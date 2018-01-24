
pragma solidity ^0.4.*;

//normal library example



library Counter_Lib {
    
    
    
    
    struct Counter { 
        uint i;
        
        
    }

    function incremented(Counter storage self) returns (uint) {
        return ++self.i;
    }
}



contract CounterContract {
    using Counter_Lib for Counter_Lib.Counter;

    Counter_Lib.Counter counter;

    function increment() returns (uint) {
        return counter.incremented();
    }
}



//using for example

library EventEmitterLib {
    function emit(string s) {
        Emit(s);
    }
    
   event Emit(string s);
}

contract EventEmitterContract {
    using EventEmitterLib for string;
    
    function emit(string s) {
        s.emit();
       
    }
    
    event Emit(string s);
}

