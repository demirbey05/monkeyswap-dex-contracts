// SPDX-License-Identifier
pragma solidity 0.8.17;

import "./interfaces/IExchange.sol";
import "./interfaces/IERC20.sol";
import {ERC20} from "solmate/src/tokens/ERC20.sol";
import "./libraries/Math.sol";

contract Exchange is IExchange, ERC20 {
    uint112 private reserve0;
    uint112 private reserve1;

    address public token0;
    address public token1;

    constructor(address _token0, address _token1) ERC20("KomToken", "KOM", 18) {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function mint(address to) internal returns (uint liquidity) {
        (uint112 reserve0, uint112 reserve1) = getReserves();
        uint balance1 = IERC20(token0).balanceOf(address(this));
        uint balance2 = IERC20(token1).balanceOf(address(this));

        uint amount1 = balance1 - reserve0;
        uint amount2 = balance2 - reserve1;

        uint _totalSupply = totalSupply;

        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount1 * amount2);
        } else {
            liquidity = Math.min(
                (amount1 * _totalSupply) / reserve0,
                (amount2 * _totalSupply) / reserve1
            );
        }

        if (liquidity <= 0) revert InsufficientLiquidity(liquidity);

        _mint(to, liquidity);
        reserve0 = uint112(balance1);
        reserve1 = uint112(balance2);
        return liquidity;
    }

    function addLiquidity(uint amount1, uint amount2) public {
        IERC20(token0).transferFrom(msg.sender, address(this), amount1);
        IERC20(token1).transferFrom(msg.sender, address(this), amount2);
        uint liquidity = mint(msg.sender);
    }

    function removeLiquidity(uint liquidity) public {
        burn(msg.sender, liquidity);
    }

    function burn(address to, uint amount) internal {
        uint balance1 = IERC20(token0).balanceOf(address(this));
        uint balance2 = IERC20(token1).balanceOf(address(this));

        uint amount1 = (amount * balance1) / totalSupply;
        uint amount2 = (amount * balance2) / totalSupply;

        _burn(msg.sender, amount);
        IERC20(token0).transfer(to, amount1);
        IERC20(token1).transfer(to, amount2);
        balance1 = IERC20(token0).balanceOf(address(this));
        balance2 = IERC20(token1).balanceOf(address(this));

        reserve0 = uint112(balance1);
        reserve1 = uint112(balance2);
    }

    function swap1(uint amount) public {
        uint k = reserve0 * reserve1;
        IERC20(token0).transferFrom(msg.sender, address(this), amount);
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint required = k / balance0;
        uint amount1 = balance1 - required;
        IERC20(token1).transfer(msg.sender, amount1);
    }

    function swap2(uint amount) public {
        uint k = reserve0 * reserve1;
        IERC20(token1).transferFrom(msg.sender, address(this), amount);
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));

        uint required = k / balance1;
        uint amount1 = balance0 - required;
        IERC20(token1).transfer(msg.sender, amount1);
    }
}
