// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Vesting {
    struct Vest {
        uint256 totalAmount;    // Total amount for vesting
        uint256 claimedAmount;  // Amount already claimed
        uint256 startTime;      // Start of vesting
        uint256 duration;       // Vesting duration (in seconds)
        address token;          // Token address (0x0 for ETH)
    }

    mapping(address => Vest) public vests;
    address public owner;

    event Vested(address indexed beneficiary, address token, uint256 amount, uint256 startTime, uint256 duration);
    event Claimed(address indexed beneficiary, address token, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Create vesting for ETH or tokens
    function vest(address beneficiary, uint256 amount, address token, uint256 duration) external payable onlyOwner {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(amount > 0, "Amount must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        require(vests[beneficiary].totalAmount == 0, "Vesting already exists for this beneficiary");

        if (token == address(0)) { // For ETH
            require(msg.value == amount, "Incorrect ETH amount sent");
        } else { // For ERC-20
            require(IERC20(token).transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        }

        vests[beneficiary] = Vest({
            totalAmount: amount,
            claimedAmount: 0,
            startTime: block.timestamp,
            duration: duration,
            token: token
        });

        emit Vested(beneficiary, token, amount, block.timestamp, duration);
    }

    // Claim available amount
    function claim() external {
        Vest storage vest = vests[msg.sender];
        require(vest.totalAmount > 0, "No vesting found");
        
        uint256 vestedAmount = calculateVestedAmount(msg.sender);
        uint256 claimable = vestedAmount - vest.claimedAmount;
        require(claimable > 0, "No claimable amount");

        vest.claimedAmount += claimable;

        if (vest.token == address(0)) { // ETH
            (bool success, ) = msg.sender.call{value: claimable}("");
            require(success, "ETH transfer failed");
        } else { // ERC-20
            require(IERC20(vest.token).transfer(msg.sender, claimable), "Token transfer failed");
        }

        emit Claimed(msg.sender, vest.token, claimable);
    }

    // Calculate vested amount based on time
    function calculateVestedAmount(address beneficiary) public view returns (uint256) {
        Vest storage vest = vests[beneficiary];
        if (vest.totalAmount == 0 || block.timestamp < vest.startTime) {
            return 0;
        }

        if (block.timestamp >= vest.startTime + vest.duration) {
            return vest.totalAmount;
        }

        return (vest.totalAmount * (block.timestamp - vest.startTime)) / vest.duration;
    }

    // Check vesting details
    function getVestingInfo(address beneficiary) external view returns (
        uint256 totalAmount,
        uint256 claimedAmount,
        uint256 startTime,
        uint256 duration,
        address token,
        uint256 claimable
    ) {
        Vest storage vest = vests[beneficiary];
        uint256 vested = calculateVestedAmount(beneficiary);
        return (
            vest.totalAmount,
            vest.claimedAmount,
            vest.startTime,
            vest.duration,
            vest.token,
            vested - vest.claimedAmount
        );
    }

    receive() external payable {}
}