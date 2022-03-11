public with sharing class tradesDataTableController {
    public static JSONData data;

     @AuraEnabled(cacheable = true)
     public static List < Trade__c > getTrades() {
    	List < Trade__c > trades = new List < Trade__c > ();
    	try {
    		trades = [SELECT Id, Name, Buy_Amount_Form__c, Buy_Currency__c, Date_Booked__c, Rate__c, Sell_Amount__c, Sell_Currency__c FROM Trade__c order by Date_Booked__c Desc];
    	} catch (Exception e) {
    		system.debug('tradesDataTableController -- getTrades --> Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage());
    		system.debug('tradesDataTableController -- getTrades --> Exception Line: ' + e.getLineNumber() + ' Exception StackTrace: ' + e.getStackTraceString());
    	}
    	return trades;
    }

     @AuraEnabled
     public static Map < String, Object > createTrade(String JsonInfo) {
    	Map < String, Object > returnMap = new Map < String, Object > ();
    	try {
            system.debug('tradesDataTableController --> JsonInfo' + JsonInfo);
    		data = (JSONData) JSON.deserializeStrict(JsonInfo, JSONData.class);
            system.debug('tradesDataTableController --> JsonInfo Des' + data);
    		List < Trade__c > tradesToInsert = new list < Trade__c > ();
    		Trade__c trade = new Trade__c();
    		trade.Sell_Currency__c = data.initalRate;
    		trade.Buy_Currency__c = data.finaleRate;
    		trade.Rate__c = data.rate;
    		trade.Sell_Amount__c = data.sellAmount;
    		tradesToInsert.add(trade);
    		insert tradesToInsert;

    	} catch (Exception e) {
    		returnMap.put('result', 'KO');
    		returnMap.put('error', e.getMessage());
    		//String logResponse = e.getMessage();
    		//String logRequest = JSON.serialize(i);
    		//APU003_WriteEAILog.writeLog(logRequest,logResponse,'Outbound', 'Sincrona', true, SYSTEMS, true, o.Id );
    		system.debug('tradesDataTableController -- createTrade --> Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage());
    		system.debug('tradesDataTableController -- createTrade --> Exception Line: ' + e.getLineNumber() + ' Exception StackTrace: ' + e.getStackTraceString());
    		return returnMap;
    	}
    	returnMap.put('result', 'OK');
    	return returnMap;

    }

    public class JSONData {
        public String initalRate { get; set; }
        public String finaleRate { get; set; }
        public Decimal sellAmount { get; set; }
        public Decimal rate { get; set; }
        public JSONData (){}
    }
}