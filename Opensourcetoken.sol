pragma solidity ^0.4.16;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract UserData is Ownable {
    
     struct Member {
        address memberAddress;
        uint    amountDeposited;
        uint    amountClaimed;
        uint    pendingAmount;
        uint    numberOfClaims;
        uint    validUPTO;
        uint    canClaimUPto;
        uint    multiplier;
        uint [] claimIDs;
    }
    
    using SafeMath for uint;
        
    address [] allMembers;  //addresses of all members in the contract.
    
    address acessContract;

    mapping(address=>Member) memberDetails; // Mapping to store details of all members.
    
    
    event MemberCreated(address indexed memberAddress,address indexed createdBy,uint timeStamp);
    event MemberDetailsUpdated(address indexed memberAddress,address indexed createdBy,uint timeStamp);
    event MemberAmountUpdated(address indexed memberAddress,address indexed createdBy,uint timeStamp);
    
    
    
    function setAccessContractAddress(address _newAddress) public onlyOwner {
        
        acessContract = _newAddress;
    }
    
    modifier onlyAccessContract (){
        require(msg.sender==acessContract);
        _;
    }
    
    
    function createMember(address _memeberAddress,uint _premiumAmount,uint _maxClaimAmount,uint _validityPeriod,uint _multiplier) public onlyAccessContract {
        
         Member memory temp = Member(_memeberAddress,_premiumAmount,0,0,0,now.add(_validityPeriod),_maxClaimAmount,_multiplier,new uint[](0));
        
         allMembers.push(_memeberAddress);
    
          memberDetails[_memeberAddress] = temp;
          
          emit MemberCreated(_memeberAddress,msg.sender,now);
        
    }
    
    function updateMemberDetails(address _memeberAddress,uint _premiumAmount,uint _validityPeriod) public onlyAccessContract {
        
        require(memberDetails[_memeberAddress].memberAddress!=address(0));
        require(memberDetails[_memeberAddress].validUPTO<=now);
        
        memberDetails[_memeberAddress].amountDeposited = _premiumAmount;
        memberDetails[_memeberAddress].validUPTO = now.add(_validityPeriod);
        
        emit MemberDetailsUpdated(_memeberAddress,msg.sender,now);
        
    }
    
    function updateMemberAmounts(address _memberAddress,uint _amountClaimed,uint _pendingAmount,uint _canClaimUPto) public onlyAccessContract {
        
        require(memberDetails[_memberAddress].memberAddress!=address(0));
        require(memberDetails[_memberAddress].validUPTO<=now);
        
        memberDetails[_memberAddress].amountClaimed = _amountClaimed;
        memberDetails[_memberAddress].pendingAmount = _pendingAmount;
        memberDetails[_memberAddress].canClaimUPto  = _canClaimUPto;
        
        
        
        emit MemberAmountUpdated(_memberAddress,msg.sender,now);
    }
    
    function getMemberDetails(address _memberAddress) public view returns (uint,uint,uint,uint,uint,uint [],uint,uint) {
        Member memory temp = memberDetails[_memberAddress];
        return (temp.amountDeposited,temp.amountClaimed,temp.pendingAmount,temp.numberOfClaims,temp.validUPTO,temp.claimIDs,temp.canClaimUPto,temp.multiplier);
         
    }
    
    
     //Method to check if an ethere address if part of our network.
    function checkMember(address _memberAddress) public view returns (bool){
        Member memory temp = memberDetails[_memberAddress];
        if(temp.amountDeposited == 0)
        return false;
        else
        return true;
    }
    
}


contract ClaimsData is Ownable {
    
    enum Status {created,accepted,rejected}
    
     struct Claim {
        uint    cliamID;
        address memberAddress;
        uint    claimAmout;
        uint    numberOfVotes;
        string  notes;
        Status  claimStatus;
    }
    
    uint  public totalClaimsCount;
    uint public approvedClaimsCount;
    uint public totalClaimAmount;
    
    address acessContract;
    
    mapping(uint=>Claim)    claimDetails;
    
    event ClaimCreated(address indexed patientAddress,address indexed cretedBy,uint claimID,uint timeStamp);
    
    function setAccessContractAddress(address _newAddress) public onlyOwner {
        
        acessContract = _newAddress;
    }
    
    modifier onlyAccessContract (){
        require(msg.sender==acessContract);
        _;
    }
    
    function createClaim(uint _claimID,address _userAddress,uint _claimAmount,string _notes) public onlyAccessContract {
        
         Claim memory temp = Claim(_claimID,_userAddress,_claimAmount,0,_notes,Status.created); //Divide by 100 before sending here.
        
        claimDetails[_claimID] = temp;
        
        emit ClaimCreated(_userAddress,msg.sender,_claimID,now);
        
    }
    
    function updateClaimVotes(uint _claimID) public onlyAccessContract {
        
        claimDetails[_claimID].numberOfVotes++;
    }
    
    function updateClaimStatus(uint _claimID,Status _claimStatus) public onlyAccessContract {
        claimDetails[_claimID].claimStatus = _claimStatus;
    }
    
    function getClaimDetails(uint _claimID) public view returns (address,uint,uint,Status,string){
        Claim memory temp = claimDetails[_claimID];
        return(temp.memberAddress,temp.claimAmout,temp.numberOfVotes,temp.claimStatus,temp.notes);
        
    }
    
    
    
}


contract VotesContract is Ownable {
    
    uint totalVotesRegistered;
    
    mapping(uint=>mapping(address=>bool)) votesPerClaim;
    
    mapping(address=>uint) votesPerUser;
    
    address acessContract;
    
    event VoteRegistered(address indexed _userAddress,address indexed contractAddress,uint claimID,uint timeStamp);
    
    function setAccessContractAddress(address _newAddress) public onlyOwner {
        
        acessContract = _newAddress;
    }
    
    modifier onlyAccessContract (){
        require(msg.sender==acessContract);
        _;
    }
    
    
    function registerVote(address _userAddress,uint _claimID) public onlyAccessContract {
        
        require(votesPerClaim[_claimID][_userAddress]==false);
        
        votesPerClaim[_claimID][_userAddress] = true;
        votesPerUser[_userAddress]++;
        
        VoteRegistered(_userAddress,msg.sender,_claimID,now);
        
    }
    
    
    
}





contract EthData is Ownable {
    
    uint totalsum;
    uint totalClaimAmount;
    uint totalWithdrawn;
    
    //***************************************************************************
    
    address acessContract;
    
    using SafeMath for uint;
    
    event EtherTransferred(address indexed _userAddress,address indexed contractAddress,uint amount,uint timeStamp);
    
    event EtherWithdrawn(address indexed adminAddress,uint amount,uint timeStamp);
    
    function setAccessContractAddress(address _newAddress) public onlyOwner {
        
        acessContract = _newAddress;
    }
    
    modifier onlyAccessContract (){
        require(msg.sender==acessContract);
        _;
    }
    
    function transferEther(address _userAddress,uint amount) public onlyAccessContract {
        
        require(amount<=totalsum/2);
        
        totalsum = totalsum.sub(amount);
        _userAddress.transfer(amount*(1 ether/1 wei));
        
        emit EtherTransferred(_userAddress,msg.sender,amount,now); 
        
    }

}




contract UHI {
    /*
        *Sample Implementation of Micro Insurance in Blockchian.
        *Only referredd users can be part of the network.
        *totalsum, pendingAmount, claimAmout are multiplied by 100 to facilitate upto 2 decimals. Whil displaying in the front end, we need to divide by 100.
        *But transfer of ether from contrac to members will be done with exact amount in wei.
        *Max claim amount, coverage multiplier and renewal period will be decided by the admin while deploying.
        
    */
    
    
    /*
        *Added new functionality of giving admins while deploying the contract.
        *Admin can add another type of users called support staff.
        *Self destruct method added which can only be called by Admins.
    */
    
    
    
    enum Status {created,accepted,rejected}
    
    uint public totalSum; // Total amount pooled by all users.
    
    
    
    uint coverageMultiplier; // 10x, how many time of the deposit amount user can claim.
    
    uint maxClaim; //1000. Maximum amount hat can be claimed by a user.
    
    uint renewalTime; // 1 year in seconds. 
    
    
    address walletAddress; // wallet address to which the ether should go. We are not using this in first phase.
    
    address [] admins;
    
    address [] supportStaff;
    
    mapping(address =>bool) isAdminUser;
    mapping(address =>bool) isSupportStaff;
    
    UserData        userDataContractAddress;
    ClaimsData      claimDataContractAddress;
    VotesContract   votesContractAddress;
    EthData         ethDataContractAddress;
    
    //Structure to hold details of the Member/user.
    
    
    
    
    
    struct Member {
        address memberAddress;
        uint    amountDeposited;
        uint    amountClaimed;
        uint    pendingAmount;
        uint    numberOfClaims;
        uint    validUPTO;
        uint    canClaimUPto;
        uint    multiplier;
        uint [] claimIDs;
    }
    
    
    //Structure to hold details of the Claim.
    struct Claim {
        uint    cliamID;
        address memberAddress;
        uint    claimAmout;
        uint    numberOfVotes;
        string  notes;
        Status  claimStatus;
    }
    
    address [] allMembers;  //addresses of all members in the contract.
    
    
    mapping(address=>Member) memberDetails; // Mapping to store details of all members.
    
    mapping(uint=>mapping(address=>bool)) votes; //To check if a user already voted for that claim.
    
    mapping(address=>uint) lastVoted; // TO check when was the last time the user voted.
    
    mapping(uint=>Claim)    claimDetails;  // Mapping to store all claims details.
    
    mapping(address=>bool) memberReferal;
    
    mapping(address=>bool) isReferred;
    
    mapping(address=>bool) isApproved; //Mapping to store if a new member is approved by Admins.
    
    mapping(address=>bool) memberVoteStatus;
    
    
    uint [] pendingClaims;
    
    uint  public totalClaimsCount;
    uint public approvedClaimsCount;
    uint public membersCount;
    uint public totalClaimAmount;
    
    
    event MemberInvited(address indexed inviterAddress,address inviteeAddress,uint timeStamp);
    
    event MemberApproved(address indexed approverAddres,address inviteeAddress,uint timeStamp);
    
    event InsuranceBought(address indexed memberAddress,uint value,uint timeStamp);
    
    event InsuranceRenewed(address indexed memberAddress,uint value,uint timeStamp);
    
    event ClaimCreated(address indexed memberAddress,uint value,uint claimID,uint timeStamp);
    
    event ClaimRejected(address indexed memberAddress,uint value,uint claimID,uint timeStamp);
    
    event ClaimApproved(address indexed memberAddress,uint value,uint claimID,uint timeStamp);
    
    event VoteRegistered(address indexed voterAddress,address indexed memberAddress,uint claimID,uint timeStamp);

    
    //Constructor method to create the contract. It takes the coverageMultiplier , renewal time and maximum claim as inpusts.
    function UHI (uint multiplier,uint _renewalTime,uint _maxClaim,address _admin){
        coverageMultiplier = multiplier;
        renewalTime = _renewalTime;
        maxClaim = _maxClaim;
        walletAddress = _admin;
        admins.push(_admin);
        isAdminUser[_admin] =true;
    }
    
    
    
    
    
    
    
    modifier onlyAdmin(){
        if(!isAdminUser[msg.sender])
        revert();
        _;
    }
    
    modifier onlySupportStaff(){
        if(!isSupportStaff[msg.sender])
        revert();
        _;
    }
    
    //This method can be used by the admin to add a new admin.
    
    function addAdminUser(address _newAdmin) onlyAdmin {
        isAdminUser[_newAdmin] = true;
        admins.push(_newAdmin);
    }
    
    
    //This method is called by the admin to set the storgae contract addresses.
    
    function setContractAddress(address _userDataAddress,address _claimDataAddress,address _votesAddress,address _ethAdderss) onlyAdmin {
        
        userDataContractAddress     = UserData(_userDataAddress);
        claimDataContractAddress    = ClaimsData(_claimDataAddress);
        votesContractAddress        = VotesContract(_votesAddress);
        ethDataContractAddress      = EthData(_ethAdderss);
        
           
    }
    
    //This method can be used by the admins to add the Support Staff to the contract.
    
    function addsupportStaff(address _staffAddress) onlyAdmin {
        isSupportStaff[_staffAddress] = true;
        supportStaff.push(_staffAddress);
    }
    
    
    //This method can be used if we want to change multiplier, renewalTime or maxClaim in future.
    function changeParameters(uint multiplier,uint _renewalTime,uint _maxClaim) onlyAdmin{
        
        coverageMultiplier = multiplier;
        renewalTime = _renewalTime;
        maxClaim = _maxClaim;
        walletAddress = msg.sender;
    }
    
    
    //This method is used to refer a new member in to the network
    // This method takes address of the new member as input.
    //Admin can invite multiple people, but a member can invite only one other member.
    function referMember(address _newMember) public {
        if(isAdminUser[msg.sender]){
            isReferred[_newMember] = true;
        }
        else{
        if(userDataContractAddress.checkMember(msg.sender)==false){
            revert();
        }
        if(memberReferal[msg.sender]==true){
            revert();
        }
        memberReferal[msg.sender] = true;
        isReferred[_newMember]=true;
        
        }
        
        emit MemberInvited(msg.sender,_newMember,now);
    } 
    
    
    function approveMember(address _newMember) public onlyAdmin {
        
        require(isReferred[_newMember] == true);
        
        isApproved[_newMember] = true;
        
        emit MemberApproved(msg.sender,_newMember,now);
    }
    
    
    function isValid() public constant returns(bool){
        if(memberDetails[msg.sender].validUPTO<now)
        {
            return false;
        }
        return true;
    }
    
    

   


// User can buy insurance using this method, here we are creating a new member in our contract.
// New user should be invited first and then need to be approved to become part of the network.
    function  buyInsurance() public payable {
        
        require(msg.value==1 ether);
        
        require(isApproved[msg.sender]==true);
        
        Member memory temp1 = memberDetails[msg.sender];
        
        require(temp1.memberAddress == address(0));
        
        
        uint amountCanbeClaimed;
        if(msg.value*coverageMultiplier < maxClaim){
        amountCanbeClaimed = msg.value*coverageMultiplier;
        }
        else{
        amountCanbeClaimed = maxClaim;
        }
        amountCanbeClaimed = amountCanbeClaimed*10**18;
        
        
        userDataContractAddress.createMember(msg.sender,msg.value,renewalTime,amountCanbeClaimed,coverageMultiplier);
        
        // Member memory temp = Member(msg.sender,msg.value,0,0,0,now+renewalTime,amountCanbeClaimed,coverageMultiplier,new uint[](0));
        
        // allMembers.push(msg.sender);
    
        //  memberDetails[msg.sender] = temp;
        memberVoteStatus[msg.sender] = true;
        
        totalSum+=msg.value*100;
        
    
        membersCount++;
        InsuranceBought(msg.sender,msg.value,now);
        
       // walletAddress.send(msg.value);
        
    }
    
    
    // Method to renew insurance.

    function renewInsurance() public payable {
        Member memory temp = memberDetails[msg.sender];
        
        if(temp.validUPTO == 0){
            revert();
        }
        
        if(temp.validUPTO>now){
            revert();
        }
        
        uint renewalAmount;
        if(temp.amountClaimed > (9*temp.canClaimUPto)/10){
            renewalAmount = 1.2*(1 ether/1 wei);
        }
        else if(temp.amountClaimed < (5*temp.canClaimUPto)/10){
            renewalAmount = 0.9*(1 ether/1 wei);
        }
        else{
            renewalAmount = (1 ether/ 1 wei);
        }
        if(renewalAmount != msg.value)
        revert();
        
        totalSum+=msg.value;
        
        uint amountCanbeClaimed = coverageMultiplier*(1 ether/1 wei);
        
        amountCanbeClaimed = maxClaim;
        
        
        temp.amountDeposited = msg.value;
        temp.validUPTO = now+renewalTime;
        temp.canClaimUPto = amountCanbeClaimed;
    
        memberVoteStatus[msg.sender] = true;
        
        
        memberDetails[msg.sender] = temp;
        
        
        userDataContractAddress.updateMemberDetails(msg.sender,msg.value,renewalTime);
        userDataContractAddress.updateMemberAmounts(msg.sender,0,0,amountCanbeClaimed);
        
        InsuranceRenewed(msg.sender,msg.value,now);
        
    }
     
// User can create a new claim, by using this method.     
     
    function createClaim(uint amount,uint _claimID,string _notes) public  {
         
         Member memory mem = memberDetails[msg.sender];
         
         if(userDataContractAddress.checkMember(msg.sender)==false)
         {
             revert();
         }
         
         uint amoountInWei = amount*(1 ether/ 1 wei);
         
         if(mem.validUPTO < now ){
              ClaimRejected(msg.sender,amount,_claimID,now);
            revert();
         }
         
         
        if (amoountInWei > totalSum/2 ||  (mem.amountClaimed+mem.pendingAmount+amoountInWei)/100> mem.canClaimUPto){
            
            ClaimRejected(msg.sender,amount,_claimID,now);
            revert();
        }
        
        if((mem.amountClaimed+mem.pendingAmount+amoountInWei)/100 > (mem.canClaimUPto*9)/10){
            memberVoteStatus[msg.sender] = false;
        }
        
        totalSum = totalSum-amount;
        Claim memory temp = Claim(_claimID,msg.sender,amoountInWei/100,0,_notes,Status.created);
        
        claimDetails[_claimID] = temp;
        
        memberDetails[msg.sender].claimIDs.push(_claimID);
        memberDetails[msg.sender].numberOfClaims++;
        memberDetails[msg.sender].pendingAmount += amoountInWei;
        
    
        totalClaimsCount++;    
        ClaimCreated(msg.sender,amount,_claimID,now);
        
    }
    
    
    
    //To check the vote Status

    
    
    // Users can give vote to a claim by calling this method, in this method, we are also chekcing the number of votes for that claim, and if is of the required value, claim will be processed.
    
    function approveClaim(uint _claimID) public returns (string) {
        
      Claim memory temp = claimDetails[_claimID];

        if(votes[_claimID][msg.sender]){
            revert();
        }
        
        if(memberVoteStatus[msg.sender]==false){
            revert();
        }
        
        
        
        if(memberDetails[msg.sender].validUPTO<now){
            revert();
        }
        
        if(msg.sender == temp.memberAddress){
            revert();
        }
        
        votes[_claimID][msg.sender] = true;
        lastVoted[msg.sender] = now;
        
        
        if(++temp.numberOfVotes>=temp.claimAmout/(1 ether/1 wei)){
            approvedClaimsCount++;
            totalClaimAmount+=temp.claimAmout;
           ClaimApproved(temp.memberAddress,temp.claimAmout,_claimID,now);
           temp.claimStatus = Status.accepted;
           uint256 etherToBesent = temp.claimAmout;
           totalSum = totalSum- (etherToBesent*100);
           temp.memberAddress.transfer(etherToBesent);
           Member memory mem = memberDetails[temp.memberAddress];
           mem.amountClaimed += temp.claimAmout*100;
           mem.pendingAmount -= temp.claimAmout*100;
           memberDetails[temp.memberAddress] = mem;
           claimDetails[_claimID] = temp;
           
        }
        else{
            claimDetails[_claimID] = temp;
        }
        VoteRegistered(msg.sender,temp.memberAddress,_claimID,now);
        return("vote registered");
        
    }
    
    
   
    
    
    //Method to get the details of a claim.
    function getClaimDetails(uint _claimID) public view returns (address,uint,uint,Status,string){
        Claim memory temp = claimDetails[_claimID];
        return(temp.memberAddress,temp.claimAmout,temp.numberOfVotes,temp.claimStatus,temp.notes);
        
    }
    
    
    //Method to get the details of a Member.
    function getMemberDetails(address _memberAddress) public view returns (uint,uint,uint,uint,uint,uint [],uint,uint) {
        Member memory temp = memberDetails[_memberAddress];
        return (temp.amountDeposited,temp.amountClaimed,temp.pendingAmount,temp.numberOfClaims,temp.validUPTO,temp.claimIDs,temp.canClaimUPto,temp.multiplier);
         
    }
    
    function getPublicDetails() public view returns(uint,uint,uint,uint,uint){
        return(totalSum,membersCount,totalClaimsCount,approvedClaimsCount,totalClaimAmount);
    }
    
    function destroyContract() private onlyAdmin  {
        selfdestruct(msg.sender);
    }
    
    
}

