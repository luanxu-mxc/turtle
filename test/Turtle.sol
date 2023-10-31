// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {Turtle} from "../src/Turtle.sol";

contract TurtleTest is Test {
    Turtle public turtle;
    uint public constant tokenMultiplier = 1e18;
    uint public constant totalSupply = 10_000_000_000 * tokenMultiplier;
    address public constant Alice = 0x10020FCb72e27650651B05eD2CEcA493bC807Ba4;
    address public constant Bob = 0x200708D76eB1B69761c23821809d53F65049939e;

    function setUp() public {
        turtle = new Turtle();
    }

    function testPremint() public {
        assertEq(turtle.balanceOf(address(this)), totalSupply);
    }

    function transferToAlice() private {
        turtle.transfer(Alice, 1e20);
    }

    function testBurn() public {
        turtle.burn(50);
        assertEq(turtle.totalSupply(), totalSupply - 50);
    }


    function testBurnWhenTransfer() public {
        transferToAlice();

        vm.prank(Alice);
        turtle.transfer(Bob, 1e18);
        assertEq(turtle.balanceOf(Bob), 1e18 - 1e18 * 10 / 100);
    }

    function testTransferFrom() public {
        transferToAlice();

        vm.prank(Alice);
        turtle.approve(Bob, 1e18);
        vm.prank(Bob);
        turtle.transferFrom(Alice, Bob, 1e18);
        assertEq(turtle.balanceOf(Bob), 1e18 - 1e18 * 10 / 100);
    }


    function testWhiteList() public {
        transferToAlice();
        turtle.addWhiteList(Alice);
        vm.prank(Alice);
        turtle.transfer(Bob, 1e18);
        assertEq(turtle.balanceOf(Bob), 1e18);
    }

    function testRemoveWhiteList() public {
        transferToAlice();
        turtle.addWhiteList(Alice);
        turtle.removeWhiteList(Alice);
        vm.prank(Alice);
        turtle.transfer(Bob, 1e18);
        assertEq(turtle.balanceOf(Bob), 1e18 - 1e18 * 10 / 100);
    }

    function testTransferSmallAmount() public {
        transferToAlice();

        // amount * fee less than 10000
        vm.prank(Alice);
        turtle.transfer(Bob, 30);
        assertEq(turtle.balanceOf(Bob), 30 - 30 * 10 / 100);
    }

    function testSupplyTarget() public {
        turtle.burn(totalSupply - 21_050_000 * tokenMultiplier);

        turtle.transfer(Alice, 21_050_000 * tokenMultiplier);

        vm.prank(Alice);
        turtle.transfer(Bob, 1000000 * tokenMultiplier); // fee original 100k to 50k

        assertEq(turtle.balanceOf(Bob),(1000000 - 50000) * tokenMultiplier);
        assertEq(turtle.totalSupply(), 21_000_000 * tokenMultiplier);

    }


}
