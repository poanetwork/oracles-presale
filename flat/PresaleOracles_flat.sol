pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract PresaleOracles is Ownable {
/*
 * PresaleOracles
 * Simple Presale contract
 * built by github.com/rstormsf Roman Storm
 */
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public cap;
    uint256 public rate;
    uint256 public totalInvestedInWei;
    uint256 public minimumContribution;
    mapping(address => uint256) public investorBalances;
    address public vault;
    bool public isInitialized = false;
    // TESTED by Roman Storm
    function () public payable {
        buy();
    }
    //TESTED by Roman Storm
    function Presale() public {
    }
    //TESTED by Roman Storm
    function initialize(uint256 _startTime, uint256 _endTime, uint256 _cap, uint256 _minimumContribution, address _vault) public onlyOwner {
        require(!isInitialized);
        require(_startTime != 0);
        require(_endTime != 0);
        require(_endTime > _startTime);
        require(_cap != 0);
        require(_minimumContribution != 0);
        require(_vault != 0x0);
        require(_cap > _minimumContribution);
        startTime = _startTime;
        endTime = _endTime;
        cap = _cap;
        isInitialized = true;
        minimumContribution = _minimumContribution;
        vault = _vault;
    }
    //TESTED by Roman Storm
    function buy() public payable {
        require(isValidPurchase(msg.value));
        require(isInitialized);
        require(getTime() >= startTime && getTime() <= endTime);
        address investor = msg.sender;
        investorBalances[investor] += msg.value;
        totalInvestedInWei += msg.value;
        forwardFunds(msg.value);
    }
    
    //TESTED by Roman Storm
    function forwardFunds(uint256 _amount) internal {
        vault.transfer(_amount);
    }
    //TESTED by Roman Storm
    function claimTokens(address _token) public onlyOwner {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
    
        BasicToken token = BasicToken(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(owner, balance);
    }

    function getTime() internal view returns(uint256) {
        return now;
    }
    //TESTED by Roman Storm
    function isValidPurchase(uint256 _amount) public view returns(bool) {
        bool nonZero = _amount > 0;
        bool hasMinimumAmount = investorBalances[msg.sender].add(_amount) >= minimumContribution;
        bool withinCap = totalInvestedInWei.add(_amount) <= cap;
        return hasMinimumAmount && withinCap && nonZero;
    }
}

