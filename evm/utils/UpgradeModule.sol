pragma solidity ^0.8.13;

import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {AmbxPay} from "../src/AmbxPay.sol";
import {AmbxPay_V_Mock} from "../src/mocks/AmbxPay_V_Mock.sol";

library UpgradeModule {
    function deploy(address deployer, uint256 version) internal returns (address proxy) {
        proxy = Upgrades.deployTransparentProxy(
            "AmbxPay.sol", deployer, abi.encodeCall(AmbxPay.initialize, (deployer, version))
        );
    }

    function upgrade(address deployer, address proxy, uint256 version) internal {
        Upgrades.upgradeProxy(
            proxy, "AmbxPay_V_Mock.sol", abi.encodeCall(AmbxPay_V_Mock.reinitializeV2, (deployer, version))
        );
    }
}
