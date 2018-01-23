pragma solidity ^0.4.16;


/*Author: Raja Sekhar */

/** submitted as an exercise **/

contract Employee{
    
    address admin; 
    int16 empCount = 0;
    int8 roleCount = 0;
    
    struct empDetails{
        address empAddr;
        int16 id;
        string name;
        int8 salary;
        string title;
    }
    
    enum roleType { employee,personal }
     
    struct roleRequests{
        address empAddr;
        roleType role;
    }
    
    roleRequests[] requests;
    
    struct roles{
        address empAddr;
        roleType role;
    }
    
    mapping (address => empDetails) m_employeeDetails;
    mapping (address => roles) m_employeeRoles;
    
    function Employee() public{
        admin = msg.sender;
    }
    
    function create(address empAddr, string name, int8 sal,string title) public{
        if(msg.sender != admin){
            revert();
        }
        
        empCount = empCount++;
        
        empDetails memory temp = empDetails(empAddr,empCount, name,sal,title);
        
        m_employeeDetails[empAddr] = temp;
    }
    
    function getEmplyementDetails(address empAddr) public view returns (string,int8,string) {
        
        if(msg.sender!= admin || m_employeeDetails[empAddr].empAddr == 0 || m_employeeRoles[empAddr].role != roleType.employee){
            revert();
        }
        
        return (m_employeeDetails[empAddr].name,m_employeeDetails[empAddr].salary,m_employeeDetails[empAddr].title);
    }
    
    function updateEmpoyemntDetails(address empAddr,string name, int8 sal, string title) public {
        
        if(msg.sender != admin || m_employeeDetails[empAddr].empAddr == 0){
            revert();
        }
        
        empDetails memory tmpEmp = m_employeeDetails[empAddr];
        
        tmpEmp.empAddr = empAddr;
        tmpEmp.name = name;
        tmpEmp.salary = sal;
        tmpEmp.title = title;
        
        m_employeeDetails[empAddr] = tmpEmp;
    }
    
    function updateEmpoyeePromotionalDetails(address empAddr, int8 sal, string title) public {
        
        if(msg.sender != admin || m_employeeDetails[empAddr].empAddr == 0){
            revert();
        }
        
        empDetails memory tmpEmp = m_employeeDetails[empAddr];
        
        tmpEmp.empAddr = empAddr;
        tmpEmp.salary = sal;
        tmpEmp.title = title;
        
        m_employeeDetails[empAddr] = tmpEmp;
    }
    
    function sendRequestToGetEmplyeeDetails(address empAddr) public {
        
        if(msg.sender != admin || msg.sender != empAddr){
            revert();
        }
        
        roleRequests memory tmpReq = roleRequests(empAddr,roleType(1));
        
        requests.push(tmpReq);
        
    }
    
    function updateRoles() public{
        if(msg.sender != admin){
            revert();
        }
        
        for(uint i = 0; i < requests.length;i++){
            roleRequests memory tmp = requests[i];
            
            m_employeeRoles[tmp.empAddr] = roles(tmp.empAddr,tmp.role);
        }
    }
    
}
