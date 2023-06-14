// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "../core/PasskeyManager.sol";
import "@account-abstraction/contracts/core/EntryPoint.sol";

import "../sample/SimpleAccountFactory.sol";
import "../sample/SimpleAccount.sol";


contract Test{
    receive() external payable {}

    function test()public {

        EntryPoint ep = new EntryPoint();
        (bool success, bytes memory data) = payable(address(ep)).call{value: 10000000000000000000, gas: 5000}("");
        SimpleAccountFactory saf = new SimpleAccountFactory(ep);

        // address add = saf.gettAddress("0x123", 50154210413425546543605881311699361520208269110677682396480363772223717523047, 62694730549099512740841131318305417639942661076452323756044724856231678508221, 0);
        // SimpleAccount account = saf.createAccount("0x123", 50154210413425546543605881311699361520208269110677682396480363772223717523047, 62694730549099512740841131318305417639942661076452323756044724856231678508221, 0);

        UserOperation memory userOp = UserOperation({
            // sender: address(account),
            sender: address(this),
            nonce: 0,
            initCode: bytes(""),
            callData: "0x2694bd1d0000000000000000000000008b220bc9529c0bc18265c1b822fcc579ee586ba2000000000000000000000000000000000000000000000000000000e8d4a510000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043a4b66f100000000000000000000000000000000000000000000000000000000",
            callGasLimit: 349525,
            verificationGasLimit: 1500000,
            preVerificationGas: 54156,
            maxFeePerGas: 286435135998,
            maxPriorityFeePerGas: 1500000000,
            paymasterAndData: bytes(""),
            // signature: abi.encode(
            //     keccak256(abi.encodePacked("test")),
            //     uint256(0x7b1d4e87baa8ae41b3f2f054552c1dbb94fa2857924833fee90b56520976885b),
            //     uint256(0x41936d56ed7fba91313899b6578970170758090258d4a21b87d09dc3641baaa0),
            //     bytes.concat(bytes32(0xf95bc73828ee210f9fd3bbe72d97908013b0a3759e9aea3d0ae318766cd2e1ad), bytes5(0x0500000000)),
            //     string('{"type":"webauthn.get","challenge":"'),
            //     string('","origin":"https://webauthn.me","crossOrigin":false}')
            // )
            signature: "0x792d699f26620a150e19d027c702afd8b1eca09b26585a93a264ff5f319b6ce8c2b387cd7ca009ffaa47a1cacb0e94eea5e74b5bee008f678b0d22494b3ecb427a2c44bc6e9ef9850b7b2869808a60bd67f8790b6c9c68a159eda25c38802cd2a7849fdfaf29521832f841580a407b6284f3b5c1e9f4528c767aae7ed2e5d894"
        });

        // (bool success1, bytes memory data1) = payable(address(account)).call{value: 10000000000000000000, gas: 5000}("");

        UserOperation[] memory ops = new UserOperation[](1);
        ops[0] = userOp;
        // ep.handleOps(ops, payable(address(account)));
    }
}
