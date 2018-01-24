pragma solidity ^0.4.0;

/*sample contract on how to create a struct, access it and method examples */

contract SimpleStorage {
    uint storedData;
    
    address admin;
    bytes byt;
    string str;
    
    struct class {
        uint number;
        uint time;
        string name;
    }
    
    class  class2;
    event someEvent(address senderAddress,address normalAddress,bytes sentBytes,string strData);
    

    function set(uint x) public {
        storedData = x;
        class storage class1;
        var obj =1;
    }

    function get() public view returns (uint) {
        storedData =1;
        
        return storedData;
    }
    
    function getVlaue() public constant returns (uint) {
        return storedData;
    }
    
    
    function newMehtod() {
        
    }
    function setPayment(uint x) public payable {
        
        msg.value;
        
        msg.sender.transfer(1 ether);
        
    
        
        msg.sender;
        storedData = x;
    }
    
    function some(address addr,bytes _byt,string _str) 
    {
        admin = addr;
        byt = _byt;
        str = _str;
        
        someEvent(msg.sender,addr,_byt,_str);
        
        
    }
    
    
    function getHash() constant returns (bytes){
        return byt;
    }
    
    
    
}


