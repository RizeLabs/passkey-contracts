// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

struct Passkey {
    uint256 pubKeyX;
    uint256 pubKeyY;
}

interface IPasskeyManager {

    event PasskeyAdded(string encodedId, uint256 publicKeyX, uint256 publicKeyY);
    event PasskeyRemoved(string encodedId, uint256 publicKeyX, uint256 publicKeyY);

    function addPasskey(string calldata _encodedId, uint256 publicKeyX, uint256 publicKeyY) external;
    function removePasskey(string calldata _encodedId) external;
}