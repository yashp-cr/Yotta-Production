function SubscriptionClass() {

    var _contracts = [];
    var _allSubscriptions = [];

    this.getAllContractsAsFilters = function( filters ) {
        ContractReportExcelController.getAllContracts(filters, function(result, event){
            _contracts = [];
            _contracts.concat( result );
        });
    }

    this.populateSubscriptionDataForContracts = function( baseFilters ) {
        getContractData( baseFilters )
    }

    this.getAllSubscriptions = function() {
        return _allSubscriptions;
    }

    function getContractData(baseFilters) {
        var currFilter = baseFilters + " AND SBQQ__Contract__c = '" + _contracts[0] + "'";
         
    }

}