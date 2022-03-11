import { api, track, wire, LightningElement }from 'lwc';
import getTradesList from '@salesforce/apex/tradesDataTableController.getTrades';
import retrieveRates from '@salesforce/apex/ratesCallout.retrieveRates';
import createTrade from '@salesforce/apex/tradesDataTableController.createTrade';

const columns = [
  { label: 'Sell CCY', fieldName: 'Sell_Currency__c', type: 'text',  editable: false,  hideDefaultActions: "true" },
  { label: 'Sell Amount', fieldName: 'Sell_Amount__c', type: 'number' ,  editable: false , hideDefaultActions: "true", typeAttributes: { minimumFractionDigits: '2' },  cellAttributes: { alignment: 'left' }},
  { label: 'Buy CCY', fieldName: 'Buy_Currency__c', type: 'text',  editable: false , hideDefaultActions: "true"},
  { label: 'Buy Amount', fieldName: 'Buy_Amount_Form__c', type: 'number',  editable: false , hideDefaultActions: "true" , typeAttributes: { minimumFractionDigits: '2' },  cellAttributes: { alignment: 'left' }},
  { label: 'Rate', fieldName: 'Rate__c', type: 'number',  editable: false , hideDefaultActions: "true", typeAttributes: { minimumFractionDigits: '4' } ,  cellAttributes: { alignment: 'left' }},
  { label: 'Date Booked', fieldName: 'Date_Booked__c', type: 'date' ,  editable: false , hideDefaultActions: "true", 
    typeAttributes: {day: '2-digit', month: '2-digit', year: 'numeric',  hour: '2-digit', minute: '2-digit'}}
];

export
default class tradingTable extends LightningElement {@track data = [];@track columns = columns;@track rateValue;@track sellCurrr;@track buyAmount;
	isCssLoaded = false
	isOpenModal = false;
	isLoading = false;
	valueSellCurr = '';
	valueBuyCurr = '';
	clickedButtonLabel;

  get options() {
    return [
        { label: 'EUR', value: 'EUR' },
        { label: 'USD', value: 'USD' },
        { label: 'GBP', value: 'GBP' },
    ];
  }

	displayModal() {
		console.log('tradingTable -- displayModal');
		this.openModal();
	}
	openModal() {
		console.log('tradingTable -- openModal');
		this.isOpenModal = true;
	}
	closeModal() {
		this.isOpenModal = false;
	}


	//wiring the apex method to a function 
	@wire(getTradesList, {})
	ApexResponse({
		error, data
	}) {
		if (data) {
			this.data = data;
		} else if (error) {}
	}

	handleChangesSell(event) {
		this.value = event.detail.value;
		console.log('handleChangesSell: ', this.value)
		let obj = this.getvalueToSend();
		if (obj.initalRate && obj.finaleRate) this.retrieveRatesLwc(obj);
	}
	handleChangesBuy(event) {
		this.value = event.detail.value;
		console.log('handleChangesBuy: ', this.value);
		let obj = this.getvalueToSend();
		if (obj.initalRate && obj.finaleRate) this.retrieveRatesLwc(obj);
	}


	calculateBuyAmount(event) {
		this.value = event.detail.value;
		console.log('handleChangesBuy: ', this.value);
		let obj = this.getvalueToCalcuateBuyAmount();
		if (obj.sellAmount && this.rateValue) this.buyAmount = parseFloat(obj.sellAmount) * parseFloat(this.rateValue);
	}
	retrieveRatesLwc(obj) {
		console.log('tradingTable -- retrieveRatesLwc --> valueSellCurr: ', obj.initalRate);
		console.log('tradingTable -- retrieveRatesLwc --> valueBuyCurr: ', obj.finaleRate);
		retrieveRates({ initialRate: obj.initalRate, finaleRate: obj.finaleRate}).then(result =>{
			console.log('tradingTable -- retrieveRatesLwc --> result: ', result);
			if (result.error || result.result == 'KO') {
        console.error(result.error);
      } else 
      {
				this.rateValue = result.rate;
				this.isLoading = false;
				if (obj.sellAmount && this.rateValue) this.buyAmount = parseFloat(obj.sellAmount) * parseFloat(this.rateValue);
			}
		}).
		catch (err =>{
			console.error('tradingTable -- retrieveRatesLwc -- err',err);
		})
	}

	createRecord() {
		console.log('tradingTable -- createRecord');
		let obj = this.getvalueToCreate();
		console.log('tradingTable -- createRecord --> obj:', JSON.stringify(obj));
		if (obj && obj.initalRate && obj.finaleRate && obj.sellAmount && obj.rate) this.createTradesLwc(obj);
		//this.isOpenModal = false;
	}

	createTradesLwc(obj) {
		console.log('tradingTable -- createTradesLwc');
		createTrade({
			JsonInfo: JSON.stringify(obj)
		}).then(result =>{
			console.log('tradingTable -- createTradesLwc --> result: ', result);
			if (result.error || result.warning) {} else {
				console.log('@@createTrade success', result);
				window.location.reload(true);
			}
		}).
		catch (err =>{
			console.error('tradingTable -- createRecord -- err',err);
		})
	}



	getvalueToSend() {
		var sellCur = this.template.querySelector('[data-id="sellCurr"]');
		var buyCur = this.template.querySelector('[data-id="buyCurr"]');
		var sellAmount = this.template.querySelector('[data-id="sellAmount"]');
		var objectReturn = {
			initalRate: sellCur.value,
			finaleRate: buyCur.value,
			sellAmount: sellAmount.value
		}
		console.log('getvalueToSend:', objectReturn);
		return objectReturn;
	}

	getvalueToCalcuateBuyAmount() {
		var sellAmount = this.template.querySelector('[data-id="sellAmount"]');
		var objectReturn = {
			sellAmount: sellAmount.value
		}
		console.log('getvalueToCalcuateBuyAmount:', objectReturn);
		return objectReturn;
	}

	getvalueToCreate() {
		var sellCur = this.template.querySelector('[data-id="sellCurr"]');
		var buyCur = this.template.querySelector('[data-id="buyCurr"]');
		var sellAmount = this.template.querySelector('[data-id="sellAmount"]');
		var objectReturn = {
			initalRate: sellCur.value,
			finaleRate: buyCur.value,
			sellAmount: sellAmount.value,
			rate: this.rateValue
		}
		console.log('getvalueToSend:', objectReturn);
		return objectReturn;
	}
}