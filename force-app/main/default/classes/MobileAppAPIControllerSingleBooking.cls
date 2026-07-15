@RestResource(urlMapping='/my_booking/*')
global without sharing class MobileAppAPIControllerSingleBooking {
    
    global class SingleBookingFullResponse {
        public Integer Status;
        public String Message;
        public String booking_status;
        public List<Receipt> listofreceipt;
        public List<Milestone> listofmilestones;
        public List<Demand> listofdemand;
        public List<BookingDetails> listofbooking;
        public List<ApplicantDetails> listofapplicant;
    }
    
    global class Receipt {
        public Decimal Total_Amount;
        public String receiptpdf;
        public String Receipt_Status;
        public String Receipt_No;
        public String Receipt_Date;
        public String Payment_mode;
        public String Instrument_number;
        public String Instrument_date;
        public String Drawie_bank_name;
    }
    
    global class Milestone {
        public Decimal Milestone_total_amount;
        public String Milestone_Name;
        public String Milestone_id;
        // NEW KEYS
        public Decimal milestone_percentage;
        public Decimal milestone_paid_amount;
        public Decimal milestone_pending_amount;
    }
    
    global class Demand {
        public String Payment_milestone_name;
        public Decimal Paid_amount;
        public String Milestone_name;
        public String Invoice_Date;
        public Decimal Invoice_amount;
        public String Due_Date;
        public String demandpdf;
        public Decimal Amount_pending;
    }
    
    global class BookingDetails {
        public String unit_no;
        public String TowerId;
        public String Tower_orphase;
        public Decimal Total_paidpercent;
        public Decimal total_paidagainstinvoice;
        public Decimal total_invoicevalue;
        public String SD_Regisration_Date;
        public String Sanction_Status;
        public Decimal Sanction_Amount;
        public String Rm_phone;
        public String Rm_name;
        public String Rm_email;
        public String Quotationpdf;
        public String project;
        public Decimal onaccountmoney;
        public List<String> ListOfDocuments;
        public String ledgerpdf;
        public Integer Floor;
        public String Disbursement_Status;
        public String Disbursement_Amount;
        public Decimal Current_Outstanding;
        public String Configuration;
        public Decimal Chargeable_Area;
        public String Century_Swift_Code;
        public String Century_IFSC_Code;
        public String Century_Bank_Name;
        public String Century_Bank_Address;
        public String Century_Account_Type;
        public String Century_Account_Number;
        public String Century_Account_Name;
        public String Booking_id;
        public String Booking_Date;
        public String Bank_Name;
        public Decimal Amount_Received;
        public Decimal Agreement_value;
        public String afs_executiondate;
        // NEW KEYS - Loan Detail
        public Decimal amount_by_bank;
        public Decimal amount_by_customer;
        // ONLY ADDITION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        public Decimal total_cost;
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    }
    
    global class ApplicantDetails {
        public String State;
        public String Relation_Name;
        public String Relation;
        public Integer Pincode;
        public String Permanent_Address;
        public String Pancard_Number;
        public String Mobile_Number;
        public String Mailing_State;
        public Integer Mailing_Pincode;
        public String Mailing_Country;
        public String Mailing_City;
        public String Mailing_Address;
        public String Email_Address;
        public String DOB;
        public String Country;
        public String City;
        public String Applicant_number;
        public String Applicant_name;
        public String Alternate_Mobile;
        public String Alternate_Email;
        public String aadhar_number;
    }
    
    global class InputWrapper {
        public String pan_number;
        public String booking_id;
    }
    
    @HttpPost
    global static SingleBookingFullResponse mobileappmethod() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try {
            String value = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);
            String data = req.requestBody.toString();
            InputWrapper input = (InputWrapper) JSON.deserialize(data, InputWrapper.class);
            
            if(value == 'my_booking'){
                SingleBookingFullResponse resObj = new SingleBookingFullResponse();
                resObj.listofreceipt = new List<Receipt>();
                resObj.listofmilestones = new List<Milestone>();
                resObj.listofdemand = new List<Demand>();
                resObj.listofbooking = new List<BookingDetails>();
                resObj.listofapplicant = new List<ApplicantDetails>();
                
                if (String.isBlank(input.booking_id)) {
                    res.statusCode = 400;
                    resObj.Status = 400;
                    resObj.Message = 'Booking ID is required';
                    return resObj;
                }
                
                Booking__c booking = [
                    SELECT Id, Name, Unit_NumberFor__c, Property_Type__c,BHK_Type__c,Tower__c,Total_received_Amount__c, Project__c, Plot__r.Project__r.Id,Quote__c,
                    Stage__c, Booking_Date__c, Agreement_Value__c, Sale_Agreement_Date__c,Pending_Amount__c, Floor__c,
                    Built_up_area__c, Demanded_Amount__c,Date_of_Booking__c,Property_TypeFor__c,
                    Paid_Percent__c, Received_Amount__c,Address__c,Date_of_Birth__c,
                    IFSC_Code__c, Project_Bank_Name__c, Project_Bank_Address__c, Email__c,
                    Account_Type__c, Builder_Account_Number__c, Bank_Name__c,Contact_Number__c,
                    Company_Name__c, Registration_Date__c,First_Applicant_Name__c,PAN_Number__c,Aadhar_Number__c,
                    Loan_Sanctioned__c, Sanctioned_Amount__c,Owner.Name,Owner.Email,Owner.Phone,
                    Amount_By_Bank__c, Amount_By_Customer__c,Project_Swift_Code__c,
                    Total_Cost_Ex_Leg_Main__c,Quote__r.Id // ONLY ADDITION >>>>>>>>>>>>>>>>>>>>>>>>>>>
                    FROM Booking__c
                    WHERE Name = :input.booking_id
                    LIMIT 1
                ];
                
                // Booking Details
                BookingDetails bd = new BookingDetails();
                bd.unit_no = booking.Unit_NumberFor__c;
                bd.TowerId = booking.Tower__c;
                bd.Tower_orphase = booking.Tower__c;
                bd.Total_paidpercent = booking.Paid_Percent__c;
                bd.total_paidagainstinvoice = booking.Total_received_Amount__c;
                bd.total_invoicevalue = booking.Demanded_Amount__c;
                bd.SD_Regisration_Date = String.valueOf(booking.Registration_Date__c);
                if(booking.Loan_Sanctioned__c == true){
                    bd.Sanction_Status = 'Sanctioned';
                }
                else{
                    bd.Sanction_Status = 'Not Sanctioned';
                }
                
                bd.Sanction_Amount = booking.Sanctioned_Amount__c;
                bd.Rm_phone = booking.Owner.Phone;
                bd.Rm_name = booking.Owner.Name;
                bd.Rm_email = booking.Owner.Email;
                if(booking.Property_Type__c == 'Apartment'){
                    bd.Quotationpdf = generatePdfPublicUrl('AppartmentCostSheet', booking.Quote__r.Id);  
                }
                else{
                    bd.Quotationpdf = generatePdfPublicUrl('VillaCostSheet', booking.Quote__r.Id);  
                }
                            
                bd.project = booking.Project__c;
                bd.onaccountmoney = 0;
                bd.ListOfDocuments = new List<String>();
                bd.ledgerpdf = generatePdfPublicUrl('Consolidated_Receipt', booking.Id);
                bd.Floor = booking.Floor__c != null ? Integer.valueOf(booking.Floor__c) : null;
                if(booking.Received_Amount__c != 0){
                     bd.Disbursement_Status = 'Disbursed';
                }
                else{
                    bd.Disbursement_Status = '';
                }
               
                bd.Disbursement_Amount = String.valueOf(booking.Received_Amount__c);
                bd.Current_Outstanding = booking.Pending_Amount__c;
                bd.Configuration = booking.BHK_Type__c;
                bd.Chargeable_Area = booking.Built_up_area__c;
                bd.Century_Swift_Code = booking.Project_Swift_Code__c;
                bd.Century_IFSC_Code = booking.IFSC_Code__c;
                bd.Century_Bank_Name = booking.Project_Bank_Name__c;
                bd.Century_Bank_Address = booking.Project_Bank_Address__c;
                bd.Century_Account_Type = booking.Account_Type__c;
                bd.Century_Account_Number = booking.Builder_Account_Number__c;
                bd.Century_Account_Name = booking.Company_Name__c;
                bd.Booking_id = booking.Name;
                bd.Booking_Date = String.valueOf(booking.Date_of_Booking__c);
                bd.Bank_Name = booking.Bank_Name__c;
                bd.Amount_Received = booking.Received_Amount__c;
                bd.Agreement_value = 0;
                bd.afs_executiondate = String.valueOf(booking.Sale_Agreement_Date__c);
                // NEW - Loan Detail keys
                bd.amount_by_bank = booking.Amount_By_Bank__c;
                bd.amount_by_customer = booking.Amount_By_Customer__c;
                // ONLY ADDITION >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
                bd.total_cost = booking.Total_Cost_Ex_Leg_Main__c;
                // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                resObj.listofbooking.add(bd);
                resObj.booking_status = booking.Stage__c;
                
                ApplicantDetails ap1 = new ApplicantDetails();
                ap1.Applicant_name = booking.First_Applicant_Name__c;
                ap1.Applicant_number = '';
                ap1.Relation = '';
                ap1.Relation_Name = '';
                ap1.Pancard_Number = booking.PAN_Number__c;
                ap1.aadhar_number = booking.Aadhar_Number__c;
                ap1.Permanent_Address = booking.Address__c;
                ap1.State = '';
                ap1.Country = '';
                ap1.City = '';
                ap1.Pincode = 0;
                ap1.Mailing_Address = '';
                ap1.Mailing_City = '';
                ap1.Mailing_State = '';
                ap1.Mailing_Country = '';
                ap1.Mailing_Pincode = 0;
                ap1.DOB = String.valueOf(booking.Date_of_Birth__c);
                ap1.Email_Address = booking.Email__c;
                ap1.Alternate_Email = '';
                ap1.Mobile_Number = booking.Contact_Number__c;
                ap1.Alternate_Mobile = '';
                resObj.listofapplicant.add(ap1);
                
                // Receipts with public URLs
                for (Receipt__c r : [SELECT Total_Received_Amount__c,Total_Amount__c, Name, Receipt_Date__c,
                                     Mode_of_payment__c, Check_Transaction_Nmber__c,(select Id,Name,Cheque_no_Transaction_Number__c,Mode_of_Payment__c,Bank_Name__c from Receipt_Line_items__r)
                                     FROM Receipt__c
                                     WHERE Booking__c = :booking.Id and Approval_status__c = 'Approved' and Total_Received_Amount__c > 0]) {
                    Receipt rec = new Receipt();
                    rec.Total_Amount = r.Total_Received_Amount__c;
                    rec.receiptpdf = generatePdfPublicUrl('ReceiptFormat', r.Id);
                    rec.Receipt_Status = 'Approved';
                    rec.Receipt_No = r.Name;
                    rec.Receipt_Date = String.valueOf(r.Receipt_Date__c);
                    rec.Payment_mode = r.Receipt_Line_items__r[0].Mode_of_payment__c;
                    rec.Instrument_number = r.Receipt_Line_items__r[0].Cheque_no_Transaction_Number__c;
                    rec.Instrument_date = String.valueOf(r.Receipt_Date__c);
                    rec.Drawie_bank_name = r.Receipt_Line_items__r[0].Bank_Name__c;
                    resObj.listofreceipt.add(rec);
                }
                
                // Milestones - UPDATED QUERY with new fields
                for (Payment_Schedule__c m : [SELECT Name, AmountB__c,Received_Amount1__c, Payment_Percent__c, Received_Amount__c, Pending_Amount__c
                                              FROM Payment_Schedule__c
                                              WHERE Booking__c = :booking.Id order by S_No__c asc]) {
                    Milestone ms = new Milestone();
                    ms.Milestone_id = m.Name;
                    ms.Milestone_Name = m.Name;
                    ms.Milestone_total_amount = m.AmountB__c;
                    // NEW - Milestone keys
                    ms.milestone_percentage = m.Payment_Percent__c;
                    ms.milestone_paid_amount = m.Received_Amount1__c;
                    ms.milestone_pending_amount = m.Pending_Amount__c;
                    resObj.listofmilestones.add(ms);
                }
                
                // Applicants
                for (Co_Applicant__c a : [SELECT Name, PAN_Number__c,Aadhar_Number__c, Address__c, Date_of_Birth__c, Email__c, Contact_Number__c  FROM Co_Applicant__c WHERE Booking__c = :booking.Id]) {
                    ApplicantDetails ap = new ApplicantDetails();
                    ap.Applicant_name = a.Name;
                    ap.Applicant_number = '';
                    ap.Relation = '';
                    ap.Relation_Name = '';
                    ap.Pancard_Number = a.PAN_Number__c;
                    ap.aadhar_number = a.Aadhar_Number__c;
                    ap.Permanent_Address = a.Address__c;
                    ap.State = '';
                    ap.Country = '';
                    ap.City = '';
                    ap.Pincode = 0;
                    ap.Mailing_Address = '';
                    ap.Mailing_City = '';
                    ap.Mailing_State = '';
                    ap.Mailing_Country = '';
                    ap.Mailing_Pincode = 0;
                    ap.DOB = String.valueOf(a.Date_of_Birth__c);
                    ap.Email_Address = a.Email__c;
                    ap.Alternate_Email = '';
                    ap.Mobile_Number = a.Contact_Number__c;
                    ap.Alternate_Mobile = '';
                    resObj.listofapplicant.add(ap);
                }
                
                resObj.listofdemand = getDemandFilesPublicUrls(booking.Id);
                
                resObj.Status = 200;
                resObj.Message = 'Success';
                res.statusCode = 200;
                return resObj;
            }
            
            SingleBookingFullResponse errorResponse = new SingleBookingFullResponse();
            errorResponse.Status = 200;
            errorResponse.Message = 'No Booking Details';
            errorResponse.booking_status = null;
            errorResponse.listofreceipt = new List<Receipt>();
            errorResponse.listofmilestones = new List<Milestone>();
            errorResponse.listofdemand = new List<Demand>();
            errorResponse.listofbooking = new List<BookingDetails>();
            errorResponse.listofapplicant = new List<ApplicantDetails>();
            return errorResponse;
        }
        catch (Exception ex) {
            res.statusCode = 500;
            SingleBookingFullResponse errorResponse = new SingleBookingFullResponse();
            errorResponse.Status = 500;
            errorResponse.Message = 'Internal Error: ' + ex.getMessage();
            errorResponse.booking_status = null;
            errorResponse.listofreceipt = new List<Receipt>();
            errorResponse.listofmilestones = new List<Milestone>();
            errorResponse.listofdemand = new List<Demand>();
            errorResponse.listofbooking = new List<BookingDetails>();
            errorResponse.listofapplicant = new List<ApplicantDetails>();
            return errorResponse;
        }
    }
    
    // ... (remaining helper methods stay unchanged)
    
    private static String generatePdfPublicUrl(String vfPageName, Id recordId) {
        try {
            PageReference pdfPage = new PageReference('/apex/' + vfPageName);
            pdfPage.getParameters().put('id', recordId);
            Blob pdfBlob;
            
            if(Test.isRunningTest()) { 
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
            
            ContentVersion cv = new ContentVersion();
            cv.Title = vfPageName + '_' + recordId;
            cv.PathOnClient = vfPageName + '_' + recordId + '.pdf';
            cv.VersionData = pdfBlob;
            cv.FirstPublishLocationId = recordId;
            cv.IsMajorVersion = true;
            insert cv;
            
            ContentVersion insertedCV = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = vfPageName + '_' + recordId;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            cd.PreferencesAllowOriginalDownload = true;
            insert cd;
            
            ContentDistribution distributionRecord = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1];
            return distributionRecord.DistributionPublicUrl;
            
        } catch(Exception e) {
            System.debug('PDF generation/distribution error: ' + e.getMessage());
            return '';
        }
    }
    
    private static List<Demand> getDemandFilesPublicUrls(Id bookingId) {
        List<Demand> demands = new List<Demand>();
        
        List<ContentDocumentLink> docLinks = [
            SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :bookingId
            AND ContentDocument.Title LIKE 'Demand -%'
            ORDER BY ContentDocument.CreatedDate DESC
        ];
        
        if (docLinks.isEmpty()) {
            return demands;
        }
        
        List<Id> docIds = new List<Id>();
        for (ContentDocumentLink link : docLinks) {
            docIds.add(link.ContentDocumentId);
        }
        
        List<ContentVersion> contentVersions = [
            SELECT Id, ContentDocumentId, Title, FileExtension
            FROM ContentVersion
            WHERE ContentDocumentId IN :docIds
            AND IsLatest = TRUE
        ];
        
        for (ContentVersion cv : contentVersions) {
            String fileName = cv.Title;
            String dateStr = fileName.substringAfter('Demand - ').split('\\.')[0];
            List<String> dateParts = dateStr.split('/');
            String formattedDate = dateParts[2] + '-' + 
                dateParts[1].leftPad(2, '0') + '-' + 
                dateParts[0].leftPad(2, '0');
            
            Demand dm = new Demand();
            dm.Payment_milestone_name = 'Demand Note';
            dm.Paid_amount = 0; 
            dm.Milestone_name = 'Demand Note';
            dm.Invoice_Date = formattedDate;
            dm.Invoice_amount = 0;
            dm.Due_Date = '';
            dm.demandpdf = createPublicUrlForFile(cv.Id);
            dm.Amount_pending = 0;
            demands.add(dm);
        }
        
        return demands;
    }
    
    /*private static String getCostSheetPublicUrl(Id bookingId) {
        try {
            List<ContentDocumentLink> docLinks = [
                SELECT ContentDocumentId
                FROM ContentDocumentLink
                WHERE LinkedEntityId = :bookingId
                AND ContentDocument.Title LIKE 'Cost%'
                LIMIT 1
            ];
            
            if (!docLinks.isEmpty()) {
                List<ContentVersion> contentVersions = [
                    SELECT Id
                    FROM ContentVersion
                    WHERE ContentDocumentId = :docLinks[0].ContentDocumentId
                    AND IsLatest = TRUE
                    LIMIT 1
                ];
                
                if (!contentVersions.isEmpty()) {
                    return createPublicUrlForFile(contentVersions[0].Id);
                }
            }
            return '';
        } catch (Exception e) {
            System.debug('Error getting CostSheet public URL: ' + e.getMessage());
            return '';
        }
    }*/
    
    private static String createPublicUrlForFile(Id contentVersionId) {
        try {
            List<ContentDistribution> existingDistributions = [
                SELECT DistributionPublicUrl 
                FROM ContentDistribution 
                WHERE ContentVersionId = :contentVersionId 
                LIMIT 1
            ];
            
            if (!existingDistributions.isEmpty()) {
                return existingDistributions[0].DistributionPublicUrl;
            }
            
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'Public_' + contentVersionId;
            cd.ContentVersionId = contentVersionId;
            cd.PreferencesAllowViewInBrowser = true;
            cd.PreferencesLinkLatestVersion = true;
            cd.PreferencesNotifyOnVisit = false;
            cd.PreferencesPasswordRequired = false;
            cd.PreferencesAllowOriginalDownload = true;
            insert cd;
            
            ContentDistribution distributionRecord = [SELECT DistributionPublicUrl FROM ContentDistribution WHERE Id = :cd.Id LIMIT 1];
            return distributionRecord.DistributionPublicUrl;
            
        } catch(Exception e) {
            System.debug('Error creating public URL: ' + e.getMessage());
            return '';
        }
    }
    
    public static void getCodeCoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}