// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title AmbxPay_V_Mock
 * @dev A contract to handle payments in ETH or ERC20 tokens.
 * Need to specify the previous version for upgradeability
 * https://docs.openzeppelin.com/upgrades-plugins/api-core#define-reference-contracts
 * It allows users to pay a specified amount of tokens or ETH and emits an event with the payment details.
 * @custom:oz-upgrades-from AmbxPay
 */
contract AmbxPay_V_Mock is Initializable {
    // Track used nonces to prevent replay
    mapping(bytes32 => bool) public nonces;
    // Admin address for withdrawal authorization
    address public admin;
    // version
    uint256 public version;
    // fee
    uint256 public fee;
    // gap for future storage variables (upgradability)
    uint256[50] private _gap;

    /**
     * @dev Initializes the contract with the admin address
     * @param _admin Address of the admin who can authorize withdrawals
     * @param _version Version number
     */
    function reinitializeV2(address _admin, uint256 _version) external reinitializer(2) {
        admin = _admin;
        version = _version;
    }

    function pay() external pure returns (string memory) {
        return "pay_upgraded_mock";
    }

    function withdraw() external pure returns (string memory) {
        return "pay_upgraded_withdraw_mock";
    }

    function anotherFunctionAdded() external pure returns (string memory) {
        return "anotherFunctionAdded_mock";
    }
}
