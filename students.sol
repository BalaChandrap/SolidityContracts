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
    
    event studentRecordUPdated(address indexed updatedBy,address studentAddress,uint timeStamp);
    
    
    
    function Students() public{
        
        facultyAddress = msg.sender;
    }
    
   
    
    modifier onlyFaculty() {
        
        require(msg.sender == facultyAddress);
        _;
    }
    
    function changeFaculty(address newFaculty) public onlyFaculty
    {
        facultyAddress = newFaculty;
        
        
    
        
    
        
    }
    
    
    function addStudentRecord(address _studentAddress,uint _rollNumber,string _studentName,Results _studentResult) public onlyFaculty  {
        
        require(msg.value>10);
        
        Student memory temp = Student(_rollNumber,sha256(_studentName),_studentResult);
        
        allStudentsData[_studentAddress] = temp;
        
       emit studentRecordAdded(_studentAddress,now);
        
    }
    
    
    function getStudentRecord(address _studentAddress) view public returns(uint,bytes32,Results)  {
        
        Student memory temp = allStudentsData[_studentAddress];
        
        return (temp.rollNumber,temp.hash,temp.studentResult);
        
    }
    
    modifier checkPermission (address _studentAddress){
        require(msg.sender==_studentAddress||msg.sender==facultyAddress);
        require(allStudentsData[_studentAddress].rollNumber!=0);
        _;
    }
    
    
    function editStudentRecord(address _studentAddress,string _updatedName,Results _updatedResults) public checkPermission( _studentAddress) {
        
        Student memory temp = allStudentsData[_studentAddress];
        
        temp.hash = sha256(_updatedName);
        temp.studentResult = _updatedResults;
        
        allStudentsData[_studentAddress] = temp;
        
        emit studentRecordUPdated(msg.sender,_studentAddress,now);
        
    }
    
    
  
    
    
    
    
}
