pragma solidity ^0.4.0;



contract SimpleStorage {
    uint storedData;

    
    struct Sample {
        uint x;
        string name;
    }
    
    
    mapping(address => Sample[]) mapValues;
    
    function set() public {
        
        
        
        Sample memory temp = Sample(5,"bala");
        
        mapValues[msg.sender].push(temp);
        
        
        
        
    }

    function get() public constant returns (uint) {
        
    
        Sample memory temp = mapValues[msg.sender][0];    

        
        return temp.x;
    }
}


