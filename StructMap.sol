pragma solidity^0.4.*;

/*This example deals with how to use a mapping inside a structure*/



contract StructMap {
    
    
    address Teacher;
    
    struct Student {
        
        
        uint rollNo;
        string name;
        
        mapping(uint=>uint) marksPerSubject;
        
    }
    
    mapping(address=>Student) allStudents;
    
    
    function StructMap(){
        Teacher = msg.sender;
    }
    
    modifier onlyTeacher() {
        require(msg.sender==Teacher);
        _;
    }
    
    function addStudentRecord(address studentAddress,uint _rollNo,string _name) onlyTeacher {
        
        Student memory std = Student(_rollNo,_name);
        
        allStudents[studentAddress] = std;
        
        allStudents[studentAddress].marksPerSubject[101] =99;
        
    }
    
    
    function getMarks(address studentAddress) view returns (uint) {
        return allStudents[studentAddress].marksPerSubject[101];
    }
    
}
