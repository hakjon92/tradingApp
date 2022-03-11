@isTest
private class  tradesDataTableController_TEST {
    @TestSetup 
    static void testSetup(){
            List < Trade__c > tradesToInsert = new list < Trade__c > ();
    		Trade__c trade = new Trade__c();
    		trade.Sell_Currency__c = 'EUR';
    		trade.Buy_Currency__c = 'GBP';
    		trade.Rate__c = 123.45;
    		trade.Sell_Amount__c = 12213;
    		tradesToInsert.add(trade);
    		insert tradesToInsert;
    }
    @isTest
    private static void getTradesTest() {
        List < Trade__c > trades = tradesDataTableController.getTrades();
        System.assert(!trades.isempty(), 'Expected trades were retrieved');
    }

    @isTest
    private static void createTrade() {
        tradesDataTableController.JSONData jsonInfo = new tradesDataTableController.JSONData();
        jsonInfo.initalRate = 'EUR';
        jsonInfo.finaleRate = 'GBP';
        jsonInfo.sellAmount = 12213;
        jsonInfo.rate = 123.45;
        Map < String, Object > result = tradesDataTableController.createTrade(json.serialize(jsonInfo));
        System.assert(result.get('result')=='OK', 'Expected trades were created');
    }
}