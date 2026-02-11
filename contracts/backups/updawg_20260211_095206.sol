// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.2/contracts/access/Ownable.sol";

contract updawg is ERC20, Ownable {
    uint256 public maxWallet;
    address private constant DEAD = 0x000000000000000000000000000000000000dEaD;

    error MaxWalletExceeded();

    constructor(uint256 supply)
        ERC20("updawg", "DAWG")
        Ownable(msg.sender)
    {
        uint256 total = supply * 10 ** decimals();
        _mint(msg.sender, total);
        maxWallet = (total * 2) / 100; // 2% max wallet
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        if (from == address(0) || to == address(0) || from == owner() || to == owner() || to == DEAD) {
            super._update(from, to, value);
            return;
        }

        uint256 burnAmount = value / 100; // 1% burn
        uint256 sendAmount = value - burnAmount;

        if (to != owner() && to != DEAD) {
            if (balanceOf(to) + sendAmount > maxWallet) {
                revert MaxWalletExceeded();
            }
        }

        if (burnAmount > 0) {
            super._update(from, DEAD, burnAmount);
        }

        super._update(from, to, sendAmount);
    }
}
