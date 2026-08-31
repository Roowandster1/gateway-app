from solver import plan_week

def show(p):
    if not p: 
        print("  INFEASIBLE — budget too low for these constraints\n"); return
    print(f"=== {p['store'].upper()}  ·  spend £{p['spend']:.2f} of £{p['budget']:.2f} "
          f"·  {p['protein_day']:.0f}g protein/day  ·  {p['kcal_day']:.0f} kcal/day ===")
    print("  MEALS")
    for m in sorted(p['meals'], key=lambda m: -m['servings']):
        tag = "(breakfast)" if m['breakfast'] else ""
        print(f"   {m['servings']}x  {m['name']:<34} {m['protein']:>5.0f}g  {m['kcal']:>5.0f}kcal {tag}")
    print("  SHOP")
    for b in sorted(p['basket'], key=lambda b: b['aisle']):
        lo = f"  [{b['leftover']:.0f}{b['unit']} left]" if b['leftover'] > 0 else ""
        print(f"   {b['packs']}x {b['item']:<26} {b['size']}{b['unit']:<4} £{b['cost']:.2f}{lo}")
    print(f"  Unused ingredient left in cupboard: {p['waste']:.0f}g\n")

for budget in (25, 30, 40):
    for store in ("aldi", "tesco"):
        show(plan_week(store, budget))
