// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {UpgradeModule} from "../utils/UpgradeModule.sol";

contract UpgradeAmbxPay is Script {
    using UpgradeModule for address;

    function setUp() public {}

    function run() public {
        address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        uint256 version = vm.envUint("VERSION");
        address proxy = vm.envAddress("PROXY_ADDRESS");

        vm.startBroadcast(deployer);

        deployer.upgrade(proxy, version);

        vm.stopBroadcast();

        console.log("Upgraded implemtation contract to:", Upgrades.getImplementationAddress(proxy));
    }
}
