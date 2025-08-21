import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
// Import Salary__c field
import SALARY from '@salesforce/schema/Job_Application__c.Salary__c';

    const fedIncomeTaxRate = 0.21
    const socialSecurityTaxRate = 0.062
    const medicareWithholdingRate = 0.0145
    const fields = [SALARY];

export default class paycheckBreakdown extends LightningElement {
    @api recordId;   // Salesforce will inject the record Id from record page
    annualSalaryAmt = 0;

    // Wire to get record
    @wire(getRecord, { recordId: '$recordId', fields })
        wiredJobApp({ error, data }) {
            if (data) {
                this.annualSalaryAmt = data.fields.Salary__c.value;
            } else if (error) {
                console.error(error);
            }
        }

    handleChange(event) {
        this.annualSalaryAmt = Number(event.target.value);
    }
    // getters
    get federalIncomeTaxAmt() {
        return this.annualSalaryAmt * fedIncomeTaxRate;
    }

    get socialSecurityTaxAmt() {
        return this.annualSalaryAmt * socialSecurityTaxRate;
    }

    get medicareWithholdingAmt() {
        return this.annualSalaryAmt * medicareWithholdingRate;
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
