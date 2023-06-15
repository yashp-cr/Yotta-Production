@isTest
public class AddressTriggerHandlerTest {
    
    @testSetup
    public static void createData(){
        //create trigger controller
        TriggerController__c tc = new TriggerController__c(DeactivateObjectTrigger__c = '', isActive__c = TRUE);
        insert tc;
    }
    
    @isTest
    public static void createAddressAndSendToKafka(){
        
        //insert account
        Account acc = new Account(Name = 'Acc Name', Industry = 'Manufacturing', YottaIndustry__c= 'Automotive');
        insert acc;
        
        State__c objState = new State__c();
        objState.Active__c = true;
        objState.Country__c = 'IN';
        objState.State_Code__c = 'MH';
        insert objState;
        
        //insert Address
        Address__c add = new Address__c(AddressLine1__c = 'Sample Add', 
                                                City__c = 'city',
                                        	 Country__c = 'IN',
                                          PostalCode__c = '101010',
                                       GSTApplicable__c = 'No',
                                              State2__c = objState.Id,
                                         AddressType__c = 'Billing',
                                             Account__c =  acc.Id,
                                   Send_To_Api_layer__c =  TRUE);
        insert add;
        
        //send record to kafka by changing envelope fields
        add.AddressLine1__c = 'Yotta add';
        update add;
    }
}