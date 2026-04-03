// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/**
 * @title AmbxPay
 * @dev A contract to handle payments in ETH or ERC20 tokens.
 * It allows users to pay a specified amount of tokens or ETH and emits an event with the payment details.
 * Need to specify the previous version for upgradeability
 * https://docs.openzeppelin.com/upgrades-plugins/api-core#define-reference-contracts
 */
contract AmbxPay is Initializable {
    using SafeERC20 for IERC20;
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // Errors
    error InvalidAdmin();
    error OnlyAdmin();
    error InvalidFee();
    error InvalidServiceFee();
    error ZeroAddress();
    error ZeroAmount();
    error NonceUsed();
    error InvalidSignature();
    error ETHTransferFailed();
    error InsufficientETH();

    uint256 public constant SCALE = 10000;
    uint256 public constant SERVICE_FEE_SCALE = 1000;

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

    // Events
    event PayEvent(bytes32 verifier, address token, uint256 amount);
    event PayToEvent(bytes32 verifier, address token, uint256 amount, address to);
    event PayClaimToEvent(bytes32 verifier, address token, uint256 amount, address to, uint256 serviceFee);
    event Withdrawn(bytes32 nonce);

    /**
     * @dev Initializes the contract with the admin address
     * @param _admin Address of the admin who can authorize withdrawals
     * @param _version Version number
     */
    function initialize(address _admin, uint256 _version) external initializer {
        if (_admin == address(0)) {
            revert InvalidAdmin();
        }

        admin = _admin;
        version = _version;
        fee = 100;
    }

    function setFee(uint256 _fee) external {
        if (msg.sender != admin) {
            revert OnlyAdmin();
        }

        if (_fee > SCALE) {
            revert InvalidFee();
        }

        fee = _fee;
    }

    /**
     * @dev Pay function to handle payments in ETH or ERC20 tokens
     * @param token Address of the token to be used for payment. Use address(0) for ETH
     * @param amount Amount of tokens to be paid. Ignored if token is ETH
     * @param verifier Verifier for the payment, which will be emitted in the event
     */
    function pay(address token, uint256 amount, bytes32 verifier) external payable {
        uint256 _amount = _pay(token, amount);

        emit PayEvent(verifier, token, _amount);
    }

    function _pay(address token, uint256 amount) internal returns (uint256 _amount) {
        if (token == address(0)) {
            _amount = msg.value;
        } else {
            _amount = amount;
            IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        }

        if (_amount == 0) {
            revert ZeroAmount();
        }

        return _amount;
    }

    /**
     * @dev Pay function to handle payments in ETH or ERC20 tokens and send to a specific address
     * @param token Address of the token to be used for payment. Use address(0) for ETH
     * @param amount Amount of tokens to be paid. Ignored if token is ETH
     * @param to Address to which the tokens/ETH will be sent
     * @param verifier Verifier for the payment, which will be emitted in the event
     */
    function payTo(address token, uint256 amount, address to, bytes32 verifier) external payable {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        uint256 _amount = _pay(token, amount);

        emit PayToEvent(verifier, token, _amount, to);

        unchecked {
            _amount = _amount - (_amount * fee) / SCALE;
        }

        if (token == address(0)) {
            (bool success,) = to.call{value: _amount}("");

            if (!success) {
                revert ETHTransferFailed();
            }
        } else {
            IERC20(token).safeTransfer(to, _amount);
        }
    }

    /**
     * @dev Pay function to handle payments which will be claimed in the future in ETH or ERC20 tokens and send to a specific address
     * @param token Address of the token to be used for payment. Use address(0) for ETH
     * @param amount Amount of tokens to be paid. Ignored if token is ETH
     * @param to Address to which the tokens/ETH will be sent
     * @param serviceFee 1000 scaled service fee
     * @param verifier Verifier for the payment, which will be emitted in the event
     */
    function payClaimTo(address token, uint256 amount, address to, uint256 serviceFee, bytes32 verifier)
        external
        payable
    {
        if (to == address(0)) {
            revert ZeroAddress();
        }

        if (serviceFee > SERVICE_FEE_SCALE) {
            revert InvalidServiceFee();
        }

        uint256 _amount = _pay(token, amount);

        emit PayClaimToEvent(verifier, token, _amount, to, serviceFee);

        unchecked {
            _amount = _amount - (_amount * fee) / SCALE;
            _amount = (_amount * serviceFee) / SERVICE_FEE_SCALE;
        }

        if (token == address(0)) {
            (bool success,) = to.call{value: _amount}("");

            if (!success) {
                revert ETHTransferFailed();
            }
        } else {
            IERC20(token).safeTransfer(to, _amount);
        }
    }

    /**
     * @dev Withdraw function to transfer tokens or ETH from the contract
     * @param signature Signature from the admin authorizing the withdrawal
     * @param token Address of the token to be withdrawn. Use address(0) for ETH.
     * @param amount Amount of tokens to be withdrawn.
     * @param to Address to which the tokens/ETH will be sent
     * @param nonce Unique nonce for the withdrawal request
     */
    function withdraw(bytes calldata signature, address token, uint256 amount, address to, bytes32 nonce) external {
        if (nonces[nonce]) {
            revert NonceUsed();
        }

        if (to == address(0)) {
            revert ZeroAddress();
        }

        // Construct the message
        bytes32 messageHash = keccak256(abi.encode(token, amount, nonce, to)).toEthSignedMessageHash();

        // Recover signer
        if (messageHash.recover(signature) != admin) {
            revert InvalidSignature();
        }

        // Mark nonce as used
        nonces[nonce] = true;

        // Transfer the tokens
        if (token == address(0)) {
            if (address(this).balance < amount) {
                revert InsufficientETH();
            }

            (bool success,) = to.call{value: amount}("");

            if (!success) {
                revert ETHTransferFailed();
            }
        } else {
            IERC20(token).safeTransfer(to, amount);
        }

        emit Withdrawn(nonce);
    }
}
