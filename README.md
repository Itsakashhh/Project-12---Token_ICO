# TokenICO Smart Contract

This `TokenICO` smart contract facilitates the sale of ERC20 tokens through an Initial Coin Offering (ICO). It is designed to allow users to purchase tokens using Ether (ETH) while providing functionalities for the contract owner to manage the ICO effectively.

---

## Features

1. **Token Sale**
   - Buyers can purchase tokens by sending ETH to the contract.
   - The number of tokens received per ETH is determined by the `rate`.

2. **Cap on Sale**
   - The maximum number of tokens available for sale is defined by the `cap`.

3. **Time-Limited Sale**
   - The ICO has a start and end time, ensuring that tokens can only be purchased during the active sale period.

4. **Ownership Control**
   - Only the contract owner can manage critical functions, such as setting ICO times and withdrawing funds.

5. **Post-ICO Management**
   - The owner can withdraw the funds raised after the ICO concludes.
   - Remaining tokens can be accounted for using the `remainingTokens` function.

6. **Event Logging**
   - Key events, such as token purchases and ICO finalization, are emitted for easy tracking.

---

## Constructor

```solidity
constructor(IERC20 _token, uint256 _rate, uint256 _cap) Ownable(msg.sender)
```
- **Arguments:**
  - `_token`: Address of the ERC20 token to be sold.
  - `_rate`: Number of tokens per 1 ETH.
  - `_cap`: Total number of tokens available for sale.
- Initializes the ICO contract with the token address, rate, and cap.

---

## Functions

### `setICOTime(uint256 _startTime, uint256 _endTime)`
- **Description:**
  Sets or updates the start and end times of the ICO.
- **Modifiers:**
  - `onlyOwner`: Can only be called by the owner.
- **Conditions:**
  - `_startTime` must be in the future.
  - `_endTime` must be after `_startTime`.

### `buyTokens()`
- **Description:**
  Allows users to purchase tokens during the ICO period.
- **Modifiers:**
  - `onlyWhileOpen`: Ensures the ICO is active.
- **Logic:**
  - Calculates the number of tokens to buy based on the `rate`.
  - Ensures the purchase does not exceed the `cap`.
  - Transfers tokens from the contract to the buyer.
  - Emits a `TokensPurchased` event.

### `withdraw()`
- **Description:**
  Transfers the total ETH raised to the contract owner after the ICO ends.
- **Modifiers:**
  - `onlyOwner`
  - `onlyAfterICO`
- **Conditions:**
  - Contract must have a balance greater than zero.

### `finalizeICO()`
- **Description:**
  Emits a summary of the total ETH raised and tokens sold.
- **Modifiers:**
  - `onlyOwner`
  - `onlyAfterICO`

### `remainingTokens()`
- **Description:**
  Returns the number of tokens still available for sale.

### `isICOActive()`
- **Description:**
  Returns `true` if the ICO is currently active, based on the start and end times.

---

## Events

### `TokensPurchased`
- **Parameters:**
  - `buyer`: Address of the token buyer.
  - `amountPaid`: Amount of ETH sent.
  - `tokensBought`: Number of tokens purchased.

### `ICOFinalized`
- **Parameters:**
  - `totalRaised`: Total ETH raised during the ICO.
  - `totalSold`: Total tokens sold during the ICO.

### `ICOTimeSet`
- **Parameters:**
  - `newStartTime`: New start time of the ICO.
  - `newEndTime`: New end time of the ICO.

---

## Deployment
1. Deploy the ERC20 token contract (if not already deployed).
2. Deploy the `TokenICO` contract, passing the following arguments to the constructor:
   - Token contract address.
   - Rate (number of tokens per 1 ETH).
   - Cap (maximum number of tokens available for sale).
3. Use the `setICOTime` function to specify the start and end times for the ICO.

---

## Usage

1. **Setting Up the ICO**
   - Call `setICOTime` to define the sale period.

2. **Buying Tokens**
   - Send ETH to the `buyTokens` function during the active ICO period.

3. **Finalizing the ICO**
   - After the ICO ends, the owner can:
     - Call `withdraw` to collect the ETH raised.
     - Call `finalizeICO` to log the final sale stats.

---

## Example Workflow

1. Deploy the `TokenICO` contract with the desired parameters.
2. Set the start and end times for the ICO using `setICOTime`.
3. Buyers can purchase tokens during the ICO period using `buyTokens`.
4. After the ICO ends, the owner can withdraw funds and finalize the ICO.

---

## Notes
- Ensure the `TokenICO` contract has enough token allowance to facilitate transfers.
- Use a secure method to deploy the contract and set its parameters.
- Test the contract on a testnet before deploying to the mainnet.

---

## Contact
For any issues or suggestions, please create a pull request or open an issue in the repository.

Thank You
