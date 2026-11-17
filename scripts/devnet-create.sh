#!/usr/bin/env bash
set -euo pipefail

# AFG Coin — DEVNET ONLY. Never use a valuable mainnet keypair here.
DECIMALS=6
SUPPLY="1000000000"

command -v solana >/dev/null || { echo "Solana CLI is missing. Install from https://solana.com/docs/intro/installation"; exit 1; }
command -v spl-token >/dev/null || { echo "SPL Token CLI is missing."; exit 1; }

echo "============================================"
echo "  AFG Coin — DEVNET Token Creator"
echo "============================================"
echo
echo "Current Solana configuration:"
solana config get
echo
read -r -p "Type DEVNET to switch CLI to Devnet and continue: " ACK
[[ "$ACK" == "DEVNET" ]] || { echo "Cancelled."; exit 1; }

solana config set --url https://api.devnet.solana.com
WALLET="$(solana address)"
echo
echo "Fee payer wallet: $WALLET"
echo "Requesting test SOL from Devnet (no monetary value)..."
solana airdrop 2 || {
  echo "Airdrop failed. You can request SOL manually from:"
  echo "  https://faucet.solana.com/"
  echo "Then press Enter to continue..."
  read -r
}

BALANCE=$(solana balance)
echo "Current balance: $BALANCE"
echo

echo "Creating classic SPL token mint with $DECIMALS decimals..."
CREATE_OUTPUT="$(spl-token create-token --decimals "$DECIMALS" 2>&1)"
echo "$CREATE_OUTPUT"
echo

# Auto-extract Mint address (works with current CLI output format)
MINT=$(echo "$CREATE_OUTPUT" | grep -oE '[1-9A-HJ-NP-Za-km-z]{32,44}' | head -1 || true)

if [[ -z "$MINT" ]]; then
  echo "Could not auto-detect Mint address."
  read -r -p "Paste the Mint address shown above: " MINT
fi

[[ -n "$MINT" ]] || { echo "Mint address is required."; exit 1; }
echo "Using Mint: $MINT"
echo

echo "Creating associated token account..."
spl-token create-account "$MINT"

echo "Minting exactly $SUPPLY AFG..."
spl-token mint "$MINT" "$SUPPLY"

echo
echo "Verifying supply before revoking authorities..."
spl-token supply "$MINT"
echo
read -r -p "If supply is exactly 1000000000, type REVOKE to permanently disable mint and freeze authorities: " REVOKE
[[ "$REVOKE" == "REVOKE" ]] || { echo "Stopped before authority revocation. Do not distribute this test token."; exit 1; }

spl-token authorize "$MINT" mint --disable
spl-token authorize "$MINT" freeze --disable

echo
echo "============================================"
echo "  FINAL VERIFICATION"
echo "============================================"
spl-token supply "$MINT"
echo "Mint Address : $MINT"
echo "Wallet       : $WALLET"
echo "Explorer     : https://explorer.solana.com/address/$MINT?cluster=devnet"
echo
echo "Devnet test complete. This token has NO real-world value."
echo "Save the Mint address securely."
