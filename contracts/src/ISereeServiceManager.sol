// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface ISereeServiceManager {
    struct Order {
        bytes32 uuid;
        uint32 orderCreatedBlock;
        Status status;
        Token token;
    }

    enum Status {
        Paid,
        Unpaid
    }

    enum Token {
        sBWP,
        sKES,
        sNGN,
        sGHS
    }

    event OrderPlaced(bytes32 indexed uuid);
    event Payout(bytes32 indexed uuid);

    function latestOrderUuid() external view returns (bytes32);

    function createNewOrder(bytes32 _uuid, Token token, uint256 amount) external payable;

    function notarizeOrder(bytes32 _uuid, bytes32 message_hash, uint256 r, uint256 s, uint256 x, uint256 y) external;
}
