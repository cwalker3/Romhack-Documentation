# Source & build pipeline

The source documents and scripts that generate the site's data. **The live site
(`../docs`) is fully self-contained and needs nothing in this folder at runtime** —
everything here is only for (re)generating the data.

## Pipeline

```
*.txt ──parse.ps1──► data.json ──enrich.ps1──► data.json ──build.ps1──► ../docs/data.js
                                     ▲
                          PokeAPI + Showdown data files
```

## Files

| File | Purpose |
|------|---------|
| `*.txt` | The original RR/SS change documents — the source of truth for all parsed data. |
| `parse.ps1` | Parses the `.txt` files into `data.json` (Pokémon, areas, moves, evolutions, items, gifts, thief). |
| `enrich.ps1` | Adds full base stats (Gen-6-corrected) and each Pokémon's vanilla Ability 1. |
| `build.ps1` | Runs parse + enrich and writes `../docs/data.js`. **This is the one to run.** |
| `fetch-sprites.ps1` | Re-downloads all 721 sprites into `../docs/sprites.js`. Only needed if sprites change. |
| `pokemon_stats.csv`, `pokemon_abilities.csv`, `ability_names.csv` | PokeAPI data (base stats, abilities). |
| `gen6-pokedex.ts`, `gen7-pokedex.ts` | Pokémon Showdown historical base-stat overrides (for Gen-6 accuracy). |

## Rebuild the data

```powershell
powershell -ExecutionPolicy Bypass -File build.ps1
```

Regenerates `../docs/data.js` from the `.txt` files. The frontend itself
(`../docs/index.html`, `app.js`, `styles.css`) is hand-maintained — not generated.
