// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./interface/IArbitrumTokenGateway.sol";
import "./interface/IZksyncL1ERC20Bridge.sol";
import "./interface/IWormhole.sol";
import "./token/IERC20.sol";
import "./utils/Admin.sol";

contract DeriTokenManager is Admin {
    struct Signature {
        uint256 amount;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct CrossChainDetails {
        bool isArbitrum;
        uint256 poolId;
        address _token;
        address _to;
        uint256 _maxGas;
        uint256 _gasPriceBid;
        uint256 _value;
        bytes _data;
        address _l2Receiver;
        address _l1Token;
        uint256 _l2TxGasLimit;
        uint256 _l2TxGasPerPubdataByte;
        address _refundRecipient;
    }

    // poolId => rewardPerSeconds
    // 0 -> Arbitrum RewardVault V2
    // 1 -> Arbitrum Uniswap
    // 2 -> Zksync RewardVault V2
    // 3 -> BNB RewardVault V2
    mapping(uint256 => uint256) public rewardPerWeeks;

    address constant DeriAddress = 0xA487bF43cF3b10dffc97A9A744cbB7036965d3b9;
    address constant ArbitrumGatewayRouter =
        0x72Ce9c846789fdB6fC1f34aC4AD25Dd9ef7031ef;
    address constant ArbitrumGateway =
        0xa3A7B6F88361F48403514059F1F16C8E78d60EeC;
    address constant ZksyncL1Bridge =
        0x57891966931Eb4Bb6FB81430E6cE0A03AAbDe063;
    address constant WormholeEthereum =
        0x6874640cC849153Cb3402D193C33c416972159Ce;
    address constant WormholeBNB = 0x15a5969060228031266c64274a54e02Fbd924AbF;

    function approveGateway() public {
        IERC20(DeriAddress).approve(ArbitrumGateway, type(uint256).max);
    }

    function approveGatewayRouter() public {
        IERC20(DeriAddress).approve(ArbitrumGatewayRouter, type(uint256).max);
    }

    function approveZkBridge() public {
        IERC20(DeriAddress).approve(ZksyncL1Bridge, type(uint256).max);
    }

    function approveWormholeEthereum() public {
        IERC20(DeriAddress).approve(WormholeEthereum, type(uint256).max);
    }

    function approveAll() external {
        approveGateway();
        approveZkBridge();
        approveWormholeEthereum();
    }

    function callZksyncL2TransactionBaseCost(
        address contractAddress,
        uint256 _gasPrice,
        uint256 _gasLimit,
        uint256 _l2GasPerPubdataByteLimit
    ) public view returns (uint256) {
        bytes memory data = abi.encodeWithSelector(
            bytes4(
                keccak256(
                    bytes("l2TransactionBaseCost(uint256,uint256,uint256)")
                )
            ),
            _gasPrice,
            _gasLimit,
            _l2GasPerPubdataByteLimit
        );
        (bool success, bytes memory returnData) = contractAddress.staticcall(
            data
        );
        require(success, "The static call was not successful.");
        uint256 returnValue = abi.decode(returnData, (uint256));
        return returnValue;
    }

    function withdraw(address token) external _onlyAdmin_ {
        uint256 amount = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(msg.sender, amount);
    }

    function setRewardPerWeek(
        uint256 poolId,
        uint256 _rewardPerWeek
    ) external _onlyAdmin_ {
        rewardPerWeeks[poolId] = _rewardPerWeek;
    }

    function setRewardPerWeek(
        uint256[] calldata _rewardPerWeek
    ) external _onlyAdmin_ {
        for (uint256 i = 0; i < _rewardPerWeek.length; i++) {
            rewardPerWeeks[i] = _rewardPerWeek[i];
        }
    }

    function bridgeAll(CrossChainDetails[] calldata details) public payable {
        // Bridge to each cross chain address
        for (uint256 i = 0; i < details.length; i++) {
            if (details[i].isArbitrum) {
                IArbitrumTokenGateway(ArbitrumGatewayRouter).outboundTransfer{
                    value: details[i]._value
                }(
                    details[i]._token,
                    details[i]._to,
                    rewardPerWeeks[details[i].poolId],
                    details[i]._maxGas,
                    details[i]._gasPriceBid,
                    details[i]._data
                );
            } else {
                IZksyncL1ERC20Bridge(ZksyncL1Bridge).deposit{
                    value: details[i]._value
                }(
                    details[i]._l2Receiver,
                    details[i]._l1Token,
                    rewardPerWeeks[details[i].poolId],
                    details[i]._l2TxGasLimit,
                    details[i]._l2TxGasPerPubdataByte,
                    details[i]._refundRecipient
                );
            }
        }
        // Bridge to BNB
        if (rewardPerWeeks[3] > 0) {
            IWormhole(WormholeEthereum).freeze(
                rewardPerWeeks[3],
                56,
                WormholeBNB
            );
        }
    }

    function mintAndBridgeAll(
        Signature calldata signature,
        CrossChainDetails[] calldata details
    ) external payable {
        // Calculate the total amount for all transfers
        uint256 totalAmount = rewardPerWeeks[3];
        for (uint256 i = 0; i < details.length; i++) {
            totalAmount += rewardPerWeeks[details[i].poolId];
        }
        require(
            totalAmount == signature.amount,
            "DeriTokenManager: invalid total mint amount"
        );
        // Mint the tokens first
        IERC20(DeriAddress).mint(
            address(this),
            totalAmount,
            signature.deadline,
            signature.v,
            signature.r,
            signature.s
        );
        // IERC20(DeriAddress).mint(address(this), totalAmount);
        // Bridge to each cross chain address
        this.bridgeAll{value: msg.value}(details);
    }
}
