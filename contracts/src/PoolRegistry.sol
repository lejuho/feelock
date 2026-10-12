// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title PoolRegistry
/// @notice Canonical pool pointer per (currency0, currency1, hooks). Replaces ENS for FeeLock MVP.
contract PoolRegistry {
    error NotOwner();
    error ZeroAddress();
    error AlreadyRegistered();

    event CanonicalRegistered(
        address indexed currency0,
        address indexed currency1,
        address indexed hooks,
        bytes32 poolId,
        address registrant
    );

    mapping(bytes32 => bytes32) public canonicalPoolId; // key => poolId
    mapping(bytes32 => address) public registrantOf;

    function key(address currency0, address currency1, address hooks) public pure returns (bytes32) {
        require(currency0 < currency1, "order");
        return keccak256(abi.encodePacked(currency0, currency1, hooks));
    }

    function register(
        address currency0,
        address currency1,
        address hooks,
        bytes32 poolId
    ) external {
        if (hooks == address(0)) revert ZeroAddress();
        bytes32 k = key(currency0, currency1, hooks);
        if (canonicalPoolId[k] != bytes32(0)) revert AlreadyRegistered();
        canonicalPoolId[k] = poolId;
        registrantOf[k] = msg.sender;
        emit CanonicalRegistered(currency0, currency1, hooks, poolId, msg.sender);
    }

    function lookup(address currency0, address currency1, address hooks) external view returns (bytes32) {
        return canonicalPoolId[key(currency0, currency1, hooks)];
    }
}
