// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { MyGovernor } from "../src/MyGovernor.sol";
import { GovToken } from "../src/GovToken.sol";
import { TimeLock } from "../src/TimeLock.sol";
import { Box } from "../src/Box.sol";

contract MyGovernorTest is Test {
    MyGovernor myGovernor;
    GovToken govToken;
    TimeLock timeLock;
    Box box;

    address USER = makeAddr("user");
    uint256 constant AMOUNT_TO_MINT = 100 ether;
    uint256 constant MIN_DELAY = 3600; // 1 hour in seconds
    uint256 constant VOTE_DELAY = 28800; // 8 hours in seconds
    uint256 constant VOTE_PERIOD = 604800; // 1 week in seconds

    address[] proposers;
    address[] executors;

    uint256[] values;
    address[] targets;
    bytes[] calldatas;

    function setUp() public {
        // Deploy the GovToken contract
        govToken = new GovToken();
        govToken.mint(USER, AMOUNT_TO_MINT);
        
        // Mint tokens to the USER
        vm.startPrank(USER);
        govToken.delegate(USER);

        timeLock = new TimeLock(MIN_DELAY, proposers, executors);
        myGovernor = new MyGovernor(govToken, timeLock);

        bytes32 proposalRole = timeLock.PROPOSER_ROLE();
        bytes32 executorRole = timeLock.EXECUTOR_ROLE();
        bytes32 adminRole = timeLock.DEFAULT_ADMIN_ROLE();

        timeLock.grantRole(proposalRole, address(myGovernor));
        timeLock.grantRole(executorRole, address(0));
        timeLock.revokeRole(adminRole, USER);
        vm.stopPrank();

        // Deploy the Box contract
        box = new Box();
        box.transferOwnership(address(timeLock));
    }

    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(42);
    }

    function testGovernanceUpdatesBox() public {
        uint256 valueToStore = 888;
        string memory description = "Store a new value in the Box contract";
        bytes memory callData = abi.encodeWithSignature("store(uint256)", valueToStore);

        values.push(0);
        targets.push(address(box));
        calldatas.push(callData);

        // 1. Propose to the DAO
        uint256 proposalId = myGovernor.propose(targets, values, calldatas, description);

        // Check proposal state
        console.log("proposal state:", uint256(myGovernor.state(proposalId)));

        vm.warp(block.timestamp + VOTE_DELAY + 1);
        vm.roll(block.number + VOTE_DELAY + 1);

        console.log("proposal state after voting delay:", uint256(myGovernor.state(proposalId)));

        // 2. Vote on the proposal
        vm.startPrank(USER);
        string memory reason = "Because I'm improving";
        uint8 voteWay = 1;

        myGovernor.castVoteWithReason(proposalId, voteWay, reason);

        console.log("proposal state after voting:", uint256(myGovernor.state(proposalId)));

        vm.warp(block.timestamp + VOTE_PERIOD + 1);
        vm.roll(block.number + VOTE_PERIOD + 1);

        console.log("proposal state after voting period:", uint256(myGovernor.state(proposalId)));

        // 3. Queue the proposal

        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        myGovernor.queue(targets, values, calldatas, descriptionHash);

        console.log("proposal state after queuing:", uint256(myGovernor.state(proposalId)));

        vm.warp(block.timestamp + MIN_DELAY + 1);
        vm.roll(block.number + MIN_DELAY + 1);

        console.log("proposal state after time warp:", uint256(myGovernor.state(proposalId)));

        // 4. Execute the proposal

        myGovernor.execute(targets, values, calldatas, descriptionHash);
        
        console.log("proposal state after execution:", uint256(myGovernor.state(proposalId)));
        vm.stopPrank();

        assertEq(box.getNumber(), valueToStore, "Box value should be updated");
        console.log("Box value after execution:", box.getNumber());

    }
}