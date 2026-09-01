tpl = open('demo/template.html').read()
css = tpl[tpl.index('<style>__FONTS__</style>')+len('<style>__FONTS__</style>'):]
css = css[css.index('<style>')+7 : css.index('</style>')]
header = '''@import "tailwindcss";

/* ============================================================================
   Till Total — one product, one identity.
   These rules are generated from demo/template.html's style block by
   scripts/regen_css.py, so the shipped app and the demo cannot drift.
   ========================================================================== */
'''
theme = '''
@theme inline {
  --color-board: var(--board);
  --color-paper: var(--paper);
  --color-paper-2: var(--paper-2);
  --color-ink: var(--ink);
  --color-ink-2: var(--ink-2);
  --color-rule: var(--rule);
  --color-accent: var(--accent);
  --color-soft: var(--soft);
  --color-red: var(--red);
  --color-red-bg: var(--red-bg);
  --color-green: var(--green);
  --font-sans: var(--font-archivo), ui-sans-serif, system-ui, sans-serif;
}
'''
# One family now: the mono went when the type was standardised, and with it the
# second webfont this used to bridge.
css = css.replace(
    '--sans:"Archivo",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;',
    '--sans:var(--font-archivo),-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;')
assert 'var(--font-archivo)' in css, 'font token bridge missing'
assert '--mono' not in css, 'a mono token survived in the template'

# The palette picker was a decision aid while the colour was being chosen. It has
# been removed from the demo, so this strips nothing now — kept as a no-op guard
# in case a demo-only block ever reappears.
if '/* ---- palette picker' in css:
    i = css.index('/* ---- palette picker')
    j = css.index('/* ---- the app ---- */')
    css = css[:i] + css[j:]

# The app lists meals without the demo's expandable method, so the same row
# rules have to reach a plain element too.
summary_rule = ('.meal>summary{display:flex;gap:11px;padding:9px 2px;align-items:center;'
                'cursor:pointer;\n  list-style:none;border-radius:8px}')
assert summary_rule in css
css = css.replace(summary_rule, summary_rule +
                  '\n.meal .row{display:flex;gap:11px;padding:9px 2px;align-items:center}')

css += '''
/* The demo draws a phone, so its meal list is capped and scrolls inside the
   handset. The app IS the page, and a 420px scroller inside a scrolling page is
   a scroll trap: you get day one, then the list ends under your thumb while the
   page below it sits empty. Let the page do the scrolling. */
.pane{max-height:none}

/* Solver-down message, shown under whichever screen is open. */
.screen-error{margin:0 16px 16px;padding:10px 12px;border-radius:10px;font-size:12.5px;
  background:var(--red-bg);color:var(--red)}
'''
open('apps/web/app/globals.css', 'w').write(header + css + theme)
print('globals.css regenerated,', len(header + css + theme), 'bytes')
