# AFG Coin — Development Starter Kit

**Proposed Name:** Afghanistan Coin  
**Proposed Symbol:** AFG  
**Target Network:** Solana  
**Token Standard:** Classic SPL Token  
**Target Supply:** 1,000,000,000 AFG  
**Decimals:** 6  
**Status:** Ready for testing. No Mainnet token has been created or launched yet.

## Important Cost Reality
- Design, coding, static website and local/Devnet testing can be done without spending real money.
- Devnet transactions use free test SOL that has no monetary value.
- Creating a token on Mainnet, accounts and real liquidity requires real SOL and network fees. "Zero euro real deployment" cannot be guaranteed.
- This package never executes real Mainnet transactions automatically. The Mainnet script is intentionally gated.

## Project Structure
```
AFG-Coin-Project/
├── website/                 # Static responsive landing page
│   ├── index.html
│   ├── style.css
│   └── afg-mark.svg
├── scripts/
│   ├── devnet-create.sh     # Create test token + mint 1B on Devnet
│   └── mainnet-create.sh    # Gated Mainnet template
├── docs/
│   ├── TOKENOMICS-fa.md
│   ├── SECURITY-fa.md
│   └── LAUNCH-CHECKLIST-fa.md
├── token-metadata.json      # Initial metadata (must be hosted publicly)
├── README.md
└── README-fa.md
```

## Prerequisites
1. A computer (use WSL on Windows).
2. Solana CLI + SPL Token CLI installed following official docs.
3. A separate test keypair (never use your main wallet).
4. Never share seed phrases or private keys. Never put them in the website or repository.

Official installation: https://solana.com/docs/intro/installation  
Official token guide: https://solana.com/docs/tokens/quickstart

## Quick Start — Devnet (Free)

```bash
# 1. Enter project folder
cd AFG-Coin-Project

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. (Recommended) Create a fresh test keypair
solana-keygen new --outfile ~/afg-devnet-keypair.json
solana config set --keypair ~/afg-devnet-keypair.json

# 4. Run the Devnet creator
./scripts/devnet-create.sh
```

The script will:
- Switch to Devnet
- Request test SOL (or guide you to https://faucet.solana.com/)
- Create the mint
- Create token account
- Mint exactly 1,000,000,000 AFG
- Optionally revoke Mint & Freeze authorities permanently
- Print Mint address + Explorer link

## Getting Free Devnet SOL
If the automatic airdrop fails, open:

**https://faucet.solana.com/**

1. Select **Devnet**
2. Paste your wallet address (`solana address`)
3. Request SOL
4. Wait a few seconds and check balance: `solana balance`

## Mainnet (Real Money — Use With Extreme Caution)
```bash
CONFIRM_MAINNET=I_UNDERSTAND_REAL_FUNDS ./scripts/mainnet-create.sh
```
Only after independent review, cost estimation, legal check and metadata hosting.

## Metadata
`token-metadata.json` is a starting point. Hosting it at a permanent public HTTPS URL (and an image) is required for most wallets and explorers to show name/logo. Classic SPL Token does not automatically attach Metaplex metadata — that step must be added separately before any serious launch.

## Next Steps
1. Confirm final name, symbol and logo rights
2. Publish website + whitepaper
3. Add Metaplex Token Metadata and test in wallets
4. Full Devnet transfer & authority tests
5. Independent code review
6. Conscious decision about Mainnet + liquidity

This project is **not** investment advice and promises no profit or price appreciation.
