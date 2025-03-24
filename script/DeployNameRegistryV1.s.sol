// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {NameRegistryV1} from "src/NameRegistryV1.sol";

contract DeployNameRegistryV1Script is Script {
    address hubV1 = address(0x29b9a7fBb8995b2423a71cC17cf9810798F6C543);
    address seeder = address(0xf21A74B94044fB229f6FA868FA5f7236329ABC18);

    NameRegistryV1 public nameRegistryV1;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nameRegistryV1 = new NameRegistryV1(hubV1, seeder);

        vm.stopBroadcast();
    }
}
