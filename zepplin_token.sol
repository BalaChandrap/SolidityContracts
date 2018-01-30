pragma solidity ^0.4.13;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';


/*
    This is another token contract example making use of Open-zepplin.
*/


contract BalaToken is MintableToken {
    using SafeMath for uint256;

    string public name = "Bala Token";
    string public symbol = "BALA";
    uint256 public decimals = 18;
    uint256 public max = (10**8)*(10**18);
    
    function mint(address _to, uint256 _amount) public returns (bool) {
        require(totalSupply.add(_amount) <= max);
        return MintableToken.mint(_to, _amount);
    }
}
