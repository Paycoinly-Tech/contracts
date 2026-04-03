// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {console} from "forge-std/console.sol";
import {Script} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {UpgradeModule} from "../utils/UpgradeModule.sol";

contract DeployAmbxPay is Script {
    using UpgradeModule for address;

    function setUp() public {}

    function run() public {
        address deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        uint256 version = vm.envUint("VERSION");

        vm.startBroadcast(deployer);

        address proxy = deployer.deploy(version);

        vm.stopBroadcast();

        console.log("Deployed proxy contract to:", proxy);
        console.log("Deployed implemtation contract to:", Upgrades.getImplementationAddress(proxy));
    }
}
