import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";


// import {
//   arrayify,
//   BytesLike,
//   defaultAbiCoder,
//   getCreate2Address,
//   hexConcat,
//   hexDataSlice,
//   keccak256,
// } from "ethers/lib/utils";

import UserOperation from "./utils/userOperation";




describe("PasskeyManager", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOneYearLockFixture() {
    // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    // const ONE_GWEI = 1_000_000_000;

    // const lockedAmount = ONE_GWEI;
    // const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // Contracts are deployed using the first signer/account by default
    console.log("owner")
    // console.log(await ethers.getSigner);
    console.log("OK");
    const [owner] = await ethers.getSigners();
    // console.log("owner", signers[0].address)

    // const chainId = hre.network.config.chainId
    // console.log("chainId", chainId)

    const EP = await ethers.getContractFactory("EP");
    const ep = await EP.deploy();
    console.log("ep", await ep.getAddress())

    const PassKeyManagerFactory = await ethers.getContractFactory("SimpleAccountFactory");
    const passKeyManagerFactory = await PassKeyManagerFactory.deploy(await ep.getAddress());
    console.log("passKeyManagerFactory", await passKeyManagerFactory.getAddress())

    // const Test = await ethers.getContractFactory("Test");
    // const test = await Test.deploy(); 
    // const owner = signers[0];
    return { ep, passKeyManagerFactory,owner };
  }

  describe("Deployment", function () {
    it("Should ", async function () {
      console.log("ewfwefwfwfwfewf")
      const { ep, passKeyManagerFactory, owner } = await loadFixture(deployOneYearLockFixture);

      const abicoder =  new ethers.AbiCoder();

      const add = await passKeyManagerFactory.gettAddress("abcd", "0x6ee246f17bc61a711f23629960353320cf7dc3d8c53c719efacd0b212ad63e67", "0x8a9bf5c1af217f5e0aa4e3bd671429bb0ff855c3932c4ca02962b035f31cfcbd", 0);
      console.log("add", add)
      // console.log("before", await ethers.provider.getCode(add));
      await expect(passKeyManagerFactory.createAccount("abcd", "0x6ee246f17bc61a711f23629960353320cf7dc3d8c53c719efacd0b212ad63e67", "0x8a9bf5c1af217f5e0aa4e3bd671429bb0ff855c3932c4ca02962b035f31cfcbd", 0))
        .to.emit(passKeyManagerFactory, "AccountCreated")
        .withArgs(add.toString());

      // await passKeyManagerFactory.createAccount("abcd", "0x6ee246f17bc61a711f23629960353320cf7dc3d8c53c719efacd0b212ad63e67", "0x8a9bf5c1af217f5e0aa4e3bd671429bb0ff855c3932c4ca02962b035f31cfcbd", 0);
      const scw = await ethers.getContractAt("PasskeyAccount", add);
      // console.log("getDeployedCode", await scw.getDeployedCode() );
      const finalSignature = "0x31ee1ddaff95e0ced0930c66a7681f6c6ac7b1f1ad0e59bbef9952c42a15c096eae5225b2ebde52b6a3bbca09e05966be089217449f0d1928c098e9028969e9eb5f1ee8ce934d9b012ec517f939e10903cc26cf626a0f535577a0c80fcb52a16";
      // console.log("simpleAccountFactory", await passKeyManagerFactory.getAddress())
      console.log("here")
      const op: UserOperation = {
        "sender": add,
        "nonce": "0",
        "initCode": "0x",
        "callData": "0x2694bd1d0000000000000000000000008b220bc9529c0bc18265c1b822fcc579ee586ba2000000000000000000000000000000000000000000000000000000e8d4a510000000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000043a4b66f100000000000000000000000000000000000000000000000000000000",
        "callGasLimit": ethers.toBigInt("0x055555"),
        "verificationGasLimit": "1500000",
        "maxFeePerGas": ethers.toBigInt("0x42b0dd51fe"),
        "maxPriorityFeePerGas": ethers.toBigInt("0x59682f00"),
        "paymasterAndData": "0x",
        "preVerificationGas": ethers.toBigInt("0xd38c"),
        // "signature": "0x792d699f26620a150e19d027c702afd8b1eca09b26585a93a264ff5f319b6ce8c2b387cd7ca009ffaa47a1cacb0e94eea5e74b5bee008f678b0d22494b3ecb427a2c44bc6e9ef9850b7b2869808a60bd67f8790b6c9c68a159eda25c38802cd2a7849fdfaf29521832f841580a407b6284f3b5c1e9f4528c767aae7ed2e5d894",
        "signature": abicoder.encode(
          ["uint", "uint","bytes", "string", "string"],
          [
            ethers.toBigInt(finalSignature.slice(0,66)),
            ethers.toBigInt("0x"+finalSignature.slice(66,130)),
            "0x49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97630500000000",
            '{"type":"webauthn.get","challenge":"',
            '","origin":"http://localhost:3000","crossOrigin":false,"other_keys_can_be_added_here":"do not compare clientDataJSON against a template. See https://goo.gl/yabPex"}'
          ]
        ),
        // "48bed44d1bcd124a28c27f343a817e5f5243190d3c52bf347daf876de1dbbf77"
    }
      console.log("balance of owner: ", await ethers.provider.getBalance(owner.address))
      
      
      await owner.sendTransaction({to: await ep.getAddress(), value: ethers.parseEther("1")});
      console.log("balance of ep: ", await ethers.provider.getBalance(await ep.getAddress()))
      console.log("here0")
      console.log("balance of scw: ", await ethers.provider.getBalance(add))
      

      await owner.sendTransaction({to: add, value: ethers.parseEther("1")});
      console.log("balance of scw: ", await ethers.provider.getBalance(add))

      console.log("here1")

      console.log("deposit of scw: ", await scw.getDeposit())
      // await ep.depositTo(add, {value: ethers.parseEther("1")});
      console.log("deposit of scw: ", await scw.getDeposit())

      console.log("here2")
      
      console.log("userOp", op)
      await ep.handleOps([op], add);
      console.log("balance of scw: ", await ethers.provider.getBalance(add))

    });

    // it("Should set the right owner", async function () {
    //   const { lock, owner } = await loadFixture(deployOneYearLockFixture);

    //   expect(await lock.owner()).to.equal(owner.address);
    // });

    // it("Should receive and store the funds to lock", async function () {
    //   const { lock, lockedAmount } = await loadFixture(
    //     deployOneYearLockFixture
    //   );

    //   expect(await ethers.provider.getBalance(lock.address)).to.equal(
    //     lockedAmount
    //   );
    // });

    // it("Should fail if the unlockTime is not in the future", async function () {
    //   // We don't use the fixture here because we want a different deployment
    //   const latestTime = await time.latest();
    //   const Lock = await ethers.getContractFactory("Lock");
    //   await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
    //     "Unlock time should be in the future"
    //   );
    // });
  });

//   describe("Withdrawals", function () {
//     describe("Validations", function () {
//       it("Should revert with the right error if called too soon", async function () {
//         const { lock } = await loadFixture(deployOneYearLockFixture);

//         await expect(lock.withdraw()).to.be.revertedWith(
//           "You can't withdraw yet"
//         );
//       });

//       it("Should revert with the right error if called from another account", async function () {
//         const { lock, unlockTime, otherAccount } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         // We can increase the time in Hardhat Network
//         await time.increaseTo(unlockTime);

//         // We use lock.connect() to send a transaction from another account
//         await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
//           "You aren't the owner"
//         );
//       });

//       it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
//         const { lock, unlockTime } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         // Transactions are sent using the first signer by default
//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw()).not.to.be.reverted;
//       });
//     });

//     describe("Events", function () {
//       it("Should emit an event on withdrawals", async function () {
//         const { lock, unlockTime, lockedAmount } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw())
//           .to.emit(lock, "Withdrawal")
//           .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
//       });
//     });

//     describe("Transfers", function () {
//       it("Should transfer the funds to the owner", async function () {
//         const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
//           deployOneYearLockFixture
//         );

//         await time.increaseTo(unlockTime);

//         await expect(lock.withdraw()).to.changeEtherBalances(
//           [owner, lock],
//           [lockedAmount, -lockedAmount]
//         );
//       });
//     });
//   });
});
