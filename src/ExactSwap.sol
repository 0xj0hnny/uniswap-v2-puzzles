// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IERC20.sol";

contract ExactSwap {
    /**
     *  PERFORM AN SIMPLE SWAP WITHOUT ROUTER EXERCISE
     *
     *  The contract has an initial balance of 1 WETH.
     *  The challenge is to swap an exact amount of WETH for 1337 USDC token using the `swap` function
     *  from USDC/WETH pool.
     *
     */
    function performExactSwap(address pool, address weth, address usdc) public {
        /**
         *     swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data);
         *
         *     amount0Out: the amount of USDC to receive from swap.
         *     amount1Out: the amount of WETH to receive from swap.
         *     to: recipient address to receive the USDC tokens.
         *     data: leave it empty.
         */

        // your code start here
        uint256 exact0Out = 1337 * 10 ** 6;
        uint256 exact1Out = 0;

        (uint256 x, uint256 y, ) = IUniswapV2Pair(pool).getReserves();
        uint numerator = y * (exact0Out) * (1000);
        uint denominator = (x - exact0Out) * 997; // 3% fee
        uint amountInWallet = (numerator / denominator) + 1;

        IERC20(weth).transfer(pool,amountInWallet);
        IUniswapV2Pair(pool).swap(exact0Out, exact1Out, address(this), "");
    }
}
