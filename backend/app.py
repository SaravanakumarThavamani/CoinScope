"""
Mini CoinGecko-style backend (Flask).

Data source:
  * LIVE  -> CoinGecko public API (no key needed, rate-limited)
  * MOCK  -> local generated data (used automatically when live fails, or force with USE_MOCK=1)

Every JSON response includes "source": "live" | "mock" so the app can show a badge.
"""
import json
import os
import threading
import time
from pathlib import Path

import requests
from flask import Flask, jsonify, request

import mock_data

app = Flask(__name__)

COINGECKO = "https://api.coingecko.com/api/v3"
FORCE_MOCK = os.getenv("USE_MOCK", "0") == "1"
CACHE_TTL = int(os.getenv("CACHE_TTL", "60"))  # seconds - protects us from API rate limits
# On a host with a persistent disk, point this at it, e.g. WATCHLIST_FILE=/data/watchlist.json
WATCHLIST_FILE = Path(os.getenv("WATCHLIST_FILE") or Path(__file__).with_name("watchlist.json"))

_cache = {}
_lock = threading.Lock()


# ---------------------------------------------------------------- helpers
@app.after_request
def add_cors(resp):
    resp.headers["Access-Control-Allow-Origin"] = "*"
    resp.headers["Access-Control-Allow-Methods"] = "GET,PUT,DELETE,OPTIONS"
    resp.headers["Access-Control-Allow-Headers"] = "Content-Type"
    return resp


def cached(key, ttl, loader):
    now = time.time()
    with _lock:
        hit = _cache.get(key)
        if hit and now - hit[0] < ttl:
            return hit[1]
    value = loader()
    with _lock:
        _cache[key] = (now, value)
    return value


def cg_get(path, params=None):
    r = requests.get(f"{COINGECKO}{path}", params=params, timeout=8,
                     headers={"Accept": "application/json", "User-Agent": "mini-gecko/1.0"})
    r.raise_for_status()
    return r.json()


def normalize(c):
    return {
        "id": c["id"], "symbol": c["symbol"], "name": c["name"], "image": c.get("image"),
        "market_cap_rank": c.get("market_cap_rank"),
        "current_price": c.get("current_price"),
        "market_cap": c.get("market_cap"),
        "total_volume": c.get("total_volume"),
        "circulating_supply": c.get("circulating_supply"),
        "total_supply": c.get("total_supply"),
        "max_supply": c.get("max_supply"),
        "price_change_percentage_24h": c.get("price_change_percentage_24h"),
        "price_change_percentage_7d": c.get("price_change_percentage_7d_in_currency"),
        "high_24h": c.get("high_24h"), "low_24h": c.get("low_24h"),
        "ath": c.get("ath"), "ath_change_percentage": c.get("ath_change_percentage"),
        "sparkline": (c.get("sparkline_in_7d") or {}).get("price", [])[::4],
    }


def load_coins():
    """Returns (coins, source). Live first, falls back to mock."""
    def loader():
        if not FORCE_MOCK:
            try:
                raw = cg_get("/coins/markets", {
                    "vs_currency": "usd", "order": "market_cap_desc", "per_page": 100,
                    "page": 1, "sparkline": "true", "price_change_percentage": "24h,7d"})
                return [normalize(c) for c in raw], "live"
            except Exception as e:  # network down, 429, etc.
                app.logger.warning("Live API failed (%s) -> using mock data", e)
        return mock_data.mock_coins(), "mock"
    # mock data "ticks" itself, so only cache live results for the full TTL
    key = "coins"
    with _lock:
        hit = _cache.get(key)
        if hit and (time.time() - hit[0] < CACHE_TTL if hit[1][1] == "live" else time.time() - hit[0] < 8):
            return hit[1]
    value = loader()
    with _lock:
        _cache[key] = (time.time(), value)
    return value


def api_error(message, status=400):
    return jsonify({"error": message}), status


def num(v, default=0.0):
    return v if isinstance(v, (int, float)) else default


# ---------------------------------------------------------------- watchlist storage
def read_watchlist():
    try:
        return json.loads(WATCHLIST_FILE.read_text())
    except Exception:
        return []


def write_watchlist(ids):
    WATCHLIST_FILE.write_text(json.dumps(ids))


# ---------------------------------------------------------------- routes
@app.get("/api/health")
def health():
    _, source = load_coins()
    return jsonify({"status": "ok", "source": source})


@app.get("/api/coins")
def list_coins():
    """Query: q, filter(all|trending|gainers|losers), sort(market_cap|price|volume|change_24h|name),
    order(asc|desc), page, per_page"""
    coins, source = load_coins()
    q = request.args.get("q", "").strip().lower()
    flt = request.args.get("filter", "all")
    sort = request.args.get("sort", "market_cap")
    order = request.args.get("order", "desc")
    try:
        page = max(int(request.args.get("page", 1)), 1)
        per_page = min(max(int(request.args.get("per_page", 20)), 1), 100)
    except ValueError:
        return api_error("page and per_page must be integers")

    if sort not in {"market_cap", "price", "volume", "change_24h", "name"}:
        return api_error(f"invalid sort '{sort}'")

    items = list(coins)
    if q:
        items = [c for c in items if q in c["name"].lower() or q in c["symbol"].lower()]
    if flt == "gainers":
        items = [c for c in items if num(c["price_change_percentage_24h"]) > 0]
    elif flt == "losers":
        items = [c for c in items if num(c["price_change_percentage_24h"]) < 0]
    elif flt == "trending":  # highest volume / market-cap turnover
        items = sorted(items, key=lambda c: num(c["total_volume"]) / max(num(c["market_cap"]), 1),
                       reverse=True)[:20]
    elif flt != "all":
        return api_error(f"invalid filter '{flt}'")

    keyfn = {
        "market_cap": lambda c: num(c["market_cap"]),
        "price": lambda c: num(c["current_price"]),
        "volume": lambda c: num(c["total_volume"]),
        "change_24h": lambda c: num(c["price_change_percentage_24h"]),
        "name": lambda c: c["name"].lower(),
    }[sort]
    items.sort(key=keyfn, reverse=(order != "asc"))

    total = len(items)
    start = (page - 1) * per_page
    return jsonify({
        "source": source, "total": total, "page": page, "per_page": per_page,
        "has_more": start + per_page < total,
        "coins": items[start:start + per_page],
    })


@app.get("/api/coins/<coin_id>")
def coin_detail(coin_id):
    coins, source = load_coins()
    coin = next((c for c in coins if c["id"] == coin_id), None)
    if not coin:
        return api_error("Coin not found", 404)

    def desc_loader():
        if source == "live":
            try:
                d = cg_get(f"/coins/{coin_id}", {
                    "localization": "false", "tickers": "false", "market_data": "false",
                    "community_data": "false", "developer_data": "false"})
                return (d.get("description") or {}).get("en", "")
            except Exception:
                pass
        return mock_data.mock_description(coin["name"])
    description = cached(f"desc:{coin_id}:{source}", 600, desc_loader)
    return jsonify({"source": source, "coin": {**coin, "description": description}})


@app.get("/api/coins/<coin_id>/chart")
def coin_chart(coin_id):
    try:
        days = int(request.args.get("days", 7))
    except ValueError:
        return api_error("days must be an integer")
    if days not in (1, 7, 30, 90, 365):
        return api_error("days must be one of 1, 7, 30, 90, 365")

    coins, source = load_coins()
    coin = next((c for c in coins if c["id"] == coin_id), None)
    if not coin:
        return api_error("Coin not found", 404)

    def loader():
        if source == "live":
            try:
                d = cg_get(f"/coins/{coin_id}/market_chart", {"vs_currency": "usd", "days": days})
                return {"prices": d["prices"], "volumes": d["total_volumes"]}, "live"
            except Exception as e:
                app.logger.warning("chart live failed: %s", e)
        return mock_data.mock_chart(coin_id, days, coin["current_price"]), "mock"
    data, src = cached(f"chart:{coin_id}:{days}", 120 if source == "live" else 20, loader)
    return jsonify({"source": src, "days": days, **data})


@app.get("/api/stats")
def stats():
    coins, source = load_coins()

    def loader():
        if source == "live":
            try:
                g = cg_get("/global")["data"]
                return {
                    "total_market_cap": g["total_market_cap"]["usd"],
                    "total_volume": g["total_volume"]["usd"],
                    "market_cap_change_24h": g["market_cap_change_percentage_24h_usd"],
                    "btc_dominance": g["market_cap_percentage"].get("btc", 0),
                    "eth_dominance": g["market_cap_percentage"].get("eth", 0),
                    "active_cryptocurrencies": g["active_cryptocurrencies"],
                    "markets": g["markets"],
                }
            except Exception as e:
                app.logger.warning("global live failed: %s", e)
        return mock_data.mock_global(coins)
    g = cached(f"global:{source}", CACHE_TTL if source == "live" else 8, loader)

    def fng_loader():
        try:
            if source == "live":
                d = requests.get("https://api.alternative.me/fng/", timeout=5).json()["data"][0]
                return {"value": int(d["value"]), "label": d["value_classification"]}
        except Exception:
            pass
        return {"value": 62, "label": "Greed"}
    fng = cached(f"fng:{source}", 600, fng_loader)

    ranked = sorted(coins, key=lambda c: num(c["price_change_percentage_24h"]), reverse=True)
    return jsonify({
        "source": source, "global": g, "fear_greed": fng,
        "top_gainers": ranked[:5], "top_losers": list(reversed(ranked[-5:])),
    })


# ---- watchlist (persisted in watchlist.json)
@app.get("/api/watchlist")
def get_watchlist():
    return jsonify({"ids": read_watchlist()})


@app.get("/api/watchlist/coins")
def get_watchlist_coins():
    ids = read_watchlist()
    coins, source = load_coins()
    by_id = {c["id"]: c for c in coins}
    return jsonify({"source": source, "coins": [by_id[i] for i in ids if i in by_id]})


@app.put("/api/watchlist/<coin_id>")
def add_watch(coin_id):
    coins, _ = load_coins()
    if not any(c["id"] == coin_id for c in coins):
        return api_error("Coin not found", 404)
    ids = read_watchlist()
    if coin_id not in ids:
        ids.append(coin_id)
        write_watchlist(ids)
    return jsonify({"ids": ids})


@app.delete("/api/watchlist/<coin_id>")
def remove_watch(coin_id):
    ids = [i for i in read_watchlist() if i != coin_id]
    write_watchlist(ids)
    return jsonify({"ids": ids})


if __name__ == "__main__":
    # Local development only. In production the server is started by gunicorn (see Procfile).
    # host 0.0.0.0 so a real phone on the same Wi-Fi can reach it
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "5000")),
            debug=os.getenv("FLASK_DEBUG", "1") == "1")
