import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
// Import Salary__c field
import SALARY from '@salesforce/schema/Job_Application__c.Salary__c';
import getFedIncomeTax from '@salesforce/apex/TakeHomePayEstimationCal.calculatorFedIncomeTax';
import getSocialSecurityTax from '@salesforce/apex/TakeHomePayEstimationCal.calculatorSocialSecurityTax';
import getMedicareWithholding from '@salesforce/apex/TakeHomePayEstimationCal.calculatorMedicareWithholding';

//const fedIncomeTaxRate = 0.21
//const socialSecurityTaxRate = 0.062
//const medicareWithholdingRate = 0.0145


const fields = [SALARY];

export default class paycheckBreakdown extends LightningElement {
    @api recordId;   // Salesforce will inject the record Id from record page
    annualSalaryAmt = 0;
    fedIncomeTax = 0;
    socialSecurityTax = 0;
    medicareWithholdingRate = 0;

    handleChange(event) {
        this.annualSalaryAmt = Number(event.target.value);
    }
    // Wire to get record
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredJobApp({ error, data }) {
        if (data) {
            this.annualSalaryAmt = data.fields.Salary__c.value;
        } else if (error) {
            console.error(error);
        }
    }
    //Get fedIncomeTax
    @wire(getFedIncomeTax, { annualSalary: '$annualSalaryAmt' })
    wiredFedIncomeTax({ data }) {
        if (data) this.fedIncomeTax = data;
    }
    //Get socialSecurityTax
    @wire(getSocialSecurityTax, { annualSalary: '$annualSalaryAmt' })
    wiredSocialSecurityTax({ data }) {
        if (data) this.socialSecurityTax = data;
    }
    //Get socialSecurityTax
    @wire(getMedicareWithholding, { annualSalary: '$annualSalaryAmt' })
    wiredMedicareWithholding({ data }) {
        if (data) this.medicareWithholdingRate = data;
    }
    //getters
    get federalIncomeTaxAmt() {
        return this.fedIncomeTax;
    }

    get socialSecurityTaxAmt() {
        return this.socialSecurityTax;
    }

    get medicareWithholdingAmt() {
        return this.medicareWithholdingRate;
    }

    get annualTakeHomeAmt() {
        return this.annualSalaryAmt -
            (this.federalIncomeTaxAmt + this.socialSecurityTaxAmt + this.medicareWithholdingAmt);
    }

    get sixMonth() {
        return this.annualTakeHomeAmt / 2;
    }

    get monthly() {
        return this.annualTakeHomeAmt / 12;
    }

    get biweekly() {
        return this.monthly / 2;
    }

    get weekly() {
        return this.monthly / 4;
    }

}
