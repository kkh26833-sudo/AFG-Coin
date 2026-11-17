#!/usr/bin/env bash
set -euo pipefail

# PRODUCTION TEMPLATE — intentionally gated. Review all costs and metadata first.
DECIMALS=6
SUPPLY="1000000000"

if [[ "${CONFIRM_MAINNET:-}" != "I_UNDERSTAND_REAL_FUNDS" ]]; then
  echo "Blocked. This script can spend real SOL."
  echo 'After independent review, set: CONFIRM_MAINNET=I_UNDERSTAND_REAL_FUNDS'
  echo "Example:"
  echo "  CONFIRM_MAINNET=I_UNDERSTAND_REAL_FUNDS ./scripts/mainnet-create.sh"
  exit 1
fi

command -v solana >/dev/null || { echo "Solana CLI is missing."; exit 1; }
command -v spl-token >/dev/null || { echo "SPL Token CLI is missing."; exit 1; }

echo "============================================"
echo "  AFG Coin — MAINNET (REAL FUNDS)"
echo "============================================"
echo
echo "MAINNET CONFIGURATION:"
solana config get
echo
read -r -p "Type the exact word MAINNET to continue: " ACK
[[ "$ACK" == "MAINNET" ]] || { echo "Cancelled."; exit 1; }

solana config set --url https://api.mainnet-beta.solana.com
WALLET="$(solana address)"
echo
echo "Fee payer: $WALLET"
echo "This wallet will pay real SOL. Confirm it is a dedicated project wallet."
read -r -p "Type the full wallet address to confirm: " WALLET_ACK
[[ "$WALLET_ACK" == "$WALLET" ]] || { echo "Wallet mismatch. Cancelled."; exit 1; }

echo
echo "Creating classic SPL mint..."
CREATE_OUTPUT="$(spl-token create-token --decimals "$DECIMALS" 2>&1)"
echo "$CREATE_OUTPUT"
echo

MINT=$(echo "$CREATE_OUTPUT" | grep -oE '[1-9A-HJ-NP-Za-km-z]{32,44}' | head -1 || true)
if [[ -z "$MINT" ]]; then
  read -r -p "Paste the new Mint address: " MINT
fi
[[ -n "$MINT" ]] || { echo "Mint address required."; exit 1; }
echo "Using Mint: $MINT"
echo

spl-token create-account "$MINT"
spl-token mint "$MINT" "$SUPPLY"

echo
echo "Verify the supply output below before authority revocation:"
spl-token supply "$MINT"
echo
read -r -p "Type exactly 1000000000-AFG-VERIFIED to revoke both authorities permanently: " FINAL_ACK
[[ "$FINAL_ACK" == "1000000000-AFG-VERIFIED" ]] || { echo "Stopped. Do not distribute until reviewed."; exit 1; }

spl-token authorize "$MINT" mint --disable
spl-token authorize "$MINT" freeze --disable

echo
echo "============================================"
echo "  MAINNET TOKEN CREATED"
echo "============================================"
spl-token supply "$MINT"
echo "Mint Address : $MINT"
echo "Wallet       : $WALLET"
echo "Explorer     : https://explorer.solana.com/address/$MINT"
echo
echo "IMPORTANT: Metadata, market liquidity, legal review and independent verification are separate tasks."
echo "Publish the Mint address only after double-checking on Explorer."
