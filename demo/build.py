"""Build demo/index.html from template.html + plans.json.

The page is static and cannot call the solver, so the solved grid is embedded.
Regenerate plans.json with services/solver/scripts/export_demo.py first.
"""
import pathlib

HERE = pathlib.Path(__file__).parent
tpl = (HERE / "template.html").read_text()
data = (HERE / "plans.json").read_text()
images = (HERE / "images.json").read_text()
fonts = (HERE / "fonts.css").read_text()
for token in ("__DATA__", "__IMAGES__", "__FONTS__"):
    assert token in tpl, f"template has no {token} placeholder"
out = (tpl.replace("__DATA__", data).replace("__IMAGES__", images)
          .replace("__FONTS__", fonts))
(HERE / "index.html").write_text(out)
print(f"built index.html — {len(data)/1024:.0f} KB solver output + "
      f"{len(images)/1024:.0f} KB photos + {len(fonts)/1024:.0f} KB fonts "
      f"= {len(out)/1024:.0f} KB")
