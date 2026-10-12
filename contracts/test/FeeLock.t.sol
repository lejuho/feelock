// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PoolRegistry} from "../src/PoolRegistry.sol";
import {FeeCommitHook} from "../src/FeeCommitHook.sol";

contract FeeLockTest is Test {
    PoolRegistry reg;
    FeeCommitHook hook;
    address t0 = address(0xA11CE);
    address t1 = address(0xB0B);

    function setUp() public {
        // enforce token order
        if (t0 > t1) (t0, t1) = (t1, t0);
        reg = new PoolRegistry();
        hook = new FeeCommitHook();
    }

    function test_register_and_lookup() public {
        bytes32 poolId = keccak256("pool-1");
        reg.register(t0, t1, address(hook), poolId);
        assertEq(reg.lookup(t0, t1, address(hook)), poolId);
    }

    function test_register_twice_reverts() public {
        reg.register(t0, t1, address(hook), keccak256("a"));
        vm.expectRevert(PoolRegistry.AlreadyRegistered.selector);
        reg.register(t0, t1, address(hook), keccak256("b"));
    }

    function test_commit_fixed_allows_exact() public {
        hook.commitFixed(3000);
        hook.assertFeeAllowed(3000);
    }

    function test_commit_fixed_rejects_other() public {
        hook.commitFixed(3000);
        // fixed mode sets max == committed, so a higher fee hits FeeTooHigh first
        vm.expectRevert(abi.encodeWithSelector(FeeCommitHook.FeeTooHigh.selector, uint24(5000), uint24(3000)));
        hook.assertFeeAllowed(5000);
    }

    function test_commit_fixed_rejects_lower_mismatch() public {
        hook.commitFixed(3000);
        vm.expectRevert(abi.encodeWithSelector(FeeCommitHook.FeeMismatch.selector, uint24(500), uint24(3000)));
        hook.assertFeeAllowed(500);
    }

    function test_commit_max_rejects_above() public {
        hook.commitMax(10000);
        hook.assertFeeAllowed(9999);
        vm.expectRevert(abi.encodeWithSelector(FeeCommitHook.FeeTooHigh.selector, uint24(10001), uint24(10000)));
        hook.assertFeeAllowed(10001);
    }
}
