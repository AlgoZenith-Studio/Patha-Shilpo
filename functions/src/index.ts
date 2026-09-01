import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { onDocumentWritten } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";

initializeApp();

/** Roles the app recognises (firestore.rules `role()`). */
const VALID_ROLES = ["artisan", "buyer", "moderator", "dept"] as const;
type Role = (typeof VALID_ROLES)[number];

function isRole(value: unknown): value is Role {
  return typeof value === "string" && (VALID_ROLES as readonly string[]).includes(value);
}

/**
 * Mirrors `users/{uid}.role` into the Firebase Auth custom claims.
 *
 * WHY A FIRESTORE TRIGGER, NOT AN AUTH onCreate TRIGGER:
 * the role is not known at sign-up. Pathashilpa authenticates with phone OTP
 * and only afterwards asks whether this is an artisan or a buyer, so an
 * `auth.user().onCreate` hook would fire with nothing to assign. The role
 * first exists when `saveArtisanProfile` / `saveBuyerProfile` writes
 * `users/{uid}` (firestore_service.dart), which is exactly what this watches.
 *
 * WHY MIRROR AT ALL:
 * `firestore.rules` resolves the role with `get(/databases/$(db)/documents/users/$(uid))`.
 * That is a billed document read on EVERY rule evaluation - every product
 * write, every RFQ read. The same role in a custom claim rides along inside
 * the ID token and costs nothing to check. The rules should prefer the claim
 * and keep the `get()` as a fallback (see the note in firestore.rules), which
 * is what makes this migration safe to roll out while old tokens are still
 * circulating.
 *
 * PROPAGATION CAVEAT: a custom claim only reaches the client on the next ID
 * token refresh (up to an hour, or immediately via `getIdToken(true)`). That
 * is precisely why the rules must not depend on the claim alone - a freshly
 * registered artisan would otherwise be locked out of their own profile until
 * their token happened to refresh.
 */
export const syncRoleClaim = onDocumentWritten(
  { document: "users/{uid}", region: "asia-south1" },
  async (event) => {
    const uid = event.params.uid;
    const after = event.data?.after;

    // Document deleted: strip the claim rather than leaving a role attached
    // to an account that no longer has a profile.
    if (!after?.exists) {
      await getAuth().setCustomUserClaims(uid, null);
      logger.info("Cleared role claim", { uid });
      return;
    }

    const role = after.data()?.role;
    if (!isRole(role)) {
      logger.warn("users doc has no valid role; leaving claims untouched", {
        uid,
        role,
      });
      return;
    }

    // No-op when nothing changed. setCustomUserClaims would otherwise run on
    // every unrelated field update (updatedAt is written on each profile
    // save), burning an Auth write and invalidating tokens for no reason.
    const existing = (await getAuth().getUser(uid)).customClaims?.role;
    if (existing === role) return;

    await getAuth().setCustomUserClaims(uid, { role });
    logger.info("Role claim set", { uid, role, previous: existing ?? null });
  }
);
