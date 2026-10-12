import { test } from 'node:test';
import assert from 'node:assert/strict';
import { guardFeeConsistency } from '../src/index.js';

test('passes when fixed fee matches', () => {
  const r = guardFeeConsistency({
    quotedFee: 3000,
    committedFee: 3000,
    maxFee: 3000,
    feeMode: 0,
    canonicalPoolId: '0xabc',
    actualPoolId: '0xAbC',
  });
  assert.equal(r.ok, true);
});

test('rejects non-canonical pool', () => {
  const r = guardFeeConsistency({
    quotedFee: 3000,
    committedFee: 3000,
    maxFee: 3000,
    feeMode: 0,
    canonicalPoolId: '0xaaa',
    actualPoolId: '0xbbb',
  });
  assert.equal(r.ok, false);
  assert.equal(r.reason, 'pool_not_canonical');
});

test('rejects quoted above max', () => {
  const r = guardFeeConsistency({
    quotedFee: 12000,
    committedFee: 0xffffff,
    maxFee: 10000,
    feeMode: 1,
  });
  assert.equal(r.ok, false);
  assert.equal(r.reason, 'quoted_above_max');
});

test('rejects fixed mismatch (malicious quote)', () => {
  const r = guardFeeConsistency({
    quotedFee: 500,
    committedFee: 3000,
    maxFee: 3000,
    feeMode: 0,
  });
  assert.equal(r.ok, false);
  assert.equal(r.reason, 'quoted_ne_committed');
});
