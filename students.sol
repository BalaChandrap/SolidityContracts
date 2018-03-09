pragma solidity ^0.4.0;


contract Students {
    
    
    enum Results {Passed, Failed}
    
    
    struct Student {
        
        uint    rollNumber;
        bytes32 hash;
        Results studentResult;
    }
    
    
    address facultyAddress;
    
    mapping (address => Student) allStudentsData;
    
    event studentRecordAdded(address studentAddress,uint timeStamp);
    
    
    
    function Students() public{
        
        facultyAddress = msg.sender;
    }
    
    
    modifier onlyFaculty() {
        
        require(msg.sender == facultyAddress);
        _;
    }
    
    
    function addStudentRecord(address _studentAddress,uint _rollNumber,string _studentName,Results _studentResult) public onlyFaculty {
        
        Student memory temp = Student(_rollNumber,sha256(_studentName),_studentResult);
        
        allStudentsData[_studentAddress] = temp;
        
        studentRecordAdded(_studentAddress,now);
        
    }
    
    
    function getStudentRecord(address _studentAddress) constant public returns(uint,Results)  {
        
        Student memory temp = allStudentsData[_studentAddress];
        
        return (temp.rollNumber,temp.studentResult);
        
    }
    
    
    
    
}
