// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "../src/Turtle.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_KEY"));
        address turtleAddr = address(new Turtle());
        Turtle(turtleAddr).burn(5_000_000_000 * 1e18);
        console2.log("(turtle address) ->", turtleAddr);
        vm.stopBroadcast();
    }
}
