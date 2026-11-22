"""Offline mock data so the app works without internet / when the public API rate-limits."""
import zlib
import random
import time

# id, symbol, name, price, market_cap, volume_24h, circulating, total, max, chg24h, chg7d
_RAW = [
    ("bitcoin", "btc", "Bitcoin", 59028.0, 1_167_000_000_000, 28_400_000_000, 19_800_000, 19_800_000, 21_000_000, 2.1, 5.4),
    ("ethereum", "eth", "Ethereum", 1664.0, 203_400_000_000, 12_300_000_000, 120_700_000, 120_700_000, None, 2.3, -1.2),
    ("tether", "usdt", "Tether", 0.9987, 174_600_000_000, 51_000_000_000, 174_800_000_000, 174_800_000_000, None, -0.01, 0.0),
    ("binancecoin", "bnb", "BNB", 539.9, 78_000_000_000, 1_500_000_000, 144_000_000, 144_000_000, 200_000_000, 5.7, 3.1),
    ("usd-coin", "usdc", "USDC", 0.9993, 71_000_000_000, 6_800_000_000, 71_100_000_000, 71_100_000_000, None, 0.0, 0.0),
    ("ripple", "xrp", "XRP", 0.9153, 58_000_000_000, 2_900_000_000, 63_000_000_000, 99_990_000_000, 100_000_000_000, 4.2, 8.9),
    ("solana", "sol", "Solana", 69.19, 28_900_000_000, 3_100_000_000, 417_000_000, 590_000_000, None, 2.5, -4.3),
    ("tron", "trx", "TRON", 0.3039, 28_000_000_000, 900_000_000, 92_000_000_000, 92_000_000_000, None, 1.1, 2.2),
    ("dogecoin", "doge", "Dogecoin", 0.1421, 21_000_000_000, 1_400_000_000, 147_000_000_000, 147_000_000_000, None, -2.4, 6.7),
    ("cardano", "ada", "Cardano", 0.3815, 13_700_000_000, 480_000_000, 35_900_000_000, 45_000_000_000, 45_000_000_000, -1.3, -2.8),
    ("hyperliquid", "hype", "Hyperliquid", 60.2, 14_100_000_000, 620_000_000, 234_000_000, 999_000_000, None, 6.5, 12.1),
    ("zcash", "zec", "Zcash", 785.9, 13_400_000_000, 700_000_000, 16_500_000, 21_000_000, 21_000_000, 10.3, 21.4),
    ("chainlink", "link", "Chainlink", 14.9, 9_700_000_000, 410_000_000, 650_000_000, 1_000_000_000, 1_000_000_000, 3.1, 1.9),
    ("stellar", "xlm", "Stellar", 0.2201, 7_100_000_000, 150_000_000, 32_300_000_000, 50_000_000_000, 50_000_000_000, -0.8, 3.4),
    ("avalanche-2", "avax", "Avalanche", 14.1, 5_800_000_000, 300_000_000, 410_000_000, 720_000_000, 720_000_000, -3.6, -7.2),
    ("litecoin", "ltc", "Litecoin", 58.4, 4_400_000_000, 280_000_000, 75_800_000, 75_800_000, 84_000_000, 0.9, -1.1),
    ("polkadot", "dot", "Polkadot", 2.01, 3_100_000_000, 120_000_000, 1_540_000_000, 1_540_000_000, None, -4.9, -9.5),
    ("shiba-inu", "shib", "Shiba Inu", 0.0000085, 5_000_000_000, 140_000_000, 589_000_000_000_000, 589_000_000_000_000, None, 1.7, 4.0),
    ("uniswap", "uni", "Uniswap", 5.31, 3_200_000_000, 190_000_000, 600_000_000, 1_000_000_000, 1_000_000_000, 7.4, 11.8),
    ("monero", "xmr", "Monero", 301.2, 5_500_000_000, 150_000_000, 18_400_000, 18_400_000, None, 2.8, 5.5),
    ("cosmos", "atom", "Cosmos Hub", 2.55, 1_000_000_000, 60_000_000, 390_000_000, 390_000_000, None, -1.9, -6.0),
    ("near", "near", "NEAR Protocol", 1.92, 2_400_000_000, 210_000_000, 1_250_000_000, 1_270_000_000, None, 4.6, 9.3),
    ("aptos", "apt", "Aptos", 1.84, 1_300_000_000, 90_000_000, 700_000_000, 1_100_000_000, None, -2.2, -3.7),
    ("arbitrum", "arb", "Arbitrum", 0.2064, 1_100_000_000, 130_000_000, 5_400_000_000, 10_000_000_000, 10_000_000_000, 0.6, -2.5),
    ("pepe", "pepe", "Pepe", 0.0000039, 1_640_000_000, 400_000_000, 420_690_000_000_000, 420_690_000_000_000, 420_690_000_000_000, -4.7, 1.3),
    ("pudgy-penguins", "pengu", "Pudgy Penguins", 0.00419, 262_000_000, 120_000_000, 62_800_000_000, 88_800_000_000, 88_800_000_000, 2.1, 5.0),
    ("filecoin", "fil", "Filecoin", 1.33, 920_000_000, 70_000_000, 690_000_000, 1_960_000_000, 2_000_000_000, 1.4, -0.6),
    ("optimism", "op", "Optimism", 0.3102, 600_000_000, 95_000_000, 1_930_000_000, 4_294_000_000, 4_294_000_000, -1.1, 2.0),
    ("the-graph", "grt", "The Graph", 0.0412, 440_000_000, 38_000_000, 10_700_000_000, 10_800_000_000, None, 0.4, -3.3),
    ("aave", "aave", "Aave", 168.5, 2_550_000_000, 210_000_000, 15_200_000, 16_000_000, 16_000_000, 3.8, 7.7),
]

_MARKET_TS_BUCKET = 10  # seconds - prices "tick" every 10s so the app feels live


def _seed(*parts):
    return zlib.crc32("|".join(str(p) for p in parts).encode())


def _sparkline(price, chg7d, seed):
    rng = random.Random(seed)
    n = 168
    start = price / (1 + chg7d / 100)
    pts, v = [], start
    for i in range(n):
        target = start + (price - start) * (i / (n - 1))
        v = v + (target - v) * 0.08 + rng.gauss(0, price * 0.004)
        pts.append(round(max(v, price * 0.2), 10))
    pts[-1] = price
    return pts


def mock_coins():
    bucket = int(time.time() // _MARKET_TS_BUCKET)
    rng = random.Random(bucket)
    out = []
    for rank, row in enumerate(_RAW, start=1):
        (cid, sym, name, price, mcap, vol, circ, total, mx, c24, c7) = row
        jitter = 1 + rng.uniform(-0.002, 0.002)
        p = price * jitter
        cap = mcap * jitter
        change24 = c24 + rng.uniform(-0.15, 0.15)
        out.append({
            "id": cid, "symbol": sym, "name": name, "image": None,
            "market_cap_rank": rank,
            "current_price": p,
            "market_cap": cap,
            "total_volume": vol * (1 + rng.uniform(-0.03, 0.03)),
            "circulating_supply": circ,
            "total_supply": total,
            "max_supply": mx,
            "price_change_percentage_24h": change24,
            "price_change_percentage_7d": c7,
            "high_24h": p * (1 + abs(change24) / 100 + 0.01),
            "low_24h": p * (1 - abs(change24) / 100 - 0.01),
            "ath": price * 1.9,
            "ath_change_percentage": -47.4,
            "sparkline": _sparkline(p, c7, _seed(cid)),
        })
    return out


def mock_chart(coin_id, days, current_price):
    """Random walk that ends exactly at the current price. Deterministic per (coin, days)."""
    rng = random.Random(_seed(coin_id, days))
    points = {1: 96, 7: 168, 30: 180, 90: 180, 365: 240}.get(days, 150)
    now = int(time.time() * 1000)
    span = days * 24 * 3600 * 1000
    step = span / (points - 1)
    vol = 0.012 if days > 1 else 0.004
    prices = [1.0]
    for _ in range(points - 1):
        prices.append(max(prices[-1] * (1 + rng.gauss(0, vol)), 0.05))
    scale = current_price / prices[-1]
    prices = [p * scale for p in prices]
    volumes = [abs(rng.gauss(1, 0.35)) * current_price * 1e6 for _ in range(points)]
    return {
        "prices": [[int(now - span + i * step), prices[i]] for i in range(points)],
        "volumes": [[int(now - span + i * step), volumes[i]] for i in range(points)],
    }


def mock_global(coins):
    total_cap = sum(c["market_cap"] for c in coins) * 1.18
    total_vol = sum(c["total_volume"] for c in coins) * 1.4
    btc = next(c for c in coins if c["id"] == "bitcoin")
    eth = next(c for c in coins if c["id"] == "ethereum")
    return {
        "total_market_cap": total_cap,
        "total_volume": total_vol,
        "market_cap_change_24h": 1.3,
        "btc_dominance": btc["market_cap"] / total_cap * 100,
        "eth_dominance": eth["market_cap"] / total_cap * 100,
        "active_cryptocurrencies": 17_284,
        "markets": 1_341,
    }


def mock_description(name):
    return (f"{name} is a digital asset tracked in this demo app. This description is mock "
            f"text shown when live data is unavailable. In live mode the backend fetches the "
            f"real description from the CoinGecko API.")
