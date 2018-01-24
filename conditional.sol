pragma solidity^0.4.*;


/*This contract is an example showing how we can different conditional and error functions like revert(),assert(),throw(),revert()*/


contract ConditionalTest {
    
    
    address admin;
    
    uint importantVlaue;
    
    
    function ConditionalTest() public{
        admin = msg.sender;
    }
    
    
    function changeVlaueAsAdminUsingThrow(uint newValue) public{
        
        if(msg.sender!=admin){
            throw;
        }
        
        importantVlaue = newValue;
        
        
    }
    
    
    function changeVlaueAsAdminUsingRevert(uint newValue) public{
        
        if(msg.sender!=admin){
            revert();
        }
        
        importantVlaue = newValue;
        
        
    }
    
    
    function changeVlaueAsAdminUsingAssert(uint newValue) public{
        
        assert(msg.sender==admin);
        
        importantVlaue = newValue;
        
        
    }
    
    
    function changeVlaueAsAdminUsingRequire(uint newValue) public{
        
        require(msg.sender==admin);
        
        importantVlaue = newValue;
        
        
    }
    
    
    
    
}



