// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ElevenToken } from "./Token.s.sol";
import { SafeMath } from "../lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";
import { Ownable } from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TokenICO is Ownable {
    using SafeMath for uint256;

    ElevenToken public token;
    uint256 public rate;  // Number of tokens per ETH
    uint256 public cap;  // Maximum number of tokens available for sale
    uint256 public totalRaised;  // Total ETH raised
    uint256 public totalSold;  // Total tokens sold
    uint256 public startTime;
    uint256 public endTime;
    uint256 public tokensToBuy;

    event TokensPurchased(address indexed buyer, uint256 amountPaid, uint256 tokensBought);
    event ICOFinalized(uint256 totalRaised, uint256 totalSold);
    event ICOTimeSet(uint256 newStartTime, uint256 newEndTime);

    constructor(ElevenToken _token, uint256 _rate, uint256 _cap) Ownable(msg.sender) {
        require(address(_token) != address(0), "Token address is zero");
        require(_rate > 0, "Rate must be greater than 0");
        require(_cap > 0, "Cap must be greater than 0");

        token = _token;
        rate = _rate;
        cap = _cap;
    }

    // Modifier to check if the ICO is active
    modifier onlyWhileOpen() {
        require(startTime > 0 && endTime > 0, "ICO time not set");
        require(block.timestamp >= startTime && block.timestamp <= endTime, "ICO is not active");
        _;
    }

    // Modifier to check if the ICO is finalized
    modifier onlyAfterICO() {
        require(endTime > 0, "ICO time not set");
        require(block.timestamp > endTime, "ICO has not ended yet");
        _;
    }

    // Function to set or update the start and end times
    function setICOTime(uint256 _startTime, uint256 _endTime, uint256 _tokenAmount) external onlyOwner {
        require(_startTime >= block.timestamp, "Start time must be in the future");
        require(_endTime > _startTime, "End time must be after start time");
        require(token.balanceOf(msg.sender) >= _tokenAmount, "Insufficient token balance for transfer");

        startTime = _startTime;
        endTime = _endTime;

        // Transfer tokens to the ICO contract
        token.transferFrom(msg.sender, address(this), _tokenAmount);
        cap = cap.add(_tokenAmount);

        emit ICOTimeSet(_startTime, _endTime);
    }

    // Function to buy tokens
    function buyTokens() external payable onlyWhileOpen {
        uint256 weiAmount = msg.value;
        require(weiAmount > 0, "You must send ETH to buy tokens");

        tokensToBuy = weiAmount.div(rate);
        require(totalSold.add(tokensToBuy) <= cap, "Not enough tokens left in the ICO");

        // Update the raised funds, total tokens sold and cap
        totalRaised = totalRaised.add(weiAmount);
        totalSold = totalSold.add(tokensToBuy);
        cap = cap.sub(tokensToBuy);

        // Transfer the tokens to the buyer
        token.transfer(msg.sender, tokensToBuy);

        emit TokensPurchased(msg.sender, weiAmount, tokensToBuy);
    }

    // Function to withdraw the raised ETH after ICO ends
    function withdraw() external onlyOwner onlyAfterICO {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner()).transfer(balance);
    }

    // Finalize ICO and stop the sale
    function finalizeICO() external onlyOwner onlyAfterICO {
        emit ICOFinalized(totalRaised, totalSold);
    }

    // Function to check the contract's balance of tokens
    function remainingTokens() external view returns (uint256) {
        return cap.sub(totalSold);
    }

    // Function to check if the ICO has ended
    function isICOActive() external view returns (bool) {
        return startTime > 0 && endTime > 0 && block.timestamp >= startTime && block.timestamp <= endTime;
    }
}
