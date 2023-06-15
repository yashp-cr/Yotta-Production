/* ****************************************************************************************************************
Name          : IntegrationExtension
Description   : Interface to create custom JSON structure in integration framework using apex.
Author        : Nandish Shenoy  
Creation Date : 20/5/2020
Modified Date : 29/5/2020
**************************************************************************************************************** */

public interface IntegrationExtension {
    Object runExtension( String params );    
    void runExtension( String params, String requestid);
}