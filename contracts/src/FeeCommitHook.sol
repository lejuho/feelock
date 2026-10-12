// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IFeeCommit} from "./IFeeCommit.sol";

/// @title FeeCommitHook
/// @notice MVP stand-in for a Uniswap v4 hook that locks fee intent.
/// Full PoolManager wiring is day-1 optional; agents read committedFee/maxFee via IFeeCommit.
contract FeeCommitHook is IFeeCommit {
    error FeeTooHigh(uint24 fee, uint24 maxFee);
    error FeeMismatch(uint24 fee, uint24 committed);
    error NotOwner();
    error AlreadyCommitted();

    address public owner;
    uint8 private _mode; // 0 fixed, 1 max
    uint24 private _committed;
    uint24 private _max;

    event FeeCommitted(uint8 mode, uint24 committedFee, uint24 maxFee);

    constructor() {
        owner = msg.sender;
    }

    function commitFixed(uint24 fee) external {
        if (msg.sender != owner) revert NotOwner();
        if (_committed != 0 || _max != 0) revert AlreadyCommitted();
        _mode = 0;
        _committed = fee;
        _max = fee;
        emit FeeCommitted(0, fee, fee);
    }

    function commitMax(uint24 maxFee_) external {
        if (msg.sender != owner) revert NotOwner();
        if (_committed != 0 || _max != 0) revert AlreadyCommitted();
        _mode = 1;
        _committed = type(uint24).max;
        _max = maxFee_;
        emit FeeCommitted(1, type(uint24).max, maxFee_);
    }

    /// @dev Call from hook beforeSwap / demo harness when an actual fee is about to apply.
    function assertFeeAllowed(uint24 fee) public view {
        if (fee > _max) revert FeeTooHigh(fee, _max);
        if (_mode == 0 && fee != _committed) revert FeeMismatch(fee, _committed);
    }

    function committedFee() external view returns (uint24) {
        return _committed;
    }

    function maxFee() external view returns (uint24) {
        return _max;
    }

    function feeMode() external view returns (uint8) {
        return _mode;
    }
}
