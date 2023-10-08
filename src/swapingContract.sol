// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {WETHInterface} from "./IWeth.sol"; 

contract StakingContract is Ownable(msg.sender) {
    using SafeERC20 for IERC20;

    IERC20 public ekohmoneyToken; 
    IERC20 public receiptToken; 
    WETHInterface public weth; 

    uint256 public annualYieldPercentage = 14; 
    uint256 public stakingDuration = 365 days; 

    struct Stake {
        uint256 initialAmount; 
        uint256 stakingTime; 
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 initialAmount);
    event YieldClaimed(address indexed user, uint256 yieldAmount);

    constructor(
        address _ekohmoneyToken,
        address _receiptToken,
        address _weth
    ) {
        ekohmoneyToken = IERC20(_ekohmoneyToken);
        receiptToken = IERC20(_receiptToken);
        weth = WETHInterface(_weth);
    }

    //  (converts to WETH) 
    function stake() external payable {
        require(msg.value > 0, "Must stake some ETH");
        uint256 wethAmount = _convertToWETH(msg.value);
        stakes[msg.sender] = Stake(wethAmount, block.timestamp);
        receiptToken.transfer(msg.sender, wethAmount); 
        emit Staked(msg.sender, wethAmount);
    }

   
    function claimYield() external {
        Stake storage userStake = stakes[msg.sender];
         require(userStake.initialAmount > 0, "No stake to claim yield from");
        require(block.timestamp >= userStake.stakingTime + stakingDuration, "Staking duration not reached");
        uint256 yieldAmount = _calculateYield(userStake.initialAmount);
        require(yieldAmount > 0, "No yield to claim");
        ekohmoneyToken.transfer(msg.sender, yieldAmount);
        emit YieldClaimed(msg.sender, yieldAmount);
    }

    function _convertToWETH(uint256 ethAmount) internal returns (uint256) {
        weth.deposit{value: ethAmount}();
        return weth.balanceOf(address(this));
    }

    function _calculateYield(uint256 amount) internal view returns (uint256) {
        uint256 annualYield = (amount * annualYieldPercentage) / 100;
        return (annualYield * stakingDuration) / (365 days);
    }
}
