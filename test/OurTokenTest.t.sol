// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address Soc = makeAddr("Soc");
    address Alice = makeAddr("Alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(Soc, STARTING_BALANCE);
    }

    function testSocBalance() public {
        assertEq(ourToken.balanceOf(Soc), STARTING_BALANCE);
    }

    function testAllowancesWorks() public {
        uint256 initialAllowance = 1000;

        // Soc approves Alice to spend tokens on her behalf

        vm.prank(Soc);
        ourToken.approve(Alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(Alice);
        ourToken.transferFrom(Soc, Alice, transferAmount);

        assertEq(ourToken.balanceOf(Alice), transferAmount);
        assertEq(ourToken.balanceOf(Soc), STARTING_BALANCE - transferAmount);
    }

    function testTransfer() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        vm.prank(msg.sender);
        ourToken.transfer(receiver, amount);
        assertEq(ourToken.balanceOf(receiver), amount);
    }

    function testBalanceAferTransfer() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        uint256 initialBalance = ourToken.balanceOf(msg.sender);
        vm.prank(msg.sender);
        ourToken.transfer(receiver, amount);
        assertEq(ourToken.balanceOf(msg.sender), initialBalance - amount);
    }

    function testTransferFrom() public {
        uint256 amount = 1000;
        address receiver = address(0x1);
        vm.prank(msg.sender);
        ourToken.approve(address(this), amount);
        ourToken.transferFrom(msg.sender, receiver, amount);
        assertEq(ourToken.balanceOf(receiver), amount);
    }
}