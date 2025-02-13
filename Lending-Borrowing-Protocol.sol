// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LendingProtocol is Ownable {
    struct Loan {
        uint256 amount;
        uint256 interest;
        uint256 dueDate;
        bool repaid;
    }

    mapping(address => uint256) public deposits;
    mapping(address => Loan) public loans;
    uint256 public interestRate = 5; // 5% interest rate

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount, uint256 interest);
    event Repaid(address indexed user, uint256 amount);

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        uint256 interest = (amount * interestRate) / 100;
        loans[msg.sender] = Loan(amount, interest, block.timestamp + 30 days, false);
        payable(msg.sender).transfer(amount);
        emit Borrowed(msg.sender, amount, interest);
    }

    function repay() external payable {
        Loan storage loan = loans[msg.sender];
        require(!loan.repaid, "Loan already repaid");
        require(msg.value >= loan.amount + loan.interest, "Insufficient repayment amount");
        loan.repaid = true;
        emit Repaid(msg.sender, msg.value);
    }
}
