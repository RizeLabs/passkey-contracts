
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;


import "../interfaces/IPasskeyManager.sol";
import "./PasskeyVerificationLibrary.sol";
import "@account-abstraction/contracts/interfaces/UserOperation.sol";


contract PasskeyManager is IPasskeyManager{


    mapping(bytes32 => Passkey) private passkeysAdded;

    bytes32[] public AddedHashedEncodedIds;


    function addPasskey(string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) public override {
        // require(msg.sender == address(this), "PM01 caller is not Wallet");
        _addPasskey(_encodedId, _publicKeyX, _publicKeyY);
    }

    function  _addPasskey(string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) internal {
        
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        require(passkeysAdded[hashEncodedId].publicKeyX == 0 && passkeysAdded[hashEncodedId].publicKeyY == 0, "PM04");
        
        Passkey memory passkey = Passkey({
            publicKeyX: _publicKeyX,
            publicKeyY: _publicKeyY,
            encodedId: _encodedId
        });
        passkeysAdded[hashEncodedId] = passkey;
        emit PasskeyAdded(_encodedId, _publicKeyX, _publicKeyY);
    }

    function removePasskey(string calldata _encodedId) external override {
        require(msg.sender == address(this), "PM01 caller is not Wallet");
        require(AddedHashedEncodedIds.length > 1, "PM03 cannot remove last key");
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        
        Passkey memory passkey = passkeysAdded[hashEncodedId];

        require(passkey.publicKeyX != 0 && passkey.publicKeyY != 0, "PM05");
        
        delete passkeysAdded[hashEncodedId];
        for(uint i = 0; i < AddedHashedEncodedIds.length; ){
            if(AddedHashedEncodedIds[i] == hashEncodedId){
                AddedHashedEncodedIds[i] = AddedHashedEncodedIds[AddedHashedEncodedIds.length - 1];
                AddedHashedEncodedIds.pop();
                break;
            }
            unchecked {
                i++;
            }
        }
        emit PasskeyRemoved(_encodedId, passkey.publicKeyX, passkey.publicKeyY);
    }


    
    function validateDataAndSignature(UserOperation calldata userOp, bytes32 userOpHash) 
        internal returns (bool success)
    {
        (uint r, uint s, bytes memory authenticatorData, string memory clientDataJSONPre, string memory clientDataJSONPost) = abi.decode(
            userOp.signature,
            (uint, uint, bytes, string, string)
        );

        string memory userOpHashHex = lower(toHex(userOpHash));

        bytes memory base64RequestId = bytes(Base64.encode(userOpHashHex));
        string memory opHashBase64 = string(base64RequestId);
        string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);

        bytes32 clientHash = sha256(bytes(clientDataJSON));
        bytes32 sigHash = sha256(bytes.concat(authenticatorData, clientHash));

        // string memory userOpHashHex = lower(toHex(userOpHash));

        // bytes memory base64RequestId = bytes(Base64.encode(userOpHashHex));

        // if (keccak256(base64RequestId) != clientDataJsonHash) return false;

        // Passkey memory passkey = passkeysAdded[hashedEncodedId];

        // success = Secp256r1.Verify(
        //     uint(message),
        //     [r, s],
        //     [passkey.publicKeyX, passkey.publicKeyY]
        // );
        // Passkey memory passkey = passkeysAdded[hashedEncodedId];

        bool success = PasskeyVerificationLib.Verify(
            uint(sigHash),
            [r, s],
            [107490028906455791796471978989263119874761744151520737029565739289860294711432, 
            22721315569127605178492405433029903652409185507600908909410012870036792961855]
        );
        return true;
    }

    function toHex16(bytes16 data) 
        internal pure returns (bytes32 result) 
    {
        result =
            (bytes32(data) &
                0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000) |
            ((bytes32(data) &
                0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >>
                64);
        result =
            (result &
                0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000) |
            ((result &
                0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >>
                32);
        result =
            (result &
                0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000) |
            ((result &
                0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >>
                16);
        result =
            (result &
                0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000) |
            ((result &
                0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >>
                8);
        result =
            ((result &
                0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >>
                4) |
            ((result &
                0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >>
                8);
        result = bytes32(
            0x3030303030303030303030303030303030303030303030303030303030303030 +
                uint256(result) +
                (((uint256(result) +
                    0x0606060606060606060606060606060606060606060606060606060606060606) >>
                    4) &
                    0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) *
                7
        );
    }

    function toHex(bytes32 data) 
        public pure returns (string memory) 
    {
        return
            string(
                abi.encodePacked(
                    '0x',
                    toHex16(bytes16(data)),
                    toHex16(bytes16(data << 128))
                )
            );
    }

    function lower(string memory _base) 
        internal pure returns (string memory) 
    {
        bytes memory _baseBytes = bytes(_base);
        for (uint256 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }

    function _lower(bytes1 _b1) 
        private pure returns (bytes1) 
    {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }

        return _b1;
    }

}