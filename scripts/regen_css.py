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
  --font-mono: var(--font-plex-mono), ui-monospace, SFMono-Regular, monospace;
}
'''
css = css.replace(
    '--sans:"Archivo",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;\n'
    '  --mono:"IBM Plex Mono",ui-monospace,SFMono-Regular,Menlo,monospace;',
    '--sans:var(--font-archivo),-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;\n'
    '  --mono:var(--font-plex-mono),ui-monospace,SFMono-Regular,Menlo,monospace;')
assert 'var(--font-archivo)' in css, 'font token bridge missing'

# The palette picker is a demo-only decision aid; the app ships one palette.
i = css.index('/* ---- palette picker')
j = css.index('/* ---- the app ---- */')
css = css[:i] + css[j:]
for pal in ('blue', 'orange', 'violet'):
    k = css.index(':root[data-palette="%s"]' % pal)
    css = css[:k] + css[css.index('\n', k) + 1:]
while ':root:not([data-theme="light"])[data-palette=' in css:
    k = css.index(':root:not([data-theme="light"])[data-palette=')
    css = css[:k] + css[css.index('\n', k) + 1:]

# The app lists meals without the demo's expandable method, so the same row
# rules have to reach a plain element too.
summary_rule = ('.meal>summary{display:flex;gap:11px;padding:9px 2px;align-items:center;'
                'cursor:pointer;\n  list-style:none;border-radius:8px}')
assert summary_rule in css
css = css.replace(summary_rule, summary_rule +
                  '\n.meal .row{display:flex;gap:11px;padding:9px 2px;align-items:center}')

css += '''
/* Solver-down message, shown under whichever screen is open. */
.screen-error{margin:0 16px 16px;padding:10px 12px;border-radius:10px;font-size:12.5px;
  background:var(--red-bg);color:var(--red)}
'''
open('apps/web/app/globals.css', 'w').write(header + css + theme)
print('globals.css regenerated,', len(header + css + theme), 'bytes')
