# FeeLock

Trust layer for Uniswap v4 routers and trading agents: verify onchain that a pool's executed fee matches its commitment before signing.

**Track:** Monad Metropolis — Trust, Identity & AI Infrastructure  
**Deadline:** 2026-10-14 12:59 KST (2026-10-13 23:59 ET)  
**Submit:** working demo + short write-up + code link on [hackathon.monad.xyz](https://hackathon.monad.xyz)

## Pitch

Uniswap v4 dynamic-fee hooks can charge a different fee at execution than what a quote implied. FeeLock lets issuers commit a fee (or max fee) onchain, registers a canonical pool without ENS, and gives agents a single `guardFeeConsistency` check that rejects mismatched pools before they sign.

## MVP (one day)

| Piece | Status | Notes |
|-------|--------|-------|
| `FeeCommitHook` | scaffold | commits fixed/`maxFee`; reverts if swap fee exceeds commit |
| `PoolRegistry` | scaffold | on-chain canonical pool id per (token0, token1, hook) |
| `guardFeeConsistency` (viem SDK) | scaffold | quote fee vs committed fee; returns pass/fail + reason |
| Agent demo | scaffold | mock agent rejects malicious pool |

Out of scope for day 1: full Uniswap v4 PoolManager integration on Monad mainnet, ENS, production UI.

## Disclose vs Klamp

Idea lineage only: Klamp ([EarthIsMine/klamp](https://github.com/EarthIsMine/klamp), ETHGlobal Tokyo). FeeLock is a new repo. All Metropolis deliverables (registry, hook commit, SDK guard, demo) are new work in the Sep 1–Oct 13 window.

## Quick start

```bash
# contracts
cd contracts && forge test

# sdk
cd ../sdk && npm i && npm test

# demo (offline mock)
cd ../demo && node agent-reject.mjs
```

## Layout

- `contracts/` — Foundry: FeeCommitHook, PoolRegistry, tests
- `sdk/` — viem guard
- `demo/` — agent rejects malicious pool
- `docs/BUILD.md` — tonight → submit checklist
