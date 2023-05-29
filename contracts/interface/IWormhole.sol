pragma solidity >=0.8.0 <0.9.0;

// SPDX-License-Identifier: MIT

interface IWormhole {
    function freeze(
        uint256 amount,
        uint256 toChainId,
        address toWormhole
    ) external;

    function claim(
        uint256 amount,
        uint256 fromChainId,
        address fromWormhole,
        uint256 fromNonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
