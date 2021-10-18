// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../interfaces/SafeMath.sol";
import "../interfaces/IERC20.sol";
import "../interfaces/IBooster.sol";
import "../interfaces/IRewards.sol";
import "../interfaces/ISushiSwapRouter.sol";


contract HarvestConvexMIM {
  using SafeMath for uint256;

  address public constant convexDepositor = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
  uint256 public constant poolId = 40; // Curve MIM - 3CRV pool
  address public constant rewardPool = address(0xFd5AbF66b003881b88567EB9Ed9c651F14Dc4771); // CRV emission rewards
  address public constant sushiSwapRouter = address(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F);

  address public constant mim3Crv = address(0x5a6A4D54456819380173272A5E8E9B9904BdF41B);
  address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
  address public constant spell = address(0x090185f2135308BaD17527004364eBcC2D37e5F6);
  address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
  address public constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  address public constant dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);

  address private owner;


  constructor() public { 
    owner = msg.sender;
  }

  
  modifier onlyAdmin {
    require(msg.sender == owner);
    _;
  }


  function deposit() external {
    uint256 balance = IERC20(mim3Crv).balanceOf(msg.sender);
    IERC20(mim3Crv).transferFrom(msg.sender, address(this), balance);
    uint256 allowance = IERC20(mim3Crv).allowance(address(this), convexDepositor);
    if (allowance < balance) {
      IERC20(mim3Crv).approve(convexDepositor, balance);
    }
    IBooster(convexDepositor).depositAll(poolId, true);
  }


  function deposit(uint256 _amount) external {
    IERC20(mim3Crv).transferFrom(msg.sender, address(this), _amount);
    uint256 allowance = IERC20(mim3Crv).allowance(address(this), convexDepositor);
    if (allowance < _amount) {
      IERC20(mim3Crv).approve(convexDepositor, _amount);
    }
    IBooster(convexDepositor).depositAll(poolId, true);
  }


  function sellToken(address _erc20) internal {
    uint256 _amount = IERC20(_erc20).balanceOf(address(this));

    // check allowance
    uint256 allowance = IERC20(_erc20).allowance(address(this), sushiSwapRouter);
    if (allowance < _amount) {
      IERC20(_erc20).approve(sushiSwapRouter, _amount);
    }
    address[] memory path = new address[](3);
    path[0] = _erc20;
    path[1] = weth;
    path[2] = dai;
    ISushiSwapRouter(sushiSwapRouter).swapExactTokensForTokens(
      _amount, 
      1, 
      path,
      address(this), 
      32528645726);
    uint256 balance = IERC20(dai).balanceOf(address(this));
    IERC20(dai).transfer(owner, balance);
  }


  function getRewardAndConvert() external {
    // claim all rewards
    IRewards(rewardPool).getReward();

    // sell tokens
    sellToken(cvx);
    sellToken(spell);
    sellToken(crv);
  }


  function getReward() external onlyAdmin {
    // claim all rewards
    IRewards(rewardPool).getReward();
  }

 
  function withdraw() external {
    uint256 amount = IRewards(rewardPool).balanceOf(address(this));
    IRewards(rewardPool).withdrawAndUnwrap(amount, false);
    uint256 balance = IERC20(mim3Crv).balanceOf(address(this));
    IERC20(mim3Crv).transfer(owner, balance);
  }


  function withdraw(address _erc20) external {
    uint256 balance = IERC20(_erc20).balanceOf(address(this));
    IERC20(_erc20).transfer(owner, balance);
  }
}