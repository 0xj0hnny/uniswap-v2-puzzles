// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

contract MultiHop {
    /**
     *  PERFORM A MULTI-HOP SWAP WITH ROUTER EXERCISE
     *
     *  The contract has an initial balance of 10 MKR.
     *  The challenge is to swap the contract entire MKR balance for ELON token, using WETH as the middleware token.
     *
     */
    address public immutable router;

    constructor(address _router) {
        router = _router;
    }

    function performMultiHopWithRouter(address mkr, address weth, address elon, uint256 deadline) public {
        // your code start here
        uint256 mkrBalance = IERC20(mkr).balanceOf((address(this)));

        address[] memory paths1 = new address[](2);
        paths1[0] = mkr;
        paths1[1] = weth;

        IERC20(mkr).approve(address(router), mkrBalance);
        uint256[] memory amountsOut1 = IUniswapV2Router(router).swapExactTokensForTokens(mkrBalance, 0, paths1, address(this), deadline);

        address[] memory paths2 = new address[](2);
        paths2[0] = weth;
        paths2[1] = elon;

        IERC20(weth).approve(router, amountsOut1[1]);
        IUniswapV2Router(router).swapExactTokensForTokens(amountsOut1[1], 0, paths2, address(this), deadline);
    }
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount of input tokens to swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses.
     *     to: recipient address to receive the liquidity tokens.
     *     deadline: timestamp after which the transaction will revert.
     */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
