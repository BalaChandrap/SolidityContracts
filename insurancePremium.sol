pragma solidity ^0.4.15;


/*Author: Swathi Kadambala */
contract InsurancePremium {
    
    address admin; 
    
    uint customerCounter;
    
    // Customer details 
    struct Customer {
        uint id; 
        string fullName;
        uint contactPhone;
        string emailId;
        CustomerAddress addressDetails; // Address 
        CustomerPolicy[ ] availedPolicies;  // policies bought 
    }
    
    struct CustomerAddress {
        string locality;
        string city;
        string country;
        string zipcode;
    }
    
    struct AvailablePolicy {   // All types of policies with an Life Insurance Company 
        uint policyNo;
        string policyName;
        uint term;
        string[] benefits;
     }

    struct CustomerPolicy { // Policies which customers bought 
        
        AvailablePolicy policyReference; 
        string dateOfPurchase;
        string dateOfExpiry;
        PaymentType paymentType; // When is the customer going to pay premiums 
        Premium[] premiums; 
     }

    enum PaymentType {MONTHLY, HALFYEARLY, YEARLY}
     
    struct Premium{   
         uint premiumNo;
         uint premiumAmount;
         string dueDateFrom; 
         string dueDateTo;
         bool isPaid;
     }
         
    AvailablePolicy[] allAvailablePolicies;
    CustomerPolicy[] allCustomerPolicies; 
    
    mapping(address => Customer) customers;  
    
    function InsurancePremium() public{
        
        admin = msg.sender;

        // initialise customer count to 0 
        customerCounter = 0;
            
        // initialise policies 
        string memory benefit1 = "good policy returns";
        string memory benefit2 = "Can claim the policy immediately after the term"; 
        string[] memory _benefits = new string[](2);
        _benefits[0] = benefit1;
        _benefits[1] = benefit2;

        AvailablePolicy memory policy1 = AvailablePolicy({
                                                 policyNo: 101, 
                                                 policyName: "Jeevan Anand",
                                                 term: 5,  // Number of years 
                                                 benefits: _benefits});
        
         AvailablePolicy memory policy2 = AvailablePolicy({
                                                 policyNo: 102, 
                                                 policyName: "Jeevan Utkarsh",
                                                 term: 10,  // Number of years 
                                                 benefits: _benefits});
                                                 
        AvailablePolicy memory policy3 = AvailablePolicy({
                                                 policyNo: 103, 
                                                 policyName: "Jeevan Labh",
                                                 term: 15,  // Number of years 
                                                 benefits: _benefits});
        allAvailablePolicies.push(policy1);
        allAvailablePolicies.push(policy2);
        allAvailablePolicies.push(policy3);
        
    }
   
   function editCustomer(address addressOfCustomer, string emailId, string locality,
                         string city, string country, string zipcode
                         ) public{ 
                             
        
    }
    
   /* function addCustomer(address addressOfCustomer, string fullName, uint contactPhone, string emailId, string locality,
                         string city, string country, string zipcode, uint policyNo, uint term, string dateOfPurchase,
                         string dateOfExpiry, uint paymentType, uint premiumAmount
                         ) public{ */
                         
    function addCustomer(address addressOfCustomer, string fullName, uint contactPhone, string emailId, uint policyNo, uint term, string dateOfPurchase,
                         string dateOfExpiry, uint paymentType, uint premiumAmount
                         ) public{ 
        
        require(msg.sender == admin); // Only admin can add a new customer 
        
        // Based upon policy purchased and payment type 
        // need to calculate the premiums 
        // For now 
        AvailablePolicy memory policy;
        bool policyExists = false; 
        // Get the policy reference with policy number 
        for(uint i=0; i < allAvailablePolicies.length; i++){
            policy = allAvailablePolicies[i];
            if (policy.policyNo == policyNo){
                policyExists = true; 
                break;
            }
        }
        if(!policyExists){ revert; } 
       
        //uint noOfPremiums = getPremiumCount(term, paymentType);
        //noOfPremiums = 1;
        Premium[] memory premiumsTmp = getPremiumsForTheCustomer(1, premiumAmount); 
        CustomerPolicy memory customerPolicy = CustomerPolicy({ 
                                             policyReference: policy,
                                             dateOfPurchase: dateOfPurchase,
                                             dateOfExpiry: dateOfExpiry,
                                             paymentType: PaymentType.YEARLY,
                                             premiums: premiumsTmp
                                          }
                                      );
        
        CustomerPolicy[ ] availedPoliciesTmp;
        availedPoliciesTmp.push(customerPolicy);

      // Stack too deep error came, so had to decrease the no of arguments // removed contactPhone
        Customer memory customer = Customer({ id: customerCounter,
                                      fullName: fullName,
                                      contactPhone: contactPhone,
                                      emailId: emailId,
                                      addressDetails: CustomerAddress({locality: "",
                                        city: "",
                                        country: "",
                                        zipcode: ""}),
                                      availedPolicies: availedPoliciesTmp
                                    });
                                    
        
        customers[addressOfCustomer] = customer;                          
    }
    
    function getPremiumsForTheCustomer(uint noOfPremiums, uint premiumAmount) private constant returns(Premium[]){
        
        Premium[] premiumsTmp; 
        for(uint i = 0; i < noOfPremiums; i++){
            Premium memory premium = Premium({
            premiumNo: i+1,
            premiumAmount: premiumAmount,
            dueDateFrom: "01-Jan-2019", // Need to check accessing date and time 
            dueDateTo: "05-Jan-2019",
            isPaid: false
         });
         premiumsTmp.push(premium);
        }
        return premiumsTmp;
    }
    
    function getPremiumCount(uint term, uint paymentType) private constant returns(uint){
        
         uint noOfPremiums = 0;
        if(paymentType == uint(PaymentType.MONTHLY) ){
            noOfPremiums = term * 12;
        }else if (paymentType == uint(PaymentType.HALFYEARLY) ){
            noOfPremiums = term * 2;
        }
        else if (paymentType == uint(PaymentType.YEARLY) ){
            noOfPremiums = term;
        }
        
        return noOfPremiums; 
    }
    
    
}
