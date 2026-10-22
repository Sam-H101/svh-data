# Exchange window: silver to gold row (UI patch source)

Status: **works in the game** (2026-10-22, `data-v1` through the client DLL's redirect: the Buy gold row shows and BUY reaches
the server). The P0 table below is the earlier loose-file history. It compiles into a copy of the game's `lobby_menu.gfx`. The server side
works end to end. Design and server side: `docs/SILVER-TO-GOLD.md` in the svh server repository.

## P0 result (v0.69d0, 2026-10-22)

| What | Result |
|---|---|
| Loose `game\resources.75\flash_movies\lobby_menu\lobby_menu.gfx` (variant A) | not loaded: the "+" next to silver opens the stock window; the patched class's names are not in the client's memory; the client never opens the path |
| Loose `game\resources.76\flash_movies\lobby_menu\lobby_menu.gfx` (variant B) | not loaded, same evidence; the client never probes `resources.76` at all |
| Loose `game\resources\flash_movies\lobby_menu\lobby_menu.gfx` (variant C1, run `p0c-20261022-080747`) | not loaded, same evidence: stock window, no patched names in memory; under `game\resources\` the client reads only the splash screen and never looks up `flash_movies` or `lobby_menu` |
| New top-level `game\resources.sources\` (variant C2) | not run: only `game\resources\` was approved for this round; the client probed no `resources.sources` path either |
| BUY button pressed in the UI | not possible: the patched window never appeared |
| The request the BUY button sends, `exchange_premium_money(0x40000005)`, passed to the stock client's own callback handler (Frida, as `ExternalInterface.call` passes it) | works: the client forwards it as `46 03`; server log `[premium] bought 5 gold for 1250 silver` (rate 250); money push `root.set_account_money {generic_money: 98750, premium_money: 100005}`; save `[98750, 100005, …]`; ledger row `buy_gold`, kind 250, silver −1250, gold +5; `svh econ-check` reports the account ok |
| Stock gold-to-silver row, EXCHANGE clicked in the window (1 gold) | works: `[premium] exchanged 1 gold for 250 silver`; the client shows 100 250 silver and 99 999 gold |

Details and the evidence for "not loaded": `docs/BALANCE-PLAN.md` in the svh server repository
§3.1. The game install was restored after each run: the recursive listing of `game\resources\`
and the top-level listing of `game\` (names, sizes, times) match the ones taken before.

The game's own files are not kept here: this folder holds only our source and tools. The patched
`lobby_menu.gfx` is a build output.

## Contents

| Path | What |
|---|---|
| `src/survarium/messages/MessageMoneyExchange.as` | The exchange window class with the added "Buy gold" row. When the window is the gold-to-silver exchange, it switches the background to its taller frame, adds a second stepper (gold, priced at `amount × rate` silver) and a BUY button, and on BUY calls `exchange_premium_money` with `0x40000000 | gold`. Otherwise the window is unchanged. |
| `src/survarium/lobby/TopPanel.as` | The top panel. The gold "+" (`onPremiumMoneyAddClick`) opens the same exchange window as the silver "+" instead of the gold info / online store dialog, so it leads to the Buy gold row. Store notifications that reuse this handler (`GOTO_STORE`) open it too. (`data-v2`) |
| `tools/tagdiff.py` | Compares the tags of two `.gfx` files: after a rebuild only the code tag (DoABC) may differ. |
| `tools/symcls.py`, `tools/bounds.py` | Helpers used to find the window's symbol, class and layout. |
| `callbacks-v0.69d0.txt` | The 198 lobby callback names the game registers (the Flash side may call only these). |

## Inputs and outputs (v0.69d0)

| File | SHA-256 |
|---|---|
| Stock `lobby_menu.gfx` (from the game's newest archive holding it, `resources.75`) | `a2970d554bdb16923fd6a974d0e1d4b692ec1fa33bfe8027f7ffe4a1b8013a82` |
| Patched `lobby_menu.gfx`, `data-v1` (MessageMoneyExchange only) | `b2f4bf0d18569b63624ea4aad2169422c13c54c1b25e83360ed1c4bddff07b15` |
| Patched `lobby_menu.gfx` built from this source, `data-v2` (plus TopPanel) | `d25fce11eec2bca986cf139d019a322dd298e17e6c2778077f8b6fe444205828` |

## Build

1. Extract the stock `lobby_menu.gfx` from the install (the newest `resources.NN.db` that holds it;
   `crates/gamedata` reads the archives) and check its SHA-256 against the table.
2. With JPEXS ffdec 26.3.0 on Java 21:
   ```
   ffdec -importScript lobby_menu.gfx lobby_menu.patched.gfx src
   ```
3. `python tools/tagdiff.py lobby_menu.gfx lobby_menu.patched.gfx` must report only the DoABC tag
   as changed. (ffdec drops 2,506 junk bytes the stock file carries after its End tag, outside the
   declared length; harmless as far as known.)

## Shipping

Open. A packed archive is out (the archives are signed by the publisher), and P0 showed that the
client ignores loose files: `resources.NN\<path>` (75 and 76 tried) and
`game\resources\<path>` alike. No loose-file route is left. The client DLL has to serve the
patched file when the client loads `resources/flash_movies/lobby_menu/lobby_menu.gfx`, or patch
the archive signature check in memory. See `docs/BALANCE-PLAN.md` in the svh server repository §3.1.
