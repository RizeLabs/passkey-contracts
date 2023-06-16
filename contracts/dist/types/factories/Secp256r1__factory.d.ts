import { Signer, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { Secp256r1, Secp256r1Interface } from "../Secp256r1";
type Secp256r1ConstructorParams = [signer?: Signer] | ConstructorParameters<typeof ContractFactory>;
export declare class Secp256r1__factory extends ContractFactory {
    constructor(...args: Secp256r1ConstructorParams);
    deploy(overrides?: Overrides & {
        from?: string;
    }): Promise<Secp256r1>;
    getDeployTransaction(overrides?: Overrides & {
        from?: string;
    }): TransactionRequest;
    attach(address: string): Secp256r1;
    connect(signer: Signer): Secp256r1__factory;
    static readonly bytecode = "0x60d6610039600b82828239805160001a60731461002c57634e487b7160e01b600052600060045260246000fd5b30600052607381538281f3fe7300000000000000000000000000000000000000003014608060405260043610603d5760003560e01c806372a4c30f14604257806391327ec614607a575b600080fd5b60687fffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63255181565b60405190815260200160405180910390f35b60687fffffffff00000001000000000000000000000000ffffffffffffffffffffffff8156fea26469706673582212204ea99fffde2d45bda4fea30e265653a3d7a1d3f156a388947d8b9c6b2a37072464736f6c634300080c0033";
    static readonly abi: readonly [{
        readonly inputs: readonly [];
        readonly name: "nn";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }, {
        readonly inputs: readonly [];
        readonly name: "pp";
        readonly outputs: readonly [{
            readonly internalType: "uint256";
            readonly name: "";
            readonly type: "uint256";
        }];
        readonly stateMutability: "view";
        readonly type: "function";
    }];
    static createInterface(): Secp256r1Interface;
    static connect(address: string, signerOrProvider: Signer | Provider): Secp256r1;
}
export {};
