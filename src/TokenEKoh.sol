// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EkohMoney is ERC20 {
    constructor() ERC20("EkohMoney", "EM") {
        _mint(address(this), 1_000e8);
    }
}