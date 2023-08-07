// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.12;

import {Ownable} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/Ownable.sol';
import {IERC20} from '@zerolendxyz/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol';

contract MockParaSwapTokenTransferProxy is Ownable {
  function transferFrom(
    address token,
    address from,
    address to,
    uint256 amount
  ) external onlyOwner {
    IERC20(token).transferFrom(from, to, amount);
  }
}
