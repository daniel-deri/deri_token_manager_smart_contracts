// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./interface/IWormhole.sol";
import "./token/IERC20.sol";
import "./utils/Admin.sol";

contract DeriTokenManagerBNB is Admin {
    address constant DeriAddressBNB =
        0xe60eaf5A997DFAe83739e035b005A33AfdCc6df5;
    address constant WormholeBNB = 0x15a5969060228031266c64274a54e02Fbd924AbF;
    address public rewardVaultBnb = 0x57b2cfAC46F0521957929a70ae6faDCEf2297740;

    function setRewardVaultBnb(address _rewardVaultBnb) external _onlyAdmin_ {
        rewardVaultBnb = _rewardVaultBnb;
    }

    function claimAndSendBnb(
        uint256 amount,
        uint256 fromChainId,
        address fromWormhole,
        uint256 fromNonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IWormhole(WormholeBNB).claim(
            amount,
            fromChainId,
            fromWormhole,
            fromNonce,
            v,
            r,
            s
        );
        IERC20(DeriAddressBNB).transfer(rewardVaultBnb, amount);
    }
}
