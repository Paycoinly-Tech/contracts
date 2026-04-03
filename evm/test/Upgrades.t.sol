// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/console.sol";
import {UpgradeModule} from "../utils/UpgradeModule.sol";
import {AmbxPay} from "../src/AmbxPay.sol";
import {AmbxPay_V_Mock} from "../src/mocks/AmbxPay_V_Mock.sol";

interface IOwnable {
    function owner() external view returns (address);
}

contract UpgradesTest is Test {
    using UpgradeModule for address;

    function setUp() public {}

    function test_upgrade() public {
        uint256 version1 = 1;
        uint256 version2 = 2;

        address proxy = address(this).deploy(version1);

        // Get the instance of the contract
        AmbxPay instance = AmbxPay(proxy);

        // Get the implementation address of the proxy
        address implAddrV1 = Upgrades.getImplementationAddress(proxy);

        // Get the admin address of the proxy
        address adminAddr = Upgrades.getAdminAddress(proxy);

        // Ensure the admin address is valid
        assertEq(IOwnable(adminAddr).owner(), address(this));

        // Log the initial value
        console.log("----------------------------------");
        console.log("Value before upgrade --> ", instance.version());
        console.log("----------------------------------");

        // Verify initial value is as expected
        assertEq(instance.version(), version1);

        // Upgrade the proxy to mocked version
        address(this).upgrade(proxy, version2);

        // Get the new implementation address after upgrade
        address implAddrV2 = Upgrades.getImplementationAddress(proxy);

        // Verify admin address remains unchanged
        assertEq(Upgrades.getAdminAddress(proxy), adminAddr);

        // Verify implementation address has changed
        assertFalse(implAddrV1 == implAddrV2);

        assertEq(AmbxPay_V_Mock(address(instance)).version(), version2);

        // Log and verify the updated value
        console.log("----------------------------------");
        console.log("Value after upgrade --> ", instance.version());
        console.log("----------------------------------");
        assertEq(AmbxPay_V_Mock(address(instance)).pay(), "pay_upgraded_mock");
        assertEq(AmbxPay_V_Mock(address(instance)).withdraw(), "pay_upgraded_withdraw_mock");
        assertEq(AmbxPay_V_Mock(address(instance)).anotherFunctionAdded(), "anotherFunctionAdded_mock");
    }
}
