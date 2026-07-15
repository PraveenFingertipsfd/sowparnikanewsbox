@isTest
public class BookingHandlerTest {

   @isTest
     public static void Bookingtest()
     {
         set<string> recIds = new set<string>();
         recIds.add(userinfo.getUserEmail());
         CustomNotificationType ct= [SELECT Id,DeveloperName FROM CustomNotificationType LIMIT 1];
        /* Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Company = 'testCompany';
        ld.phone ='9876543459';
        ld.LeadSource = 'Website';
        ld.Email ='test@gmail.com';
        insert ld;
         */
         Project__c pjt = new Project__c();
        pjt.Name = 'Test Project';
         pjt.project__c ='Test Project';
        pjt.Active__c = true;
        insert pjt;
         
         Master_payment_schedule__c msp = new Master_payment_schedule__c();
         msp.Name ='On booking';
         msp.Payment_Percent__c = 50;
         msp.Project__c = pjt.Id;
         msp.Status__c ='Completed';
         insert msp;
         
         Master_payment_schedule__c msp1 = new Master_payment_schedule__c();
         msp1.Name ='On booking 2';
         msp1.Payment_Percent__c = 50;
         msp1.Project__c = pjt.Id;
         msp1.Status__c ='Completed';
         msp1.S_No__c = 1;
         insert msp1;
         
         plot__c ut = new Plot__c();
         ut.Name='Test Unit';
         ut.Project__c=pjt.id;
         ut.Status__c='Available';
         ut.Property_Type__c = 'Villa';
         insert ut;
         
         plot__c ut2 = new Plot__c();
         ut2.Name='Test Unit2';
         ut2.Project__c=pjt.id;
         ut2.Status__c='Available';
         ut2.Property_Type__c = 'Villa';
         insert ut2;
         
         Quote__c Qt = new Quote__c();
        Qt.Approval_status__c = 'Approved';
        //Qt.Lead__c = ld.id;
        Qt.Project__c = 'Test Project';
        Qt.Unit__c = ut.id;
        Qt.Payment_Type__c = 'Standard';
         insert Qt;
        
          List<Booking__c> bkList=new List<Booking__c>();
          Booking__c bk=new Booking__c();
         bk.Stage__c = 'New';
        bk.Last_comment__c='sampletest comment';
          bk.Followup_Date__c = system.today().addDays(1);
          bk.Followup_Subject__c = 'test';
          bk.Email__c = 'test@gmail.com';
          bk.Email_id__c = 'test1@gmail.com';
         bk.Project1__c = pjt.Id;
         bk.Project__c = pjt.Project__c;
         bk.Plot__c = ut.Id;
         bk.Swap_Unit__c = ut2.Id;
         bk.Projectswap__c = 'Test Project';
         bk.First_Disbursement_Received__c =false;
         bk.Payment_Type__c ='Standard';
         bk.Cancellation_User__c = userinfo.getuserId();
         bk.Total_Cost_Ex_Leg_Main__c = 1200000;
         bk.Sales_Manager__c = UserInfo.getUserId();
         insert bk;
         bkList.add(bk);
         
         
         
         Booking__c bk2=new Booking__c();
         bk2.Stage__c = 'New';
         bk2.Last_comment__c='sampletest comment';
         bk2.Followup_Date__c = system.today().addDays(1);
         bk2.Followup_Subject__c = 'test';
         bk2.Email__c = 'test@gmail.com';
         bk2.Email_id__c = 'test1@gmail.com';
         bk2.Project1__c = pjt.Id;
         bk2.Project__c = pjt.Project__c;
         bk2.Plot__c = ut.Id;
         bk2.Swap_Unit__c = ut2.Id;
         bk2.Projectswap__c = 'Test Project';
         bk2.Payment_Type__c ='Standard';
         bk2.First_Disbursement_Received__c =false;
         bk2.Total_Cost_Ex_Leg_Main__c = 1200000;
         bk2.Cancellation_User__c = userinfo.getuserId();
         bk2.Sales_Manager__c = UserInfo.getUserId();
         insert bk2;
         bkList.add(bk2);
         
          Payment_schedule__c ps = new Payment_schedule__c();
         ps.quote__c = Qt.Id;
         ps.Payment_percent__c =50;
         ps.Booking__c = bk2.Id;
         insert ps;
         
         Payment_schedule__c ps1 = new Payment_schedule__c();
         ps1.quote__c = Qt.Id;
         ps1.S_No__c = 1;
         ps1.Payment_percent__c =50;
         ps1.Booking__c = bk2.Id;
         insert ps1;
         Receipt__c rep = new Receipt__c();
         rep.Booking__c = bk2.Id;
         rep.Approval_status__c = 'Approved';
         insert rep;
         /*document__c dc = new document__c();
         dc.booking__c = bk.Id;
         dc.booking_stage__c=bk.Stage__c;
         dc.Documents_Uploaded__c =false;
        
         insert dc;
         Mapping__c mp = new Mapping__c();
         mp.name ='Booking__c';
         mp.Stage_Name__c ='Booking';
         mp.Documents_to_Create__c ='BookingForm';
         mp.Tasks_To_Create__c ='Send Booking Form,Cost Sheet,Receipt Floor Plan';
         insert mp;*/
         test.startTest();
         Test.setCurrentPage(new PageReference('/apex/BookinfEmailFormVF'));
         ApexPages.currentPage().getParameters().put('id', bk.Id);
         BookingHandler.chnageUnitStatus(bkList);
         BookingHandler.getBookingAllDeatils(bk.Id);
         BookingHandler.swapUnit(bkList,bkList);
         //BookingHandler.createBookingDocumentsAndTask(bkList,'Document');
         // BookingHandler.createBookingDocumentsAndTask(bkList,'Task');
         BookingHandler.getInitialData(bk.Id);
         String myString = 'This is my PDF content';
         Blob pdfBlob = Blob.valueOf(myString);
         String base64String = EncodingUtil.base64Encode(pdfBlob);
         BookingHandler.SaveFile(bk.Id,'Mypdf.pdf',base64String,'PDF');
         List<BookingHandler.PDFWrapper> wrpList = new List<BookingHandler.PDFWrapper>();
         BookingHandler.PDFWrapper wrp = new BookingHandler.PDFWrapper();
         wrp.fileBody = pdfBlob;
         wrp.fileName ='mypdf.pdf';
         wrpList.add(wrp);
         BookingHandler.sendCustomNotification(recIds, 'Test EMail', 'Test EMail', string.valueof(bk.Id), ct.DeveloperName);
         BookingHandler.uploadFilesAsWrapper(wrpList,bk.Id);
         BookingHandler.sendBookingFormEmail(bk.Id);
         BookingHandler.testingMethod();
         //BookingHandler.sendWelcomeBookingMail(bkList);
         BookingHandler.CloneBooingWithUnitChangeDetails(bk2,'Agreement Under Process');
         BookingHandler bh = new BookingHandler();
         bh.Docs =wrpList;
         PageReference ref = bh.Save();
        
      
        test.stoptest();

     }
 }