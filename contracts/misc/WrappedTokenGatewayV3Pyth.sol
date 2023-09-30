// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.12;

import {IPool, WrappedTokenGatewayV3} from './WrappedTokenGatewayV3.sol';
import {IPyth} from '@pythnetwork/pyth-sdk-solidity/IPyth.sol';

/**
 * @dev This contract is an upgrade of the WrappedTokenGatewayV3 contract, with a pyth pricefeed
 * updater
 */
contract WrappedTokenGatewayV3Pyth is WrappedTokenGatewayV3 {
  IPyth internal immutable PYTH;

  /// @dev When was the pricfeeds last updated
  uint256 public lastUpdatedAt;

  /**
   * @dev Sets the WETH address and the PoolAddressesProvider address. Infinite approves pool.
   * @param weth Address of the Wrapped Ether contract
   * @param owner Address of the owner of this contract
   **/
  constructor(
    address weth,
    address owner,
    IPool pool,
    IPyth pyth
  ) WrappedTokenGatewayV3(weth, owner, pool) {
    PYTH = pyth;
  }

  /**
   * @dev deposits WETH into the reserve, using native ETH. A corresponding amount of the overlying asset (aTokens)
   * is minted.
   * @param onBehalfOf address of the user who will receive the aTokens representing the deposit
   * @param referralCode integrators are assigned a referral code and can potentially receive rewards.
   * @param pythPriceUpdateData pyth pricefeed data
   **/
  function depositETH(
    address,
    address onBehalfOf,
    uint16 referralCode,
    bytes[] calldata pythPriceUpdateData
  ) external payable {
    WETH.deposit{value: msg.value}();
    POOL.deposit(address(WETH), msg.value, onBehalfOf, referralCode);

    // Update the prices to the latest available values and pay the required fee for it. The `priceUpdateData` data
    // should be retrieved from our off-chain Price Service API using the `pyth-evm-js` package.
    // See section "How Pyth Works on EVM Chains" below for more information.
    uint fee = PYTH.getUpdateFee(pythPriceUpdateData);
    if (address(this).balance > fee && lastUpdatedAt + 3600 < block.timestamp) {
      PYTH.updatePriceFeeds{value: fee}(pythPriceUpdateData);
      lastUpdatedAt = block.timestamp;
    }
  }

  receive() external payable override {
    // accept ETH to pay for the PYTH updates
  }
}
