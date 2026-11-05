# Northwind (own company)

> Loaded inside `~/projects/northwind` and the product folders listed in `map.tsv`.

## Products
| Product | Status | Next |
|---|---|---|
| Invoicer | 2.4 live | Partial refunds |
| Scheduler | 1.0 beta, 12 test customers | Calendar import |
| Reports | 3.1 live | Shared PDF renderer with Invoicer |

## Release rules
- Production deploy only after the owner says "ship" for that exact version.
- Ordinary change: tests and a try on staging. Change to permissions, exports or deletion: one independent reviewer per risk area.
- Public screenshots use demo data only. No real customer names, ever.

## Shared code
Each product still copies the analytics and rate limiter code. Moving them into one package is open, see `lessons.md`.
