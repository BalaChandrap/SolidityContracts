pragma solidity^0.4.*;

/*This example on how to access another contracts storage from one cotnract. 

  Here in this example , I am using two contracts Teacher contract and Student Contract. 
    
  In Teacher contract teacher will add students. In sutdents contract, students can update their marks.


*/

contract owned {
    
    
    address admin;
    
    function owned(){
        admin = msg.sender;
    }
    
    modifier onlyAdmin(){
        
        require(admin==msg.sender);
        _;
    }
}



contract TeacherContract is owned {
    
    
    address Teacher;
    
    struct Student {
        
        
        uint rollNo;
        string name;
        
        mapping(uint=>uint) marksPerSubject;
        
    }
    
    mapping(address=>Student) public allStudents;
    
    
    function StructMap(){
        Teacher = msg.sender;
    }
    
    
    function addStudentRecord(address studentAddress,uint _rollNo,string _name) onlyAdmin {
        
        Student memory std = Student(_rollNo,_name);
        
        allStudents[studentAddress] = std;
        
    }
    
    function setMarks(address studentAddress,uint subjectID,uint marks){
        allStudents[studentAddress].marksPerSubject[subjectID] = marks;
    }
    
    function getmarks(address studentAddress, uint subjectID) view returns (uint){
        
        return  allStudents[studentAddress].marksPerSubject[subjectID];
    }
    
}


contract StudentContract is owned {
    
    TeacherContract teacherContract;
    
    
    function setContractAddress(address contractAddress) public onlyAdmin {
        teacherContract = TeacherContract(contractAddress);
    }
    
    function addMarks(uint subjectID,uint marks){
        
        teacherContract.setMarks(msg.sender,subjectID,marks);
    }
    
    function getmarks(address studentAddress,uint subjectID) view returns (uint) {
        
       return teacherContract.getmarks(studentAddress,subjectID);
    }
    
}

contract  ParentContract is owned {
    
    TeacherContract teacherContract;
    
     
    function setContractAddress(address contractAddress) public onlyAdmin {
        teacherContract = TeacherContract(contractAddress);
    }
    
    function getmarks(address studentAddress,uint subjectID) view returns (uint) {
        
       return teacherContract.getmarks(studentAddress,subjectID);
    }
    
}






















