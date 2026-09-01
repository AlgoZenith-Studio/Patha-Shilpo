"""Per-user rate limiting for the AI endpoints (TRD.md §6).

Every AI call costs real money against the Gemini / fal.ai / Sarvam quotas,
so an authenticated user must not be able to drain them.

**In-process and per-instance.** With more than one backend instance each
holds its own counters, so the effective limit multiplies by instance count.
That is acceptable while Render runs a single instance; moving to Redis is
tracked in TRD.md §19.10 alongside the shared Bhashini pipeline cache.
"""

import time
from collections import defaultdict, deque

from fastapi import HTTPException, status


class SlidingWindowLimiter:
    """Sliding-window limiter keyed by uid.

    Chosen over a fixed window because a fixed window lets a caller burst
    double the limit across a boundary, which is exactly the case that
    matters when each request costs money.
    """

    def __init__(self, max_requests: int, window_seconds: int) -> None:
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._hits: dict[str, deque[float]] = defaultdict(deque)

    def check(self, key: str) -> None:
        now = time.monotonic()
        cutoff = now - self.window_seconds
        hits = self._hits[key]

        while hits and hits[0] < cutoff:
            hits.popleft()

        if len(hits) >= self.max_requests:
            retry_after = max(1, int(hits[0] + self.window_seconds - now))
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=(
                    "Too many AI requests. Please wait a moment and try again."
                ),
                headers={"Retry-After": str(retry_after)},
            )

        hits.append(now)

    def reset(self, key: str | None = None) -> None:
        """Test hook; also lets a future admin route clear a stuck caller."""
        if key is None:
            self._hits.clear()
        else:
            self._hits.pop(key, None)


# Generating a listing takes an artisan ~90 seconds of real work, so 20/min
# is far above genuine use while still capping runaway cost.
ai_limiter = SlidingWindowLimiter(max_requests=20, window_seconds=60)
