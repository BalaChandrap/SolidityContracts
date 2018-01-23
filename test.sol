pragma solidity ^0.4.16;


contract test {
    
    
    //example for external functions;
    
    function testing(int x) external {
        
    }
    
    
    function testing2 (){
        
        this.testing(2);
        
    }
    
    
    
    
    
    
    
    //exmaple for getting same hash using different ways of representing an input in hash function
    
    
    function returnSHAValues() constant returns (bytes32,bytes32,bytes32,bytes32){
        
        
        
        return(sha3("ab","c"),sha3("abc"),sha256(97,98,99),keccak256(6382179));
        
    }
    
    
    
    
    
    
    
    
}


// Example for normal fallback functions
contract Test1 {
    function()  { x = 1; }
    uint x;
}

contract Caller1 {
    function callTest(address testAddress) {
        
        
        
        Test1(testAddress).call(0);
    // results in Test(testAddress).x becoming == 1.
    }
}




//Example for fall back functions payable.

contract Test {
    function() payable { x = 1; }
    
    uint x;
}

contract Caller {

    function callTest(address testAddress) {
        Test(testAddress).send(0);
    // results in Test(testAddress).x becoming == 1.
    }
}




contract interfaceTest {
    
    Test tst;
    
    
    
    function check(){
    
        address(tst); //Converting contract object to address;
        
        uint256 a;
        address nameReg = 0x72ba7d8e73fe8eb666ea66babc8116a41bfb10e2;
        nameReg.call("register", "MyName");
        nameReg.call(bytes4(sha3("fun(uint256)")), a);
        
        
    }
}






















