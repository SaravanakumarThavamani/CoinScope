# Interview prep – how to explain this project

## 30-second pitch
"I built a CoinGecko-style research app. Flutter uses GetX for state, dependency injection and navigation. A Flask backend sits between the app and
the CoinGecko API: it normalises the data, caches it for 60 s to avoid rate limits, falls back to mock data if the
live API fails, and does search / filter / sort / pagination on the server. The watchlist is persisted on the backend.
Every screen handles loading, error and empty states, and the chart is interactive."

## Design decisions (say these out loud)
1. **Why a backend instead of calling CoinGecko from Flutter?** Hide API details, caching + rate-limit protection,
   one stable JSON shape, mock fallback, a place to persist the watchlist. In production I'd also keep API keys there.
2. **Why GetX?** Less boilerplate: reactive state (`.obs` + `Obx`), DI (`Get.put/find`) and navigation (`Get.to`) in one
   package, no BuildContext needed in controllers. Trade-off: it's less strict than Bloc/Riverpod, so I keep controllers
   small, one per feature, and keep all API logic in `ApiService`.
3. **Debounced search (400 ms)** using GetX's `debounce` worker, so we don't call the API on every keystroke. **Request-id guard** in `MarketController.load`
   so a slow old response can't overwrite a newer one (race condition).
4. **Optimistic watchlist toggle** – UI updates instantly, rolls back and shows a SnackBar if the server fails.
5. **Single `ApiException`** – the service converts timeouts / socket errors / 4xx-5xx into one message the UI shows.
6. **Silent auto-refresh every 30 s** (no spinner, errors ignored) → "live" feel without flicker.
7. **Infinite scroll** via `ScrollController` + `has_more` from the server.
8. **Mock data** ticks every 10 s with small jitter, so the UI looks live offline.

## Likely questions
* *setState vs GetX?* setState = tiny local UI state (search clear button); GetX controllers = shared/async state.
* *Obx vs GetBuilder?* `Obx` auto-rebuilds when an `.obs` variable read inside it changes (reactive). `GetBuilder`
  needs `update()` (manual). I use Obx everywhere, in small pieces so only the changed part rebuilds.
* *Get.put vs Get.lazyPut vs Get.find?* put = create now, lazyPut = create on first use, find = fetch the instance.
  `AppBinding` registers everything once. `CoinDetailController` uses a **tag** (coin id) and `Get.delete` in `dispose`.
* *What are `onInit` / `onClose`?* Controller lifecycle: I start the first load and the 30 s refresh timer in `onInit`
  and cancel the timer in `onClose`.
* *How does the chart interaction work?* `fl_chart` `LineTouchData` → `touchCallback` gives the touched index →
  I call `onSelect` and the screen shows that price/time in the header.
* *How would you handle API keys?* Environment variables on the backend, never in the app.
* *What would you improve?* Real DB (SQLite/Postgres) + per-user auth for watchlist, websockets for live prices,
  offline cache (Hive/Isar), more tests (provider tests with a fake ApiService), candlestick chart, pagination from
  the real API instead of a cached top-100.
* *How do you test?* `ApiService` is injectable (takes an `http.Client`), so controllers can be tested with a fake (`Get.put<ApiService>(Fake())`).

## Demo script (2 min)
1. Open Markets → show LIVE/MOCK pill, search "eth", clear, tap **Top Gainers**, sort by **Price**.
2. Open a coin → drag on the chart, switch 24H → 1Y, scroll to supply bar, tap ⭐.
3. Stats tab → dominance donut, Fear & Greed, tap a top gainer.
4. Watchlist tab → swipe to remove → **Undo**.
5. Stop the Flask server → pull to refresh → show **error state + Try again** → restart server → retry.
