/**
 * Demo: trading agent calls FeeLock guard and rejects a malicious pool.
 * Offline — no RPC required.
 */
import { guardFeeConsistency } from '../sdk/src/index.js';

const canonical = '0xfeed000000000000000000000000000000000001';
const malicious = '0xbad0000000000000000000000000000000000001';

const honest = guardFeeConsistency({
  quotedFee: 3000,
  committedFee: 3000,
  maxFee: 3000,
  feeMode: 0,
  canonicalPoolId: canonical,
  actualPoolId: canonical,
});

const baitAndSwitch = guardFeeConsistency({
  quotedFee: 500, // quote looked cheap
  committedFee: 3000,
  maxFee: 3000,
  feeMode: 0,
  canonicalPoolId: canonical,
  actualPoolId: canonical,
});

const lookalike = guardFeeConsistency({
  quotedFee: 3000,
  committedFee: 3000,
  maxFee: 3000,
  feeMode: 0,
  canonicalPoolId: canonical,
  actualPoolId: malicious,
});

function line(label, r) {
  const mark = r.ok ? 'PASS' : 'REJECT';
  console.log(`[${mark}] ${label} → ${r.reason}`);
}

console.log('FeeLock agent demo (Trust / AI Infra track)\n');
line('honest canonical pool', honest);
line('bait-and-switch quote', baitAndSwitch);
line('look-alike pool id', lookalike);

if (!honest.ok || baitAndSwitch.ok || lookalike.ok) {
  console.error('\nDemo invariants failed');
  process.exit(1);
}
console.log('\nAgent signs only the honest pool.');
