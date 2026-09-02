# Catalogue seeding

Populates Cloud Storage and Firestore with real craft photos and the matching
artisan and product documents, so the buyer-facing catalogue has content to
show.

## Run it

From `pathashilpo_backend/`:

```bash
# Validate images, paths and encoded sizes. Writes nothing.
.venv/Scripts/python.exe scripts/seed_catalogue.py --dry-run

# Actually seed.
.venv/Scripts/python.exe scripts/seed_catalogue.py

# Seed a single product while iterating on its copy.
.venv/Scripts/python.exe scripts/seed_catalogue.py --only loc_dhokra_peacock_ewer
```

Re-running is safe. Documents are keyed by a stable id and merged; Storage
objects are overwritten at a deterministic path.

## Adding more images

Edit `seed_data.json` — the script needs no changes.

1. Drop the photo anywhere under `imagesRoot` (default
   `C:/Users/archi/OneDrive/Desktop/Images`, override with `--images-root`).
2. Add a `products[]` entry. `image` is the path relative to `imagesRoot`;
   `artisanId` must match an entry in `artisans[]`.
3. `craftType` must be one of the values in `MockBuyerData.craftCategories`
   (frontend `lib/data/mock/mock_buyer_data.dart`) or the product will not be
   reachable from any explore filter chip.
4. Dry-run, then run.

Source images can be `.jpg`, `.png`, `.webp` or anything else Pillow decodes —
each is re-encoded to a bounded RGB JPEG (max 1600px, quality 85) before upload.

## Why the Admin SDK

`storage.rules` only lets `products/{artisanId}/**` be written by the signed-in
artisan who owns that path, and `firestore.rules` requires `isArtisan()` to
create a product. Seeding is neither, so it authenticates with the service
account in `FIREBASE_SERVICE_ACCOUNT`, which bypasses both rule sets. That
credential is a real secret (TRD.md §5.4): it is read from `.env`, never
printed, and must never be committed or shipped in the app.

## Two details worth knowing

**`createdAt` is written as an ISO-8601 string, not a Firestore Timestamp.**
`ProductModel.fromMap` parses it with `DateTime.tryParse`, which returns null
for a Timestamp object — every product would silently show as created *now*.
ISO-8601 also sorts lexicographically, so ordering still works.

**Download URLs are minted by hand.** The app reads images with
`CachedNetworkImage`, which expects the tokenised `firebasestorage.googleapis.com`
URL that the *client* SDK's `getDownloadURL()` produces. The Admin SDK does not
mint that token, so the script sets `firebaseStorageDownloadTokens` itself and
assembles the same URL. Seeded products are then indistinguishable from
artisan-uploaded ones, and the bucket need not be publicly listable.
