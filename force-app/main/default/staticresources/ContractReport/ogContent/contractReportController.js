$(document).ready(function(){
    showLoader();
    renderFilters();
    var filters = [];
    getDataFromApex( filters ); 
});

Handlebars.registerHelper('isObjectNotEmpty', function (value) {
    return Object.keys(value).length > 0 ;
});

function showLoader() {
    $('#loading').show();
}

function hideLoader() {
    $('#loading').hide();
}

function renderFilters() {
    var filterTemplate = Handlebars.getTemplate('contractReportFilter');
    var filterHtml = filterTemplate({ "data": window.PicklistValues}); 
    $('#filterOptions').html( filterHtml );            
    $('.filter-date').datepicker({ dateFormat: 'yy-mm-dd' }); 
    $('[html-event="applyFilter"]').click(applyFilter);
    $('[html-event="downloadCsv"]').click(downloadCSV);
}

function bindPagingEventHandlers() {
    $('.nextButton').on('click', nextPageEventHandler);
    $('.prevButton').on('click', prevPageEventHandler);
}

function unbindPagingEventHandlers() {
    $('.nextButton').off('click', nextPageEventHandler);
    $('.prevButton').off('click', prevPageEventHandler);
}

function nextPageEventHandler() {
    window.PageInstance.nextPage();
    renderData();
}

function prevPageEventHandler() {
    window.PageInstance.previousPage();
    renderData();
}

function applyFilter(e) {
    var filters = [];
    $('[html-filter="true"]').each(function(){
        if( $(this).is('input') && $(this).val().length > 0) {
            if( $(this).hasClass('filter-date') ) {
                filters.push($(this).attr('html-filter-field') + $(this).attr('html-cond') + $(this).val());
            } else {
                filters.push($(this).attr('html-filter-field') + "='" + $(this).val() + "'");
            }
        } else if( $(this).is('select') && $(this).val().length > 0 ) {
            filters.push($(this).attr('html-filter-field') + " IN ('" + $(this).val().join("','") + "')" );
        }
    });
    getDataFromApex( filters );
}

function getDataFromApex( filters ) {
    filters.push('SBQQ__Quantity__c >= 0');
    filters.push('SBQQ__Bundle__c = false');
    showLoader(); 
    getAllContractsAsFilters(filters, function(result){
        window.PageInstance = new PaginateTable( result, window['PageSize'] );
        renderData();
        bindPagingEventHandlers();
        hideLoader();
    }); 
}

function renderData() {
    var data = window.PageInstance.getData();
    window.PageInstance.toggleControl();
    console.log('data on page::', data);
    var compiledTemplate = Handlebars.getTemplate('ContractTemplate');
    var html = compiledTemplate({ 
                    "data": {
                        ContractHeader : window['DataColumns'],
                        subscriptionData: data 
                    }
                });
    $('#contractReport').html( html );       
}

function getAllContractsAsFilters( filters, callback ) {
    var baseFilters = filters.join(' AND ');
    ContractReportExcelController.getAllContracts(baseFilters, function(result, event){
        if( event.type === 'exception') {
            swal('Exception occured', event.message);
            hideLoader();
        } if( result.length === 0 ){
            swal( 'No Records found.' );
            hideLoader();
        } else {
            console.log('result All Contracts', result);
            getContractData( baseFilters, result, [], callback );
        }
    });
}

function getContractData(baseFilters, contracts, mainSubArray, callback) {
    var currFilter = baseFilters + " AND SBQQ__Contract__c = '" + contracts[0] + "'";
    ContractReportExcelController.getFormattedSubscriptionLinesFilter(currFilter , function(result, event){
        if( event.type === 'exception') {
            swal('Exception occured', event.message);
            hideLoader();
        } else {
            contracts.splice( 0,1 );
            console.log('event', event);
            var newMainSubArray = mainSubArray.concat(result);
            console.log('items pending', contracts.length)
            if( contracts.length > 0 ) {
                getContractData(baseFilters, contracts, newMainSubArray, callback);
            } else {
                callback(newMainSubArray);
            }
        }
    },{escape:false});    
}

function downloadCSV(e) {
    var rows = [];
    rows.push(window['DataColumns']);
    window.PageInstance.getAllData().forEach(function(row){
        var csvRow = [];
        csvRow.push( row.BillCustId );
        csvRow.push( row.strAccountName );
        csvRow.push( row.ContractNumber );
        csvRow.push( row.BundleName );
        csvRow.push( row.ComponentName);
        csvRow.push( row.SegmentYear);
        csvRow.push( row.businessUnit );
        csvRow.push( row.strStartDate );
        csvRow.push( row.strEndDate );
        csvRow.push( row.AccountManagerName );
        csvRow.push( row.ProductFamily );
        csvRow.push( row.ProductModel );
        csvRow.push( row.ProductDescription );
        csvRow.push( row.strBillStartDate );
        csvRow.push( row.strBillEndDate );
        csvRow.push( row.strTechStartDate );
        csvRow.push( row.strTechEndDate );
        csvRow.push( row.strCancellationDate );
        csvRow.push( row.years );
        csvRow.push( row.months );
        csvRow.push( row.days );
        csvRow.push( row.contractCurrency );
        csvRow.push( row.billingCurrency );
        csvRow.push( row.billingFrequency );
        csvRow.push( row.lineItemSrNo );
        csvRow.push( row.lineItemId );
        csvRow.push( row.ServiceId );
        csvRow.push( row.status );
        csvRow.push( row.componentQuantity );
        csvRow.push( row.unitOTC );
        csvRow.push( row.unitMRC );
        csvRow.push( row.unitVRC );
        csvRow.push( row.totalOTC );
        csvRow.push( row.totalMRC );
        csvRow.push( row.totalVRC );
        csvRow.push( row.totalACV );
        csvRow.push( row.totalTCV );
        csvRow.push( row.DCLocation );
        csvRow.push( row.SupportCustId );
        csvRow.push( row.SupportCustName );
        csvRow.push( row.HSNSACCode );
        csvRow.push( row.OMTApprovalStatus );
        csvRow.push( row.PrimarySource );
        csvRow.push( row.SecondarySource );
        csvRow.push( row.TertiarySource );
        csvRow.push( row.vertical );
	csvRow.push(row.ApprovalDate);
        rows.push( csvRow );
    }); 
    csvGenerator = new CsvGenerator(rows, 'contract report.csv');
    csvGenerator.getLinkElement(true).click();
}    

function PaginateTable(data, size) {
    var _data = data;
    var _pagesize = size; 
    var _startIndex = 0;
    var _endIndex = (_startIndex + _pagesize) - 1;

    this.getData = function() {
        var pageData = [];
        for( var i=_startIndex ; i <= _endIndex; i++) {
            if( i < data.length ) {
                pageData.push( _data[i] );
            }
        }
        return pageData;
    }

    this.nextPage = function() {
        _startIndex = _startIndex + _pagesize;
        _endIndex = _endIndex + _pagesize;
    }

    this.previousPage = function() {
        _startIndex = _startIndex - _pagesize;
        _endIndex = _endIndex - _pagesize;
    }

    this.firstPage = function() {
        var _startIndex = 0;
        var _endIndex = (_startIndex + _pagesize) - 1;
    }

    this.getAllData = function() {
        return _data;
    }

    var isFirstPage = function() {
        return _startIndex <= 0;
    }

    var isLastPage = function() {
        return _endIndex >= (_data.length - 1);
    }

    this.toggleControl = function() {
        if( _data.length <= _pagesize ) {
            $('.pagingCtrl').prop('disabled', true);
        } else {
            if( isFirstPage() ) {
                $('.prevButton').prop('disabled', true);
                $('.nextButton').prop('disabled', false);
            } else if( isLastPage() ) {
                $('.prevButton').prop('disabled', false);
                $('.nextButton').prop('disabled', true);
            } else {
                $('.pagingCtrl').prop('disabled', false);
            }
        }
    }
}
