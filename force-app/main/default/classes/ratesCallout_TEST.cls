@isTest
private with sharing class ratesCallout_TEST {
        private static final String initRate = 'EUR';
        private static final String finRate = 'EUR';

        @isTest static void successResponse() {
            Test.setMock( HttpCalloutMock.class, new fixetIoMockOk());
            Map < String, Object > result = ratesCallout.retrieveRates(initRate, finRate);
            system.assert(result.get('rate')==1.000000,'The excpeted rate arrived');
        }
        @isTest
        static void errorResponse() {
            Map < String, Object > result = new Map < String, Object >();
            Test.setMock( HttpCalloutMock.class, new fixetIoMockKo());
            result = ratesCallout.retrieveRates(initRate, finRate);
            system.assert(result.get('result')=='KO','The excpeted KO arrived');


        }
        public class fixetIoMockOk implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                rate Rates = new rate();
                Rates.EUR = 1.000000;
                Rates.GBP = 0.882047;
                Rates.USD = 1.23396;
                body BodyToSerialize = new body();
                BodyToSerialize.success = true;
                BodyToSerialize.timestamp = 1519296206;
                BodyToSerialize.base = 'EUR';
                BodyToSerialize.rates = Rates;
                res.setHeader('Content-Type', 'application/json');
                res.setBody(json.serialize(BodyToSerialize));
                res.setStatusCode(200);
                return res;
            }
        }
    
        public class fixetIoMockKo implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setStatusCode(400);
                return res;
            }
        }

        public class Body {
            public boolean success;
            public integer timestamp;
            public string base;
            public rate rates;
        }
        public class rate {
            public decimal EUR;
            public decimal GBP;
            public decimal USD;
        }
}