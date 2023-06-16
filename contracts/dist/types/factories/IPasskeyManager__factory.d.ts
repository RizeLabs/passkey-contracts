import { Signer } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type { IPasskeyManager, IPasskeyManagerInterface } from "../IPasskeyManager";
export declare class IPasskeyManager__factory {
    static readonly abi: readonly [{
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: false;
            readonly internalType: "string";
            readonly name: "encodedId";
            readonly type: "string";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "publicKeyX";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "publicKeyY";
            readonly type: "uint256";
        }];
        readonly name: "PasskeyAdded";
        readonly type: "event";
    }, {
        readonly anonymous: false;
        readonly inputs: readonly [{
            readonly indexed: false;
            readonly internalType: "string";
            readonly name: "encodedId";
            readonly type: "string";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "publicKeyX";
            readonly type: "uint256";
        }, {
            readonly indexed: false;
            readonly internalType: "uint256";
            readonly name: "publicKeyY";
            readonly type: "uint256";
        }];
        readonly name: "PasskeyRemoved";
        readonly type: "event";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "string";
            readonly name: "_encodedId";
            readonly type: "string";
        }, {
            readonly internalType: "uint256";
            readonly name: "publicKeyX";
            readonly type: "uint256";
        }, {
            readonly internalType: "uint256";
            readonly name: "publicKeyY";
            readonly type: "uint256";
        }];
        readonly name: "addPasskey";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }, {
        readonly inputs: readonly [{
            readonly internalType: "string";
            readonly name: "_encodedId";
            readonly type: "string";
        }];
        readonly name: "removePasskey";
        readonly outputs: readonly [];
        readonly stateMutability: "nonpayable";
        readonly type: "function";
    }];
    static createInterface(): IPasskeyManagerInterface;
    static connect(address: string, signerOrProvider: Signer | Provider): IPasskeyManager;
}
