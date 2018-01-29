pragma solidity ^0.4.18;


/*
    This is a sample token and ICO contract. Which I have created by going through several other ICO contracts.
    
*/

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;
  
  uint256 a; uint256 b;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    
    SafeMath.add(a,b);
    a.add(b);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract BalaToken is BasicToken {

  string public constant name = "BalaCoin";
  string public constant symbol = "BALA";
  uint8 public constant decimals = 18;

  uint256 public constant INITIAL_SUPPLY = 45000000 * (10 ** uint256(decimals));

  function BalaToken() public{
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }

  function() public{
    throw;
  }
}



contract ICO is Ownable{
  using SafeMath for uint256;

  // The token being sold
  BalaToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime; //will be hardcode when final deployment
  uint256 public endTime; //will be hardcode when final deployment
  uint256 public preICOendTime = 1516060799;
  uint256 public ICOstartTime = 1516406400;

  // address where funds are collected
  address public wallet; //will be hardcode when final deployment

  // how many token units a buyer gets per wei
  uint256 public rate; //will be hardcode when final deployment

  // amount of raised money in wei
  uint256 public weiRaised;
  address public owner;

  uint8 bountyPreico = 3;
  uint8 bountyIco = 5;
  uint8 discountPreico = 15;
  uint8 discountIco = 1;
  mapping (address => bool) public validKyc;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function CSiPRONTO(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public{
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;

    token = createTokenContract();

  }
  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (BalaToken) {
    return new BalaToken();
  }
  // Token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase(msg.value));

    uint256 weiAmount = msg.value;
    uint256 tokens = weiAmount.mul(rate);
    weiRaised = weiRaised.add(weiAmount);
    tokens = bountyExecute(tokens);

    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // Token transfer function
  function transferTokens(address beneficiary, uint256 weiAmount) onlyOwner public {
    require(beneficiary != address(0));
    require(validPurchase(weiAmount));

    uint256 tokens = weiAmount.mul(rate);
    weiRaised = weiRaised.add(weiAmount);
    tokens = bountyExecute(tokens);

    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
  }


  // @return true if the transaction can buy tokens
  function validPurchase(uint256 weiAmount) internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = weiAmount != 0;
    bool isBetweenIcos = isPreico() || isIco();
    return withinPeriod && nonZeroPurchase && isBetweenIcos;
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender);
  }

  function bountyExecute(uint256 tokens) internal constant returns (uint256){
    if (isPreico()) {
      // calculate and add bountyPreico percentage token to the transfer tokens
      tokens = tokens + tokens.mul(bountyPreico).div(100);
    }
    if (isIco()) {
      // calculate and add bountyIco percentage token to the transfer tokens
      tokens = tokens + tokens.mul(bountyPreico).div(100);
    }
    return tokens;
  }

  function discountPrice() internal constant returns (uint256 price){
    if (isPreico()) {
      price = rate.mul(discountPreico).div(100);
    }
    if (isIco()) {
      price = rate.mul(discountIco).div(100);
    }
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function isPreico() internal constant returns (bool){
    return now >= startTime && now <= preICOendTime;
  }

  function isIco() internal constant returns (bool){
    return now >= ICOstartTime && now <= endTime;
  }

  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }

  function approveKyc(address _addr) onlyOwner public{
      validKyc[_addr] = true;
  }

  function isValidKyc(address _addr) internal constant returns (bool){
     return !validKyc[_addr];
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return token.balanceOf(_owner);
  }
}

