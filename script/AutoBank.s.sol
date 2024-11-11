// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Bank} from "../src/AutoBank.sol";

contract BankScript is Script {
    Bank public bank;
    uint256 threshold = 0.008 ether;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);

        bank = new Bank(threshold);
        console.log("Bank deployed to:", address(bank));

        vm.stopBroadcast();
    }
}

