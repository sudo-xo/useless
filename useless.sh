#!/usr/bin/env bash
set -u

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
    echo "Run me as ./useless_on_off.sh — don't source me."
    exit 1
fi

TOKEN="Dz9mQ9NzkBcCsuGPFJ3r1bS4wgqKMHBPiVuniW8Mbonk"
TMPFILE="$(mktemp)"
trap 'rm -f "$TMPFILE"' EXIT

clear
cat <<'BANNER'
 ██╗   ██╗███████╗███████╗██╗     ███████╗███████╗███████╗
 ██║   ██║██╔════╝██╔════╝██║     ██╔════╝██╔════╝██╔════╝
 ██║   ██║███████╗█████╗  ██║     █████╗  ███████╗███████╗
 ██║   ██║╚════██║██╔══╝  ██║     ██╔══╝  ╚════██║╚════██║
 ╚██████╔╝███████║███████╗███████╗███████╗███████║███████║
  ╚═════╝ ╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝╚══════╝
BANNER
echo "======================================================"
echo "  A memecoin on Solana that promises nothing."
echo "  No roadmap. No utility. No team. No promises."
echo "  Somehow listed on Coinbase, Binance US, Kraken, Bithumb."
echo "  Market cap in the hundreds of millions. Make it make sense."
echo "======================================================"
echo

TDATA=$(curl -s --max-time 10 \
    "https://api.geckoterminal.com/api/v2/networks/solana/tokens/${TOKEN}")

PRICE=$(echo "$TDATA" | jq -r '.data.attributes.price_usd // "null"' 2>/dev/null)
MCAP=$(echo "$TDATA"  | jq -r '.data.attributes.market_cap_usd // "null"' 2>/dev/null)
FDV=$(echo "$TDATA"   | jq -r '.data.attributes.fdv_usd // "null"' 2>/dev/null)
POOL=$(echo "$TDATA"  | jq -r '.data.relationships.top_pools.data[0].id // empty' 2>/dev/null | sed 's/^solana_//')

if [[ -z "$PRICE" || "$PRICE" == "null" ]]; then
    echo "API is down. Which is fitting — even USELESS took the day off."
    exit 0
fi

fmt_num() {
    awk -v n="$1" 'BEGIN {
        n = n + 0
        if (n >= 1e9)      printf "$%.2fB", n/1e9
        else if (n >= 1e6) printf "$%.2fM", n/1e6
        else if (n >= 1e3) printf "$%.2fK", n/1e3
        else               printf "$%.2f", n
    }'
}

MCAP_H=$(fmt_num "$MCAP")
FDV_H=$(fmt_num "$FDV")
PRICE_H=$(awk -v p="$PRICE" 'BEGIN { printf "%.6f", p+0 }')
MCAP_RAW=$(awk -v m="$MCAP" 'BEGIN { printf "%.0f", m+0 }')

EXCHANGE_RATE=96
MCAP_INR=$(awk -v m="$MCAP_RAW" -v fx="$EXCHANGE_RATE" 'BEGIN { printf "%.0f", m * fx }')

CHAI=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 15 }')
SAMOSAS=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 20 }')
VADA_PAV=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 20 }')
BANANAS=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 60 }')
THALIS=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 28.4 }')
PIZZAS=$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m / 280 }')
SHANNON_BOXES=$(awk -v m="$MCAP_RAW" 'BEGIN { printf "%.0f", m / 50 }')

echo "  Current price         : \$$PRICE_H"
echo "  Market cap            : $MCAP_H"
echo "  Fully diluted (FDV)   : $FDV_H"
echo "  Circulating / Total   : ~100%  (yes, really)"
echo

echo "  ── UTILITY METER ──────────────────────────"
echo "  [░░░░░░░░░░░░░░░░░░░░] 0%"
echo "  Status: not staked, not used, not useful."
echo

echo "  ── ROADMAP ────────────────────────────────"
echo "  Q1:"
echo "  Q2:"
echo "  Q3:"
echo "  Q4:"
echo "  (All quarters intentionally left blank.)"
echo

if [[ -n "$POOL" ]]; then
    curl -s --max-time 15 \
        "https://api.geckoterminal.com/api/v2/networks/solana/pools/${POOL}/ohlcv/day?limit=30&aggregate=1" \
        | jq -r '.data.attributes.ohlcv_list[] | .[4]' 2>/dev/null | tac > "$TMPFILE"

    if [[ -s "$TMPFILE" ]]; then
        echo "  ── 30-DAY CHART (daily closes) ────────────"
        echo
        awk '
        {
            vals[NR] = $1 + 0
            if (NR == 1 || $1 < min) min = $1 + 0
            if (NR == 1 || $1 > max) max = $1 + 0
        }
        END {
            rows = 12
            range = max - min
            if (range == 0) range = 1
            for (r = rows; r >= 1; r--) {
                high = min + range * r / rows
                low  = min + range * (r - 1) / rows
                printf "  %8.5f |", high
                for (i = 1; i <= NR; i++)
                    printf "%s", (vals[i] >= low ? "█" : " ")
                printf "\n"
            }
            printf "           +"
            for (i = 1; i <= NR; i++) printf "-"
            printf "\n"
            printf "           30d ago%*snow\n", NR - 13, ""
            printf "\n  low: %.6f   high: %.6f\n", min, max
        }' "$TMPFILE"
        echo
    fi
fi

echo "  ── MARKET CAP, TRANSLATED ─────────────────"
echo "  $MCAP_H  =  ₹$(awk -v m="$MCAP_INR" 'BEGIN { printf "%.0f", m/10000000 }') Crore"
echo "  $MCAP_H  =  $CHAI cups of cutting chai"
echo "  $MCAP_H  =  $SAMOSAS samosas"
echo "  $MCAP_H  =  $VADA_PAV vada pavs"
echo "  $MCAP_H  =  $BANANAS kg of bananas"
echo "  $MCAP_H  =  $THALIS home-cooked veg thalis"
echo "  $MCAP_H  =  $PIZZAS medium pizzas"
echo "  $MCAP_H  =  $SHANNON_BOXES Claude Shannon boxes"
echo "  $MCAP_H  =  0 units of utility"
echo

echo "\"$MCAP_H for a coin whose entire pitch is 'there is no pitch.' We are all just along for the ride.\""
echo

sleep 2
echo "My one move is complete."
echo "Process $$ is now OFF. Goodbye."
exit 0
