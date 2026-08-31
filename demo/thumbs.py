"""
Build base64 thumbnails of the recipe photos for the static demo.

The demo is a published Artifact, and its CSP blocks external images — so the
only way it can show photography is to carry it inline. Full-size files would
blow the page budget, so each is scaled to a 160px square, which is twice the
56px the UI draws them at and therefore sharp on a retina screen.
"""
import base64
import io
import json
import pathlib

from PIL import Image

SRC = pathlib.Path(__file__).parents[1] / "apps" / "web" / "public" / "recipes"
OUT = pathlib.Path(__file__).parent / "images.json"
EDGE = 160

images, total = {}, 0
for path in sorted(SRC.glob("*.webp")):
    im = Image.open(path).convert("RGB")
    side = min(im.size)
    im = im.crop((
        (im.width - side) // 2, (im.height - side) // 2,
        (im.width + side) // 2, (im.height + side) // 2,
    )).resize((EDGE, EDGE), Image.LANCZOS)
    buf = io.BytesIO()
    im.save(buf, "WEBP", quality=72, method=6)
    images[path.stem] = "data:image/webp;base64," + base64.b64encode(buf.getvalue()).decode()
    total += len(buf.getvalue())

OUT.write_text(json.dumps(images, separators=(",", ":")))
print(f"{len(images)} thumbnails · {total // 1024}KB raw · "
      f"{OUT.stat().st_size // 1024}KB base64")
