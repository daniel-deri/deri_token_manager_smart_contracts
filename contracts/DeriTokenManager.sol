// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./interface/IArbitrumTokenGateway.sol";
import "./interface/IZksyncL1ERC20Bridge.sol";
import "./interface/IWormhole.sol";
import "./token/IERC20.sol";
import "./utils/Admin.sol";

//mainnet
contract DeriTokenManager is Admin {
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

    function approveAll() public {
        approveGateway();
        approveZkBridge();
        approveWormholeEthereum();
    }

    function mintAndBridgeToArbitrum(
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address _token,
        address _to,
        uint256 _amount,
        uint256 _maxGas,
        uint256 _gasPriceBid,
        bytes calldata _data
    ) external payable returns (bytes memory) {
        IERC20(DeriAddress).mint(address(this), _amount, deadline, v, r, s);
        bytes memory data = IArbitrumTokenGateway(ArbitrumGatewayRouter)
            .outboundTransfer{value: msg.value}(
            _token,
            _to,
            _amount,
            _maxGas,
            _gasPriceBid,
            _data
        );
        return data;
    }

    function mintAndBridgeToZksync(
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte
    ) external payable returns (bytes32) {
        IERC20(DeriAddress).mint(address(this), _amount, deadline, v, r, s);
        // IERC20(DeriAddress).mint(address(this), _amount);
        bytes32 txHash = IZksyncL1ERC20Bridge(ZksyncL1Bridge).deposit{
            value: msg.value
        }(
            _l2Receiver,
            _l1Token,
            _amount,
            _l2TxGasLimit,
            _l2TxGasPerPubdataByte
        );
        return txHash;
    }

    function mintAndBridgeToZksync(
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address _l2Receiver,
        address _l1Token,
        uint256 _amount,
        uint256 _l2TxGasLimit,
        uint256 _l2TxGasPerPubdataByte,
        address _refundRecipient
    ) external payable returns (bytes32) {
        IERC20(DeriAddress).mint(address(this), _amount, deadline, v, r, s);
        // IERC20(DeriAddress).mint(address(this), _amount);
        bytes32 txHash = IZksyncL1ERC20Bridge(ZksyncL1Bridge).deposit{
            value: msg.value
        }(
            _l2Receiver,
            _l1Token,
            _amount,
            _l2TxGasLimit,
            _l2TxGasPerPubdataByte,
            _refundRecipient
        );
        return txHash;
    }

    function mintAndBridgeToBnb(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20(DeriAddress).mint(address(this), amount, deadline, v, r, s);
        IWormhole(WormholeEthereum).freeze(amount, 56, WormholeBNB);
    }

    function claimAndSendBnb(
        uint256 amount,
        uint256 fromChainId,
        address fromWormhole,
        uint256 fromNonce,
        uint8 v,
        bytes32 r,
        bytes32 s,
        address to
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
        IERC20(DeriAddress).transfer(to, amount);
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
}
