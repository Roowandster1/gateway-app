"""Build demo/index.html from template.html + plans.json.

The page is static and cannot call the solver, so the solved grid is embedded.
Regenerate plans.json with services/solver/scripts/export_demo.py first.
"""
import pathlib

HERE = pathlib.Path(__file__).parent
tpl = (HERE / "template.html").read_text()
data = (HERE / "plans.json").read_text()
assert "__DATA__" in tpl, "template has no __DATA__ placeholder"
(HERE / "index.html").write_text(tpl.replace("__DATA__", data))
print(f"built index.html — {len(data)/1024:.0f} KB of solver output embedded")
