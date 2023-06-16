
// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@account-abstraction/contracts/samples/SimpleAccount.sol";
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
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        _addPasskey(hashEncodedId, _encodedId, _pubKeyX, _pubKeyY);
    }

    function addPasskey(string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) public override {
         bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        _addPasskey(hashEncodedId, _encodedId, _publicKeyX, _publicKeyY);
    }

    function _addPasskey(bytes32 hashEncodedId, string calldata _encodedId, uint256 _publicKeyX, uint256 _publicKeyY) internal {
        
        require(PasskeysAuthorised[hashEncodedId].pubKeyX == 0 && PasskeysAuthorised[hashEncodedId].pubKeyY == 0, "PM01: Passkey already exists");
        
        Passkey memory passkey = Passkey({
            pubKeyX: _publicKeyX,
            pubKeyY: _publicKeyY
        });
        KnownEncodedIdHashes.push(hashEncodedId);
        PasskeysAuthorised[hashEncodedId] = passkey;
        emit PasskeyAdded(_encodedId, _publicKeyX, _publicKeyY);
    }

    function removePasskey(string calldata _encodedId) external override {
        //! Need to look into this
        // require(msg.sender == address(this), "PM02: Only wallet can remove passkeys");
        require(KnownEncodedIdHashes.length > 1, "PM03: cannot remove last key");
        bytes32 hashEncodedId = keccak256(abi.encodePacked(_encodedId));
        
        Passkey memory passkey = PasskeysAuthorised[hashEncodedId];

        require(passkey.pubKeyX != 0 && passkey.pubKeyX != 0, "PM04: Passkey doesn't exist");
        
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
        emit PasskeyRemoved(_encodedId, passkey.pubKeyX, passkey.pubKeyY);
    }

   /**
    * @param userOp typical userOperation
    * @param userOpHash the hash of the user operation.
    * @return validationData
    */
    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash) 
        internal override virtual returns (uint256)
    {

        (uint r, uint s, bytes memory authenticatorData, string memory clientDataJSONPre, string memory clientDataJSONPost, bytes32 encodedIdHash) = abi.decode(
            userOp.signature,
            (uint, uint, bytes, string, string, bytes32)
        );

        string memory opHashBase64 = Base64.encode(bytes.concat(userOpHash));
        string memory clientDataJSON = string.concat(clientDataJSONPre, opHashBase64, clientDataJSONPost);
        bytes32 clientHash = sha256(bytes(clientDataJSON));
        bytes32 message = sha256(bytes.concat(authenticatorData, clientHash));

        Passkey memory passKey = PasskeysAuthorised[encodedIdHash];
        require(passKey.pubKeyX != 0 && passKey.pubKeyY != 0, "PM06: Passkey doesn't exist");

        require(Secp256r1.Verify(
            passKey,
            r, s,
            uint(message)
        ), "PM07: Invalid signature");
        return 0;
    }

}