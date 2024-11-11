// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AutomationCompatibleInterface} from "chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Bank is AutomationCompatibleInterface {
    address public owner;
    uint256 public threshold;
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setThreshold(uint256 _newThreshold) external {
        require(msg.sender == owner, "Only owner can set the threshold");
        threshold = _newThreshold;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool shouldTransferFunds, bytes memory /* performData */)
    {
        shouldTransferFunds = (address(this).balance > threshold);
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        if (address(this).balance > threshold) {
            uint256 halfBalance = address(this).balance / 2;
            // payable(owner).transfer(halfBalance);
            (bool success, ) = payable(owner).call{value: halfBalance}("");
            require(success, "Transfer failed");
        }
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance); 
    }

    // Receive function to accept direct Ether transfers
    receive() external payable {
        deposit();
    }

    // Fallback function to handle any calls to non-existent functions
    fallback() external payable {
        deposit();
    }
}

