import { LightningElement, track } from 'lwc';
import saveFile from '@salesforce/apex/LeadLeakageController.checkLeadExistence';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
//import XLSX from '@salesforce/resourceUrl/xlsxzip'; 
//import { loadScript } from 'lightning/platformResourceLoader';

const previewColumns = [
    { label: 'Phone', fieldName: 'Phone' },
    { label: 'Project', fieldName: 'Project' }
];

const resultColumns = [
    { label: 'Phone', fieldName: 'phone' },
    { label: 'Project', fieldName: 'project' },
    { label: 'Existance', fieldName: 'existance' },
    { label: 'Exists', fieldName: 'exists' },
    { label: 'Allocated Project', fieldName: 'allocatedProject' },
    { label: 'Last Sub Source', fieldName: 'lastSubSource' },
    { label: 'Owner Name', fieldName: 'ownerName' },
    { label: 'Lead Source', fieldName: 'leadSource' },
    { label: 'Lead Source Secondary', fieldName: 'leadSourceSecondary' },
    { label: 'Sub Source', fieldName: 'subSource' },
    { label: 'Sub Source Secondary', fieldName: 'subSourceSecondary' },
    { label: 'Lead Owner Secondary', fieldName: 'leadOwnerSecondary' }
];


export default class LeadLeakageCmp extends NavigationMixin(LightningElement) {
    @track previewColumns = previewColumns;
    @track resultColumns = resultColumns;

    @track fileName = '';
    @track UploadFile = 'Upload CSV File';
    @track showLoadingSpinner = false;
    @track isPreview = false;
    @track isData = false;

    resultData;
    selectedRecords;
    @track csvData = [];
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    MAX_FILE_SIZE = 1500000;

    /*connectedCallback() {
        loadScript(this, XLSX + '/xlsx.full.min.js')
            .then(() => {
                console.log('SheetJS loaded successfully');
            })
            .catch(error => {
                console.error('Error loading SheetJS:', error);
                this.showNotification('Error', 'SheetJS library could not be loaded.', 'error');
            });
    }*/

    handleFilesChange(event) {
        if (event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.handleFileReaderCheck();
        }
    }

    handleFileReaderCheck() {
        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = () => {
            const fileContents = this.fileReader.result;
            const allLines = fileContents.split('\n');
            const headers = allLines[0].split(',');
            this.handleCheckAccept(headers);
        };
        this.fileReader.readAsText(this.filesUploaded[0]);
    }

    handleCheckAccept(headers) {
        if (headers[0].toUpperCase() === 'PHONE' && headers[1].toUpperCase() === 'PROJECT\r') {
            this.fileName = this.filesUploaded[0].name;
        } else {
            this.fileName = '';
            this.showNotification('Error', 'Format Error! Please check the format.', 'error');
        }
        this.showLoadingSpinner = false;
    }

    handlePreview() {
        if (this.filesUploaded.length > 0) {
            this.parseCSVFile();
        } else {
            this.fileName = 'Please select a CSV file to upload!!';
        }
    }

    parseCSVFile() {
        if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            console.log('File Size is too large');
            return;
        }
        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = () => {
            const fileContents = this.fileReader.result;
            this.csvData = this.parseCSV(fileContents);
            this.showLoadingSpinner = false;
            this.isPreview = true;
            this.isData = false;
        };
        this.fileReader.readAsText(this.filesUploaded[0]);
    }

    parseCSV(csv) {
        const lines = csv.split('\n');
        const result = [];
        const headers = lines[0].split(',');
        for (let i = 1; i < lines.length; i++) {
            const obj = {};
            const currentline = lines[i].split(',');

            for (let j = 0; j < headers.length; j++) {
                obj[headers[j].trim()] = currentline[j] ? currentline[j].trim() : '';
            }
            result.push(obj);
        }
        return result;
    }

    handlesampleDownload() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/sampleBulkHQEXCEL'
            }
        }).then(generatedUrl => {
            window.open(generatedUrl);
        });
    }

    handleUpload() {
        if (this.filesUploaded.length > 0) {
            this.uploadFile();
        } else {
            this.fileName = 'Please select a CSV file to upload!!';
        }
    }

    uploadFile() {
        if (this.filesUploaded[0].size > this.MAX_FILE_SIZE) {
            console.log('File Size is too large');
            return;
        }

        this.showLoadingSpinner = true;
        this.fileReader = new FileReader();
        this.fileReader.onloadend = () => {
            this.fileContents = this.fileReader.result;
            this.saveFile();
        };
        this.fileReader.readAsText(this.filesUploaded[0]);
    }

    showNotification(titleText, messageText, variant) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: messageText,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

    saveFile() {        
        saveFile({
            base64Data: JSON.stringify(this.fileContents),
            fileName: this.fileName,
        })
            .then(result => {
                    this.isPreview = false;
                    this.isData = false;
                    this.showLoadingSpinner = false;
                    this.showNotification('Success!!', `${this.filesUploaded[0].name} processed Successfully and send results to your mail Id`, 'success');
            })
            .catch(error => {
                console.error(error);
                this.showLoadingSpinner = false;
                let errorMessage = 'Unknown error';
                if (error.body && error.body.message) {
                    const errorParts = error.body.message.split(';')[1].trim();
                    if (errorParts.length > 0) {
                        errorMessage = errorParts.split('first error:')[1].trim().split('[')[0].trim();
                    }
                    this.showNotification('Error!', errorMessage, 'error');
                }
            });
    }

    /*exportToExcel() {
        const tableData = this.resultData;
        const filename = 'ExportToExcel.xlsx';
        const workbook = XLSX.utils.book_new();
        const worksheetData = tableData.map(record => ({
            phone: record.phone,
            project: record.project,
            existance: record.existance,
            exists: record.exists
        }));

        const worksheet = XLSX.utils.json_to_sheet(worksheetData);
        XLSX.utils.book_append_sheet(workbook, worksheet, 'ExportToExcel');
        const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
        const blob = new Blob([excelBuffer], { type: 'application/octet-stream' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = filename;
        a.click();
        URL.revokeObjectURL(a.href);
    }*/
}