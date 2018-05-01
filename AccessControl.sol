pragma solidity 0.4.23;
import "browser/library.sol";


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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract Test is Ownable  {
    
    
    address accessAddress;
    
    uint x;
    
    using SafeMath for uint;

    
    modifier onlyAccess {
        
        require(msg.sender==accessAddress);
        _;
    }
    
    
    function setAccessContract(address _contractAddress) public onlyOwner {
        accessAddress = _contractAddress;
    }
    
    function getAccessAddress() view public returns (address) {
        return accessAddress;
    }
    
    
    function  setValue(uint a) public onlyAccess {
        x= x.add(a);   //same as SafeMath.add(x,a);
    } 
    
    
    function getValue() view public returns (uint) {
        return x;
    }
    
    
    
}




contract Test2 {
    
    
    Test temp;
    
    
    function setAddress(address _contractAddress) public {
        
        temp = Test(_contractAddress);
    }
    
    function callNew() public {
        temp.setValue(3);
    }
    
}
