// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {NameRegistryV1} from "src/NameRegistryV1.sol";

contract DeployNameRegistryV1Script is Script {
    NameRegistryV1 public nameRegistryV1;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nameRegistryV1 = new NameRegistryV1();

        vm.stopBroadcast();
    }
}
