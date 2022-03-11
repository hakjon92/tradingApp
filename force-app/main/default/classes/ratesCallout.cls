public with sharing class ratesCallout {

	@AuraEnabled(cacheable = true)
	public static Map < String, Object > retrieveRates(string initialRate, string finaleRate) {
		Map < String, Object > returnMap = new Map < String, Object > ();
		system.debug('retrieveRates --> initialRate' + initialRate);
		system.debug('retrieveRates --> finaleRate' + finaleRate);
		WrapperResponse wrapRes = new WrapperResponse();
		HttpRequest req = new HttpRequest();
		decimal rate = 0;
		string apiKey = system.label.apiKey;

		try {
			String str = '', str2 = '';
			string Endpoint = 'http://data.fixer.io/api/latest?access_key='+apiKey+'&base=' + initialRate + '&symbols=' + finaleRate;
			system.debug('retrieveRates --> Endpoint' + Endpoint);
			req.setEndpoint(Endpoint);
			req.setMethod('GET');
			Http http = new Http();
			HTTPResponse response = http.send(req);
			wrapRes.StatusCode = response.getStatusCode();
			if (response.getStatusCode() != 200) {
				wrapRes.errorMessage = response.getStatusCode() + ' ' + response.getStatus();
				System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
				returnMap.put('result', 'KO');
				returnMap.put('errorCode', response.getStatusCode());
				returnMap.put('error', response.getStatus());
			} else {
				str = response.getBody();
				//WrapperResult wrapObj = (WrapperResult)Json.deserialize(str,WrapperResult.class);
				system.debug('retrieveRates --> wrapRes' + wrapRes);
				system.debug('retrieveRates --> str' + str);
				str2 = str.substringBetween(finaleRate + '":', '}');
				system.debug('retrieveRates --> str2' + str2);
				if (!string.isblank(str2) && decimal.valueof(str2) != null) rate = decimal.valueof(str2);
				returnMap.put('result', 'OK');
				returnMap.put('rate',rate);
			}

		} catch (Exception e) {
			system.debug('ratesCallout -- retrieveRates --> Exception Type: ' + e.getTypeName() + ' Exception Message: ' + e.getMessage());
			system.debug('ratesCallout -- retrieveRates --> Exception Line: ' + e.getLineNumber() + ' Exception StackTrace: ' + e.getStackTraceString());
			returnMap.put('result', 'KO');
			returnMap.put('error', e.getMessage());
		}
		return returnMap;

	}

	private class WrapperResponse {
		//public WrapperResult responseContent;
		public String errorMessage;
		public Integer StatusCode;
	}

	/*public class WrapperResult {
		public boolean success;
		//public integer timestamp;
		//public string base;
		//public date date;
	}*/

}