"""Seed the Firestore catalogue and Cloud Storage with real craft photos.

Reads ``scripts/seed_data.json``, uploads each product photo to Cloud Storage,
and writes the matching ``artisans/{uid}``, ``users/{uid}`` and
``products/{localId}`` documents.

Run from the backend directory::

    .venv/Scripts/python.exe scripts/seed_catalogue.py --dry-run
    .venv/Scripts/python.exe scripts/seed_catalogue.py

Why the Admin SDK: ``storage.rules`` only lets ``products/{artisanId}/**`` be
written by the signed-in artisan who owns that path, and ``firestore.rules``
requires ``isArtisan()`` to create a product. Seeding is neither, so it goes
through the service account, which bypasses both. That credential is a real
secret (TRD.md 5.4) - it is read from ``FIREBASE_SERVICE_ACCOUNT`` in .env and
never printed.

Re-running is safe: documents are keyed by a stable id and merged, and Storage
objects are overwritten at a deterministic path.
"""

from __future__ import annotations

import argparse
import io
import json
import mimetypes
import sys
import urllib.parse
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

# Import app.* the same way the API does, by putting the backend root on the path.
BACKEND_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(BACKEND_ROOT))

from PIL import Image  # noqa: E402
from firebase_admin import firestore, storage  # noqa: E402

from app.core.config import get_settings  # noqa: E402
from app.core.firebase import init_firebase  # noqa: E402

DEFAULT_MANIFEST = Path(__file__).with_name("seed_data.json")

# Product photos are re-encoded before upload: the source folder mixes .webp,
# .jpeg and phone captures at wildly different sizes. Uploading one normalised
# JPEG per product keeps StorageService's `processed.jpg` convention and keeps
# every object under the 2 MB ceiling storage.rules imposes on real uploads.
MAX_EDGE_PX = 1600
JPEG_QUALITY = 85


# --------------------------------------------------------------------------
# Image handling
# --------------------------------------------------------------------------

def to_jpeg_bytes(path: Path) -> bytes:
    """Decode any supported image and re-encode as a bounded, RGB JPEG."""
    with Image.open(path) as img:
        # WebP and PNG can carry alpha, which JPEG cannot represent. Flatten
        # onto white rather than letting Pillow raise on the mode mismatch.
        if img.mode in ("RGBA", "LA", "P"):
            img = img.convert("RGBA")
            flat = Image.new("RGB", img.size, (255, 255, 255))
            flat.paste(img, mask=img.split()[-1])
            img = flat
        elif img.mode != "RGB":
            img = img.convert("RGB")

        img.thumbnail((MAX_EDGE_PX, MAX_EDGE_PX), Image.LANCZOS)

        buf = io.BytesIO()
        img.save(buf, format="JPEG", quality=JPEG_QUALITY, optimize=True)
        return buf.getvalue()


def upload_public_image(bucket, blob_path: str, data: bytes) -> str:
    """Upload bytes and return a URL equivalent to client getDownloadURL().

    The app reads images with ``Image.network`` / ``CachedNetworkImage``, which
    expect the tokenised ``firebasestorage.googleapis.com`` form that the client
    SDK's ``getDownloadURL()`` produces. The Admin SDK does not mint that token,
    so we set ``firebaseStorageDownloadTokens`` ourselves and assemble the same
    URL. This keeps seeded products indistinguishable from artisan-uploaded ones
    and avoids needing the bucket to be publicly listable.
    """
    token = str(uuid.uuid4())
    blob = bucket.blob(blob_path)
    blob.metadata = {"firebaseStorageDownloadTokens": token, "seeded": "true"}
    blob.upload_from_string(data, content_type="image/jpeg")

    quoted = urllib.parse.quote(blob_path, safe="")
    return (
        f"https://firebasestorage.googleapis.com/v0/b/{bucket.name}"
        f"/o/{quoted}?alt=media&token={token}"
    )


# --------------------------------------------------------------------------
# Document builders
# --------------------------------------------------------------------------

def build_artisan_doc(src: dict[str, Any], photo_url: str | None) -> dict[str, Any]:
    """Mirror ArtisanModel.toMap() so ArtisanModel.fromMap can read it back."""
    return {
        "uid": src["uid"],
        "name": src["name"],
        "nameHi": src.get("nameHi", ""),
        "village": src.get("village", ""),
        "district": src.get("district", ""),
        "state": src.get("state", ""),
        "craft": src.get("craft", ""),
        "cluster": src.get("cluster", ""),
        "giTag": src.get("giTag"),
        # Identity fields stay empty on purpose. The document NUMBER is never
        # stored (TRD.md 5.6) and seeded artisans have verified no documents.
        "idType": None,
        "gstin": None,
        "idVerified": False,
        "idDocumentUrl": None,
        "story": src.get("story", ""),
        "storyHi": src.get("storyHi", ""),
        "yearsOfPractice": src.get("yearsOfPractice", 0),
        "photoUrl": photo_url,
        "verified": src.get("verified", True),
        "productCount": src.get("productCount", 0),
        "rating": src.get("rating", 4.9),
        "audioStoryUrl": src.get("audioStoryUrl"),
        "createdAt": src.get("createdAt")
        or (datetime.now(timezone.utc) - timedelta(days=180)).isoformat(),
    }


def build_product_doc(
    src: dict[str, Any],
    artisan: dict[str, Any],
    image_url: str,
) -> dict[str, Any]:
    """Mirror ProductModel.toMap() so ProductModel.fromMap can read it back."""
    created = datetime.now(timezone.utc) - timedelta(
        days=src.get("createdAtDaysAgo", 0)
    )
    cluster = f"{artisan.get('village', '')}, {artisan.get('district', '')}".strip(", ")

    return {
        "productId": src["localId"],
        "localId": src["localId"],
        "artisanId": src["artisanId"],
        "artisanName": artisan["name"],
        "artisanCluster": src.get("artisanCluster") or cluster,
        "artisanState": artisan.get("state", ""),
        "artisanPhotoUrl": artisan.get("photoUrl"),
        "imageUrl": image_url,
        "originalImageUrl": None,
        "title": src["title"],
        "titleHi": src.get("titleHi", ""),
        "description": src.get("description", ""),
        "descriptionHi": src.get("descriptionHi", ""),
        "tags": src.get("tags", []),
        "material": src.get("material", ""),
        "craftType": src.get("craftType", ""),
        "colors": src.get("colors", []),
        "hoursOfWork": src.get("hoursOfWork", 0),
        "materialCost": src.get("materialCost", 0),
        "priceFloor": src.get("priceFloor", 0),
        "priceSuggested": src.get("priceSuggested", 0),
        "priceMax": src.get("priceMax", 0),
        "priceFinal": src.get("priceFinal", 0),
        "priceReasoning": src.get("priceReasoning", ""),
        "priceReasoningHi": src.get("priceReasoningHi", ""),
        "state": "LIVE",
        # firestore.rules gates public reads on exactly this value.
        "status": "live",
        "channels": src.get("channels", ["storefront"]),
        "giTag": src.get("giTag"),
        "isVerified": src.get("isVerified", True),
        # ISO string, NOT a Timestamp: ProductModel.fromMap parses this with
        # DateTime.tryParse, which returns null for a Timestamp and would
        # silently reset every product to "created now". ISO-8601 also sorts
        # lexicographically, so orderBy('createdAt') still works.
        "createdAt": created.isoformat(),
    }


# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--manifest", type=Path, default=DEFAULT_MANIFEST,
        help="seed manifest JSON (default: scripts/seed_data.json)",
    )
    parser.add_argument(
        "--images-root", type=Path, default=None,
        help="override imagesRoot from the manifest",
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="validate and report without writing to Firebase",
    )
    parser.add_argument(
        "--only", action="append", default=None, metavar="LOCAL_ID",
        help="seed only these product localIds (repeatable)",
    )
    parser.add_argument(
        "--reassign-to", default=None, metavar="UID",
        help=(
            "attribute every seeded product to this artisan uid instead of the "
            "manifest's. Use it to give a real signed-in artisan account the "
            "catalogue, so the artisan app shows the same products buyers "
            "browse. NOTE: this rewrites the maker shown on each listing."
        ),
    )
    parser.add_argument(
        "--prune-placeholders", action="store_true",
        help=(
            "after --reassign-to, delete the manifest's placeholder artisan and "
            "user documents, which own nothing once products have moved."
        ),
    )
    args = parser.parse_args()

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    images_root = args.images_root or Path(manifest["imagesRoot"])
    artisans = {a["uid"]: a for a in manifest["artisans"]}
    products = manifest["products"]
    if args.only:
        products = [p for p in products if p["localId"] in set(args.only)]
        if not products:
            print(f"No products matched --only {args.only}", file=sys.stderr)
            return 1

    # Validate every image exists and decodes BEFORE touching Firebase, so a
    # bad path cannot leave the catalogue half-seeded.
    print(f"Images root: {images_root}")
    resolved: list[tuple[dict[str, Any], Path]] = []
    missing: list[str] = []
    for product in products:
        image_path = images_root / product["image"]
        if not image_path.is_file():
            missing.append(f"  {product['localId']}: {image_path}")
            continue
        if product["artisanId"] not in artisans:
            missing.append(
                f"  {product['localId']}: unknown artisanId {product['artisanId']}"
            )
            continue
        resolved.append((product, image_path))

    if missing:
        print("Cannot seed - unresolved entries:", file=sys.stderr)
        print("\n".join(missing), file=sys.stderr)
        return 1

    print(f"Resolved {len(resolved)} product image(s), {len(artisans)} artisan(s).")

    if args.dry_run:
        for product, image_path in resolved:
            raw = image_path.stat().st_size
            encoded = len(to_jpeg_bytes(image_path))
            kind = mimetypes.guess_type(image_path.name)[0] or "unknown"
            print(
                f"  [dry-run] {product['localId']}\n"
                f"            src   {image_path.name} ({kind}, {raw // 1024} KB)\n"
                f"            jpeg  {encoded // 1024} KB -> "
                f"products/{product['artisanId']}/{product['localId']}/processed.jpg\n"
                f"            doc   products/{product['localId']}  "
                f"status=live  Rs.{product['priceFinal']}"
            )
        print("\nDry run complete. No writes were made.")
        return 0

    if not init_firebase():
        print(
            "Firebase Admin could not initialise. Set FIREBASE_SERVICE_ACCOUNT "
            "in pathashilpo_backend/.env - see app/core/firebase.py.",
            file=sys.stderr,
        )
        return 1

    settings = get_settings()
    bucket_name = (
        getattr(settings, "FIREBASE_STORAGE_BUCKET", "")
        or f"{settings.FIREBASE_PROJECT_ID}.firebasestorage.app"
    )
    bucket = storage.bucket(bucket_name)
    db = firestore.client()
    print(f"Project: {settings.FIREBASE_PROJECT_ID}   Bucket: {bucket.name}\n")

    # When reassigning, the target artisan's real profile supplies the name,
    # cluster and state stamped onto every product - the manifest's placeholder
    # profiles are not written at all.
    target: dict[str, Any] | None = None
    if args.reassign_to:
        snap = db.collection("artisans").document(args.reassign_to).get()
        if not snap.exists:
            print(
                f"No artisans/{args.reassign_to} document. The artisan must "
                "finish registration before the catalogue can be moved to them.",
                file=sys.stderr,
            )
            return 1
        target = snap.to_dict() or {}
        target["uid"] = args.reassign_to
        print(
            f"Reassigning every product to {target.get('name')} "
            f"({args.reassign_to})\n"
        )

    # 1. Artisans (+ the users/{uid} role doc FirestoreService writes alongside).
    written_artisans: dict[str, dict[str, Any]] = {}
    for uid, src in ({} if target else artisans).items():
        doc = build_artisan_doc(src, src.get("photoUrl"))
        db.collection("users").document(uid).set(
            {"uid": uid, "role": "artisan", "updatedAt": firestore.SERVER_TIMESTAMP},
            merge=True,
        )
        db.collection("artisans").document(uid).set(
            {**doc, "updatedAt": firestore.SERVER_TIMESTAMP}, merge=True
        )
        written_artisans[uid] = doc
        print(f"  artisan  {uid}  {doc['name']}")

    # 2. Products: upload the photo, then write the document referencing it.
    counts: dict[str, int] = {}
    for product, image_path in resolved:
        artisan = target or written_artisans[product["artisanId"]]
        owner = artisan["uid"]
        # The Storage path is keyed by the OWNING artisan, matching
        # storage.rules (products/{artisanId}/**) so that artisan can later
        # overwrite their own photo from the app.
        blob_path = f"products/{owner}/{product['localId']}/processed.jpg"
        product = {**product, "artisanId": owner}
        image_url = upload_public_image(bucket, blob_path, to_jpeg_bytes(image_path))

        doc = build_product_doc(product, artisan, image_url)
        db.collection("products").document(product["localId"]).set(
            {**doc, "updatedAt": firestore.SERVER_TIMESTAMP}, merge=True
        )
        counts[product["artisanId"]] = counts.get(product["artisanId"], 0) + 1
        print(f"  product  {product['localId']}  {doc['title'][:46]}")

    # 3. productCount is denormalised onto the artisan for the storefront header.
    for uid, count in counts.items():
        db.collection("artisans").document(uid).set({"productCount": count}, merge=True)

    # 4. Optionally clear the placeholder artisans, which own nothing now.
    if args.reassign_to and args.prune_placeholders:
        for uid in artisans:
            db.collection("artisans").document(uid).delete()
            db.collection("users").document(uid).delete()
            print(f"  removed placeholder artisan {uid}")

    print(
        f"\nSeeded {len(resolved)} product(s) across {len(counts)} artisan(s). "
        "Re-running overwrites the same documents and Storage paths."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
