pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DEX {
    IERC20 public associatedToken;

    uint price;
    address owner;

    constructor(IERC20 _token, uint _price){
        associatedToken = _token;
        owner = msg.sender;
        price = _price;
    }
    modifier onlyOwner {
        require(msg.sender == owner, " you are not the owner");
        _;
    }

    function sell() external onlyOwner {
        uint allowance = associatedToken.allowance(msg.sender, address(this));
        require(allowance > 0, "you must allow this address atleast one token");
        bool sent = associatedToken.transferFrom(msg.sender,address(this), allowance);
        require(sent, "failed to send");
    }

    function withdrawTokens() external onlyOwner {
        uint256 balance = associatedToken.balanceOf(address(this));
        associatedToken.transfer(msg.sender, balance);
    }

    function withdrawFunds() external onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance} (
            ""
        );
        require(sent);
    }

    function getPrice(uint numTokens) public view returns (uint) {
        return numTokens * price;
    }

    function buy (uint numTokens) external payable {
        require(numTokens <= getTokenBalance(), "not enough tokens");
        uint256 priceForTokens = getPrice(numTokens);
        require(msg.value == priceForTokens,"Invalid value sent");

        associatedToken.transfer(msg.sender, numTokens);
    }

    function getTokenBalance() public view returns(uint256) {
        return associatedToken.balanceOf(address(this));
    }
}