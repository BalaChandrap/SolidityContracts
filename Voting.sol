pragma solidity ^0.4.17;

/*Author: Swathi Kadambala */
contract Voting {
    
    // There are few proposal names 
    // We can invite people to vote 
    // get the winning proposal name finally 
    
    address admin;
    
    struct Proposal{

        bytes32 proposalName;
        uint voteCount;
    } 
    
    Proposal[] proposals;
    
    struct Voter{
        
        bool voted;
        address delegate;
        uint indexOfProposals;
        uint weight;
        //int votesCount; // Voter's vote count is 1 + delegate's weight i.e,
        // if 3 voters delegated to single delegate, delegate's votescount is 3 + 1 (self)
        // Instead of keeping variable name is votesCount 
        // put as weight 
    }
    
    mapping(address => Voter) voters; 
    
    // create proposals 
    // Passing String array is not possible
    function Voting(bytes32[] proposalNames) public{
        
        admin = msg.sender; 
    
        for (uint i = 0; i < proposalNames.length; i++){
            
            Proposal memory proposal = Proposal({proposalName: proposalNames[i],
                                       voteCount: 0});
            proposals.push(proposal);                         
                                       
        }
        
        giveRightToVote(admin);
    }
    
    // Returning array of structure or structure is not possible 
    
    function getProposals() public constant returns(string) {
        return bytes32ToString(proposals[0].proposalName);
    }
    
    function bytes32ToString(bytes32 x) private constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    
    modifier onlyByAdmin(address account) {
         require (msg.sender == admin);
         _;
    } 
    
    function giveRightToVote(address voter) public onlyByAdmin (msg.sender){

       //  voters[address] = Voter({voted: false, delegate : address(0)}); 
       // as the above is not possible
       // Keeping an entry of voter address is assigning the voter the right to vote 
       voters[voter].voted = false; 
       voters[voter].weight = 1;

    }
    
    function getVoteCountForProposal(uint indexOfProposals) public constant returns(uint){
        
        return proposals[indexOfProposals].voteCount;
    }
    
    
    function hasRightToVote() public constant returns(bool) {
        
        if (voters[msg.sender].weight >= 1){
            return true;
        }
        
       return false;
    }   
    
    
    function voteFor(uint indexOfProposals) public {
        
        // check sender is eligible to vote or not 
       require(voters[msg.sender].voted == false);
       
       proposals[indexOfProposals].voteCount += voters[msg.sender].weight;
       voters[msg.sender].voted = true; 
       voters[msg.sender].indexOfProposals = indexOfProposals;
       
       // if current voter is delegated by some other voters, add those vote vounts as well 
    
    }
    
    function delegate(address delegateTo) public{
       
        // check sender is eligible to vote or not 
       require(msg.sender != delegateTo);

       require(voters[msg.sender].weight >= 1);
       require(voters[delegateTo].weight >= 1);

       // assigning delegate of voter to delegate  
       voters[msg.sender].delegate = delegateTo; 
       
       // Check if delegate has already voted 
       // if yes, the current voters goes to the proposal whom delegate has already voted for 
       
       if(voters[delegateTo].voted){
          
          uint indexOfProposalByDelegate = voters[delegateTo].indexOfProposals; 
          proposals[indexOfProposalByDelegate].voteCount += 1; 
          voters[msg.sender].indexOfProposals = voters[msg.sender].indexOfProposals; 
          voters[msg.sender].voted = true;
          
       }else{
          voters[delegateTo].weight += 1;
       }
    }
    
    function winner() public returns(string){
        
        uint max = 1000;
        
        for(uint i=0; i< proposals.length; i++){
            
            Proposal proposal = proposals[i];
            
            uint votesCount = proposal.voteCount; 
            
            if(votesCount > max){
                max = votesCount; 
            }
        }
        
        if (max == 1000){
            return "Not Found";
        }else{
            return bytes32ToString(proposals[max].proposalName);
        }
    }
    
    
}
