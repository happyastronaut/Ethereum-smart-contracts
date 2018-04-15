pragma solidity ^0.4.18;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a); 
    return a - b; 
  } 
  
  function add(uint256 a, uint256 b) internal pure returns (uint256) { 
    uint256 c = a + b; assert(c >= a);
    return c;
  }
}

contract ERC20 {
      uint256 public totalSupply;
      function balanceOf(address who) public constant returns (uint256);
      function transfer(address to, uint256 value) public returns (bool);
      function transferFrom(address from, address to, uint256 value) public returns (bool);
      function allowance(address owner, address spender) public constant returns (uint256);
      function approve(address spender, uint256 value) public returns (bool);
      event Transfer(address indexed from, address indexed to, uint256 value);
      event Approval(address indexed owner, address indexed spender, uint256 value);
  
}

contract ERC20Token is ERC20{
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    function balanceOf(address _owner) public constant returns (uint256 balance) { 
        return balances[_owner]; 
    } 
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]); 
        balances[msg.sender] = balances[msg.sender].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        Transfer(msg.sender, _to, _value); 
        return true; 
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]); 
        balances[_from] = balances[_from].sub(_value); 
        balances[_to] = balances[_to].add(_value); 
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); 
        Transfer(_from, _to, _value); 
        return true; 
        
    }
  
    function approve(address _spender, uint256 _value) public returns (bool) { 
        allowed[msg.sender][_spender] = _value; 
        Approval(msg.sender, _spender, _value); 
        return true; 
        
    }
  
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { 
        return allowed[_owner][_spender]; 
        
    }
}

contract TrashToken is ERC20Token{
    address owner = msg.sender;
    string public constant name = "TrashToken";
    string public constant symbol = "TRSH";
    uint32 public constant decimals = 18;
    
    uint256 public totalSupply = 0;
}

contract Crowdsale is TrashToken{
    bool public purchasingAllowed = false;
    uint256 public totalContribution = 0;
    
    function enablePurchasing() public {
        require(msg.sender == owner);
        purchasingAllowed = true;
    }

    function disablePurchasing() public {
        require(msg.sender == owner);
        purchasingAllowed = false;
    }
    
    function mint(address to, uint256 amount) internal returns (bool) {
        totalSupply = totalSupply.add(amount);
        balances[to] = balances[to].add(amount);
        Mint(to, amount);
        return true;
    }
    
    function() public payable{
        require(purchasingAllowed);
        require(msg.value > 0);

        owner.transfer(msg.value);
        totalContribution = totalContribution.add(msg.value);
        
        mint(msg.sender, msg.value);
    }
    
    event Mint(address indexed to, uint256 amount);
}