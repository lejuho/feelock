// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @notice Minimal fee-commitment view for routers/agents.
interface IFeeCommit {
    /// @dev Fixed fee in hundredths of a bip (Uniswap-style), or type(uint24).max if using maxFee only.
    function committedFee() external view returns (uint24);

    /// @dev Upper bound; swaps with fee > maxFee must revert in the hook.
    function maxFee() external view returns (uint24);

    function feeMode() external view returns (uint8); // 0 = fixed, 1 = maxFee cap
}
