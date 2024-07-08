// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IERC20.sol";

/**
 *
 *  ARBITRAGE A POOL
 *
 * Given two pools where the token pair represents the same underlying; WETH/USDC and WETH/USDT (the formal has the corect price, while the latter doesnt).
 * The challenge is to flash borrowing some USDC (>1000) from `flashLenderPool` to arbitrage the pool(s), then make profit by ensuring MyMevBot contract's USDC balance
 * is more than 0.
 *
 */
contract MyMevBot {
    address public immutable flashLenderPool;
    address public immutable weth;
    address public immutable usdc;
    address public immutable usdt;
    address public immutable router;
    bool public flashLoaned;

    constructor(address _flashLenderPool, address _weth, address _usdc, address _usdt, address _router) {
        flashLenderPool = _flashLenderPool;
        weth = _weth;
        usdc = _usdc;
        usdt = _usdt;
        router = _router;
    }

    function performArbitrage() public {
        // your code here
        uint256 flashBorrowAmount0 = 2000 * 1e6;
        uint256 flashBorrowAmount1 = 0;

        // flas borrow USDC
        IUniswapV3Pool(flashLenderPool).flash(
            address(this), 
            flashBorrowAmount0, 
            flashBorrowAmount1, 
            abi.encode(flashBorrowAmount0, flashBorrowAmount1)
        );
    }

    function uniswapV3FlashCallback(uint256 _fee0, uint256, bytes calldata data) external {
        callMeCallMe();

        // your code start here
        (uint256 amount0, ) = abi.decode(data, (uint256, uint256));
        uint256 totalDebt = amount0 + _fee0;
        address[] memory paths1 = new address[](2);
        paths1[0] = usdc;
        paths1[1] = weth;

        // swap USDC => USDT
        IERC20(usdc).approve(router, amount0);
        uint256[] memory amountsOut1 = IUniswapV2Router(router).swapExactTokensForTokens(amount0, 0, paths1, address(this), block.timestamp + 20);

        address[] memory paths2 = new address[](2);
        paths2[0] = weth;
        paths2[1] = usdt;

        // swap WETH => USDT
        IERC20(weth).approve(router, amountsOut1[1]);
        uint256[] memory amountsOut2 = IUniswapV2Router(router).swapExactTokensForTokens(amountsOut1[1], 0, paths2, address(this), block.timestamp + 20);

        address[] memory paths3 = new address[](2);
        paths3[0] = usdt;
        paths3[1] = usdc;

        // swap USDT => USDC
        IERC20(usdt).approve(router, amountsOut2[1]);
        uint256[] memory amountsOut3 = IUniswapV2Router(router).swapExactTokensForTokens(amountsOut2[1], 0, paths3, address(this), block.timestamp + 20);

        // Check profit
        require(amountsOut3[1] > totalDebt, "No profit");

        // Repay flash loan
        IERC20(usdc).transfer(flashLenderPool, totalDebt);

        // Profit is the remaining USDC balance
        require(IERC20(usdc).balanceOf(address(this)) > 0, "No profit left");
    }

    function callMeCallMe() private {
        uint256 usdcBal = IERC20(usdc).balanceOf(address(this));
        require(msg.sender == address(flashLenderPool), "not callback");
        require(flashLoaned = usdcBal >= 1000 * 1e6, "FlashLoan less than 1,000 USDC.");
    }
}

interface IUniswapV3Pool {
    /**
     * recipient: the address which will receive the token0 and/or token1 amounts.
     * amount0: the amount of token0 to send.
     * amount1: the amount of token1 to send.
     * data: any data to be passed through to the callback.
     */
    function flash(address recipient, uint256 amount0, uint256 amount1, bytes calldata data) external;
}

interface IUniswapV2Router {
    /**
     *     amountIn: the amount to use for swap.
     *     amountOutMin: the minimum amount of output tokens that must be received for the transaction not to revert.
     *     path: an array of token addresses. In our case, WETH and USDC.
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
