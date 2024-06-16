// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract AddLiquid {
    /**
     *  ADD LIQUIDITY WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1000 USDC and 1 WETH.
     *  Mint a position (deposit liquidity) in the pool USDC/WETH to msg.sender.
     *  The challenge is to provide the same ratio as the pool then call the mint function in the pool contract.
     *
     */

    event UsdcAmount(uint256 amount);
    event UsdcBalance(uint256 balance);
    function addLiquidity(address usdc, address weth, address pool, uint256 usdcReserve, uint256 wethReserve) public {
        IUniswapV2Pair pair = IUniswapV2Pair(pool);

        // your code start here

        // see available functions here: https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol

        uint256 usdcAmount = IERC20(usdc).balanceOf(address(this));
        uint256 wethAmount = (usdcAmount * wethReserve) / usdcReserve;

        uint256 wethBalance = IERC20(weth).balanceOf(address(this));
        require(wethAmount <= wethBalance, "not enough token");

        IERC20(weth).approve(pool, wethAmount);
        IERC20(weth).transfer(pool, wethAmount);

        IERC20(usdc).approve(pool, usdcAmount);
        IERC20(usdc).transfer(pool, usdcAmount);

        pair.mint(address(this));        

        uint256 poolBalance = IERC20(pool).balanceOf(address(this));
        IERC20(pool).transfer(msg.sender, poolBalance);          
    }
}
