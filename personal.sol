pragma solidity ^0.4.16;


/* small exercise on how to use smart contract to share your personal details. */

contract MYDetails {
    
    address admin;
    
    
    
    struct PersonalDetails {
        string name;
        uint age;
    }
    
    PersonalDetails myDetails;
    
    
    mapping (address =>bool) requestSent;
    
    mapping (address =>bool) requestStatus;
    
    
    function MYDetails() public{
        admin = msg.sender;
    }
    
    modifier onlyAdmin(){
        if(msg.sender!=admin)
        revert();
        _;
    }
    
    function addDetails(string name,uint age) onlyAdmin public {
        
        myDetails.name = name;
        myDetails.age = age;
        
    }  
    
    
    function requestDetails() public {
        
        requestSent[msg.sender] = true;
    }
    
    function acceptRequest (address requestorAddress) onlyAdmin public {
        
        requestStatus[requestorAddress] = true;
    }
    
    function getDetails() constant public returns (string,uint) 
    {
        if(requestStatus[msg.sender]==false || msg.sender!=admin){
            revert();
        }
        
        return(myDetails.name,myDetails.age);
    
    
    }
    
}
