// SPDX-License-Identifier
pragma solidity 0.8.17;

interface IExchange {
    error InsufficientLiquidity(uint256 amount);

    function getReserves() external view returns (uint112, uint112);
    // Token to Token Transfer

    // Add Liquidity

    // Remove Liquidity
}
