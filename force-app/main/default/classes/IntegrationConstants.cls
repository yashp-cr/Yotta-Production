/* ****************************************************************************************************************
Name          : IntegrationConstants
Description   : Stores constant keywords used in IntegrationFramework
Author        : Nandish Shenoy  
Creation Date : 20/5/2020
Modified Date : 29/5/2020
**************************************************************************************************************** */
public with sharing class IntegrationConstants {
    
    public static final String STR_ACCOUNT_TEMPLATE_NAME = Label.Integration_Account_Metadata;
    public static final String STR_CONTACT_TEMPLATE_NAME = Label.Integration_Contact_Metadata;
    public static final String STR_ADDRESS_TEMPLATE_NAME = Label.Integration_Address_Metadata;
    public static final String STR_PRODUCT_TEMPLATE_NAME = Label.Integration_Product_Metadata;
    public static final String STR_OUTBOUNDBATCH_BASEQUERY = 'SELECT ID, Name, Parent_Template_Name__c, Valid_for_Retrial__c, Number_of_Retrials__c, Account__c, Contact__c, Address__c, Product2__c, Contract__c, Error_Code__c, Error_Description__c, Integration_Status__c, Downstream_Reference_ID__c, Request_Envelope__c, Response_Envelope__c, Unique_Key__c FROM Integration_Message__c';
    public static final String STR_CONTRACT_TEMPLATE_NAME = Label.Integration_Contract_Metadata;
    public static final String STR_NO_TEMPLATE_NAME = 'NO_TEMPLATE';
	
    public static void dummyMethod() {
        Decimal int1 = 0;
        Decimal int2 = 0;
    }
    
}