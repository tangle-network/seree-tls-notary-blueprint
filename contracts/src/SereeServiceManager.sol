// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {ECDSAServiceManagerBase} from "@eigenlayer-middleware/src/unaudited/ECDSAServiceManagerBase.sol";
import {ECDSAStakeRegistry} from "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {IServiceManager} from "@eigenlayer-middleware/src/interfaces/IServiceManager.sol";
import {ECDSAUpgradeable} from
    "../lib/eigenlayer-middleware/lib/openzeppelin-contracts-upgradeable/contracts/utils/cryptography/ECDSAUpgradeable.sol";
import {IERC1271Upgradeable} from
    "../lib/eigenlayer-middleware/lib/openzeppelin-contracts-upgradeable/contracts/interfaces/IERC1271Upgradeable.sol";
import {ISereeServiceManager} from "./ISereeServiceManager.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./p256/verifier.sol";

interface IERC20 {
    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

/**
 * @title Primary entrypoint for procuring services from Sereé (https://seree.xyz).
 * @author Eigen Labs, Inc.
 */
contract SereeServiceManager is ECDSAServiceManagerBase, ISereeServiceManager {
    using ECDSAUpgradeable for bytes32;

    // Sereé Sepolia Address
    address public constant RECIPIENT = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    bytes32 public latestOrderUuid;

    address public sBWPADDRESS;
    address public sKESADDRESS;
    address public sNGNADDRESS;
    address public sGHSADDRESS;

    mapping(uint256 => Order) public orders;
    mapping(uint256 => uint256) public escrowBalances;

    modifier onlyOperator() {
        require(ECDSAStakeRegistry(stakeRegistry).operatorRegistered(msg.sender), "Operator must be the caller");
        _;
    }

    struct NotaryInfo {
        string serverUrl;
        uint16 port;
        bool isActive;
    }

    mapping(address => NotaryInfo) public notaries;
    address[] public notaryList;

    event NotaryAdded(address indexed notary, string serverUrl, uint16 port);

    /**
     * @notice Add or update a notary's server information
     * @param notary The address of the notary operator
     * @param serverUrl The URL of the notary's server
     * @param port The port number the notary server is listening on
     */
    function addNotary(address notary, string calldata serverUrl, uint16 port) external {
        require(msg.sender == owner() || msg.sender == notary, "Caller must be owner or notary");
        require(bytes(serverUrl).length > 0, "Server URL cannot be empty");
        require(port > 0, "Port must be greater than 0");

        if (!notaries[notary].isActive) {
            notaryList.push(notary);
        }

        notaries[notary] = NotaryInfo({serverUrl: serverUrl, port: port, isActive: true});

        emit NotaryAdded(notary, serverUrl, port);
    }

    constructor(
        address _avsDirectory,
        address _stakeRegistry,
        address _rewardsCoordinator,
        address _delegationManager,
        address sBWPADDR,
        address sKESADDR,
        address sNGNADDR,
        address sGHSADDR
    ) ECDSAServiceManagerBase(_avsDirectory, _stakeRegistry, _rewardsCoordinator, _delegationManager) {
        sBWPADDRESS = sBWPADDR;
        sKESADDRESS = sKESADDR;
        sNGNADDRESS = sNGNADDR;
        sGHSADDRESS = sGHSADDR;
    }

    /* FUNCTIONS */
    function createNewOrder(bytes32 _uuid, Token token, uint256 amount) external payable {
        require(amount > 0, "Amount must be greater than 0");

        address tokenAddress;
        latestOrderUuid = _uuid;

        if (token == Token.sBWP) {
            tokenAddress = sBWPADDRESS;
        } else if (token == Token.sKES) {
            tokenAddress = sKESADDRESS;
        } else if (token == Token.sNGN) {
            tokenAddress = sNGNADDRESS;
        } else if (token == Token.sGHS) {
            tokenAddress = sGHSADDRESS;
        } else {
            revert("Invalid token type");
        }

        uint256 allowance = IERC20(tokenAddress).allowance(msg.sender, address(this));
        require(allowance >= amount, "Insufficient allowance");

        Order memory newOrder =
            Order({uuid: _uuid, orderCreatedBlock: uint32(block.number), status: Status.Unpaid, token: token});

        orders[uint256(_uuid)] = newOrder;
        escrowBalances[uint256(_uuid)] = amount;

        bool success = IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        emit OrderPlaced(_uuid);
    }

    function notarizeOrder(bytes32 _uuid, bytes32 message_hash, uint256 r, uint256 s, uint256 x, uint256 y)
        external
        override
    {
        SignatureVerifier sigVerifier = new SignatureVerifier();

        bool isValidSignature = sigVerifier.verify(message_hash, r, s, x, y);
        require(isValidSignature, "Invalid signature");

        Order storage order = orders[uint256(_uuid)];
        require(order.status == Status.Unpaid, "Order already paid");

        uint256 amount = escrowBalances[uint256(_uuid)];
        require(amount > 0, "Amount must be greater than 0");

        if (order.token == Token.sBWP) {
            require(IERC20(sBWPADDRESS).transfer(RECIPIENT, amount), "Pula transfer failed");
        } else if (order.token == Token.sKES) {
            require(IERC20(sKESADDRESS).transfer(RECIPIENT, amount), "Shilling transfer failed");
        } else if (order.token == Token.sNGN) {
            require(IERC20(sNGNADDRESS).transfer(RECIPIENT, amount), "Naira transfer failed");
        } else if (order.token == Token.sGHS) {
            require(IERC20(sGHSADDRESS).transfer(RECIPIENT, amount), "Cedi transfer failed");
        } else {
            revert("Invalid token type");
        }

        order.status = Status.Paid;
        escrowBalances[uint256(_uuid)] = 0;

        emit Payout(_uuid);
    }
}
