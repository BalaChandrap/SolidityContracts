pragma solidity ^0.4.16;


contract BlockchianClass {
    
    address admin;
    
    struct Member {
        address memberAddress;
        string name;
        uint age;
    }
    
    
    
    mapping (address=>Member) memberDetails;
    
    function BlockchianClass () public
    {
        admin = msg.sender;
    }
    
    
    modifier onlyAdmin(){
        if(msg.sender!=admin){
            revert();
        }
        _;
    }
    
    
    
    
    function addMember(address _memberAddress,uint _age,string _name) onlyAdmin{
        
        if(memberDetails[_memberAddress].age!=0){
            revert();
        }
        
        Member memory temp = Member(_memberAddress,_name,_age);
        
        memberDetails[_memberAddress] = temp;
        
    }
    
    
    function getMember(address _memberAddress) constant returns (uint,string) {
        
        return (memberDetails[_memberAddress].age,memberDetails[_memberAddress].name);
    }
    
    
    function editMember(address _memberAddress,uint _age,string _name)  {
        
        if(msg.sender!=_memberAddress&&msg.sender!=admin){
            revert();
        }
        
        if(memberDetails[_memberAddress].age==0){
            revert();
        }
        
        Member memory temp = memberDetails[_memberAddress];
        temp.age = _age;
        temp.name = _name;
        
        memberDetails[_memberAddress] =temp;
        
        
    }
    
    function getAdminAddress() constant returns (address){
        return admin;
    }
    
    function changeAdmin(address newAdmin) {
        if(msg.sender!=admin){
            revert();
        }
        
        admin = newAdmin;
    }
    
    
    
}
