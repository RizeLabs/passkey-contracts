
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@account-abstraction/samples/SimpleAccount.sol";
import "../interfaces/IPasskeyManager.sol";
import "./PasskeyVerificationLibrary.sol";
import "../utils/Base64.sol";


contract PasskeyManager is SimpleAccount, IPasskeyManager {

    mapping(bytes32 => Passkey) private PasskeysAuthorised;
    bytes32[] public KnownEncodedIdHashes;
    
    // The constructor is used only for the "implementation" and only sets immutable values.
    // Mutable value slots for proxy accounts are set by the 'initialize' function.
    constructor(IEntryPoint anEntryPoint) SimpleAccount(anEntryPoint)  {
    }

    /**
     * The initializer for the PassKeysAcount instance.
     * @param _encodedId the id of the key
     * @param _pubKeyX public key X val from a passkey that will have a full ownership and control of this account.
     * @param _pubKeyY public key X val from a passkey that will have a full ownership and control of this account.
     */
    function initialize(string calldata _encodedId, uint256 _pubKeyX, uint256 _pubKeyY) public virtual initializer {
        super._initialize(address(0));
        _addPassKey(_encodedId, _pubKeyX, _pubKeyY, _encodedId);
    }

    function addPasskey(string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) public override {
        _addPasskey(_encodedId, _publicKeyX, _publicKeyY);
    }

    function  _addPasskey(string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) internal {
        
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        require(PasskeysAuthorised[hashEncodedId].publicKeyX == 0 && PasskeysAuthorised[hashEncodedId].publicKeyY == 0, "PM01: Passkey already exists");
        
        Passkey memory passkey = Passkey({
            publicKeyX: _publicKeyX,
            publicKeyY: _publicKeyY,
        });

        PasskeysAuthorised[hashEncodedId] = passkey;
        emit PasskeyAdded(_encodedId, _publicKeyX, _publicKeyY);
    }

    function removePasskey(string calldata _encodedId) external override {
        //! Need to look into this
        // require(msg.sender == address(this), "PM02: Only wallet can remove passkeys");
        require(KnownEncodedIdHashes.length > 1, "PM03: cannot remove last key");
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        
        Passkey memory passkey = PasskeysAuthorised[hashEncodedId];

        require(passkey.publicKeyX != 0 && passkey.publicKeyY != 0, "PM04: Passkey doesn't exist");
        
        delete PasskeysAuthorised[hashEncodedId];
        for(uint i = 0; i < KnownEncodedIdHashes.length; ){
            if(KnownEncodedIdHashes[i] == hashEncodedId){
                KnownEncodedIdHashes[i] = KnownEncodedIdHashes[KnownEncodedIdHashes.length - 1];
                KnownEncodedIdHashes.pop();
                break;
            }
            unchecked {
                i++;
            }
        }
        emit PasskeyRemoved(_encodedId, passkey.publicKeyX, passkey.publicKeyY);
    }


    /**
    * @param signature contains the signature and the clientDataJsonHash
    * @param userOpHash the hash of the user operation.
    * @return success A boolean indicating the validation result.
    */
    function validateDataAndSignature(bytes memory signature, bytes32 userOpHash) 
        internal returns (bool success)
    {

        (uint r, uint s, bytes32 message, bytes32 clientDataJsonHash, bytes32 encodedIdHash) = abi.decode(
            userOp.signature,
            (uint, uint, bytes32, bytes32, bytes32)
        );

        string memory userOpHashHex = lower(toHex(userOpHash));
        bytes memory base64RequestId = bytes(Base64.encode(userOpHashHex));
        require(keccak256(base64RequestId) == clientDataJsonHash, "PM05: Invalid clientDataJsonHash");

        passKey = PasskeysAuthorised[encodedIdHash];
        require(passKey.publicKeyX != 0 && passKey.publicKeyY != 0, "PM06: Passkey doesn't exist")

        bool success = Secp256r1.Verify(
            passKey,
            r, s,
            uint(message)
        );

        return success;
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