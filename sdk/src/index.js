/**
 * FeeLock SDK — guardFeeConsistency
 * Core Metropolis deliverable: agents/routers call this before signing.
 */

/**
 * @typedef {'fixed'|'max'} FeeMode
 * @typedef {{ ok: true, reason: string } | { ok: false, reason: string, detail?: object }} GuardResult
 */

/**
 * Compare a quoted/expected fee against on-chain commitment.
 * @param {{
 *   quotedFee: number,
 *   committedFee: number,
 *   maxFee: number,
 *   feeMode: 0|1|number,
 *   canonicalPoolId?: `0x${string}`|string,
 *   actualPoolId?: `0x${string}`|string,
 * }} input
 * @returns {GuardResult}
 */
export function guardFeeConsistency(input) {
  const {
    quotedFee,
    committedFee,
    maxFee,
    feeMode,
    canonicalPoolId,
    actualPoolId,
  } = input;

  if (
    canonicalPoolId !== undefined &&
    actualPoolId !== undefined &&
    canonicalPoolId.toLowerCase() !== actualPoolId.toLowerCase()
  ) {
    return {
      ok: false,
      reason: 'pool_not_canonical',
      detail: { canonicalPoolId, actualPoolId },
    };
  }

  if (quotedFee > maxFee) {
    return {
      ok: false,
      reason: 'quoted_above_max',
      detail: { quotedFee, maxFee },
    };
  }

  if (Number(feeMode) === 0 && quotedFee !== committedFee) {
    return {
      ok: false,
      reason: 'quoted_ne_committed',
      detail: { quotedFee, committedFee },
    };
  }

  return { ok: true, reason: 'fee_consistent' };
}

export const feeCommitAbi = [
  {
    type: 'function',
    name: 'committedFee',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint24' }],
  },
  {
    type: 'function',
    name: 'maxFee',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint24' }],
  },
  {
    type: 'function',
    name: 'feeMode',
    stateMutability: 'view',
    inputs: [],
    outputs: [{ name: '', type: 'uint8' }],
  },
];

export const poolRegistryAbi = [
  {
    type: 'function',
    name: 'lookup',
    stateMutability: 'view',
    inputs: [
      { name: 'currency0', type: 'address' },
      { name: 'currency1', type: 'address' },
      { name: 'hooks', type: 'address' },
    ],
    outputs: [{ name: '', type: 'bytes32' }],
  },
];
