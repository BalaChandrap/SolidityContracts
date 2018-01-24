pragma solidity ^0.4.16;


/*Example of how we can use get and set methods for public variables directly */

contract C1 {
    
    
    
    struct srt{
        uint value;
    }
    
    
    mapping(address => srt) public valueMapping;
    
    
    function setValue(uint x){
        valueMapping[msg.sender].value = x;
    }
}


contract C2 {
    
     struct srt{
        uint value;
    }
    
    srt obj;
    
    C1 c1;
    
    function setAddress(address contractAddress){
        c1 = C1(contractAddress);
    }
    
    function getValue() returns (uint){
        
      //  c1.valueMapping[msg.sender].value;
        
        
    }
    
    
}
