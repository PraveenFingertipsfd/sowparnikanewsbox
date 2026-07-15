public class BookingPdfController {
    
    @InvocableMethod
    public static void SendManagementEmail(List<Booking__c> lst)
    {
        string recordId = lst[0].Id;
        Booking__c l = [SELECT Id,Name,Email__C,Email1__c,lead1__r.Email__c FROM Booking__c where Id=:lst[0].Id];
        List<String> lstCCEmail = new List<String>();
        if (l.Email__C != null && l.Email__C != '') {
            lstCCEmail = l.Email__C.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }

        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>(); 
        PageReference pdfPage;
                pdfPage= page.BookingForm;
        pdfPage.getParameters().put('Id', recordId);
        Blob pdfContent;
        if(!test.isRunningTest()){
            pdfContent = pdfPage.getContent();
        }else{
            pdfContent=Blob.valueOf('Test Content');
        }
        String accountName = l.Name != null ? l.Name : '';
       // String city = l.Opportunity__r.City__c != null ? ', '+l.Opportunity__r.City__c : '';
        String city='test';
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
        efa1.setFileName('Booking form for '+ accountName+''+city+' | #'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name+'.Pdf');
        efa1.setBody(pdfContent);
        fileAttachments.add(efa1);
        
        if(l.Email__C != null && l.Email__C != ''){
            //List<String> lstCCEmail = l.Email__C != null ? l.Email__C.split(',') : new List<String>();
            List<String> lstBCCEmail = l.Email__C != null ? l.Email__C.split(',') : new List<String>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = new string[]{l.lead1__r.Email__c};
                //mail.bccaddresses = lstBCCEmail;
            //mail.ccaddresses = lstCCEmail;
            mail.setSubject('Booking form for '+ accountName+''+city+' | #'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name);
            mail.setFileAttachments(fileAttachments);
            //l.Opportunity__r.Contact__r.FirstName = l.Opportunity__r.Contact__r.FirstName != null ? l.Opportunity__r.Contact__r.FirstName : '';
            //l.Opportunity__r.Contact__r.LastName = l.Opportunity__r.Contact__r.LastName != null ? l.Opportunity__r.Contact__r.LastName : '';
            //String emailBody = 'Hi '+l.Opportunity__r.Contact__r.FirstName+' '+l.Opportunity__r.Contact__r.LastName+'<br/><br/>Please find the attached quotation.<br/><br/>Thank You,<br/>'+Userinfo.getUserName();
         /*   String emailBody = l.Mail_Format__c != null ? l.Email_Content__c : '';
            emailBody += '<br/> <table border="0" cellspacing="0" cellpadding="0" style="border-collapse:collapse">';
            emailBody += '<tbody><tr style="height:125.25pt">';
            emailBody += '<td valign="top" style="border:none;border-right:solid black 1.0pt;padding:5.0pt 5.0pt 5.0pt 5.0pt;height:125.25pt">';
            emailBody += '<p class="MsoNormal" style="margin-bottom:12.0pt">';
            emailBody += '<img border="0" width="201" height="52" style="width:2.0902in;height:.5416in" id="m_-7294728397434456129_x0000_i1030" src="https://lh4.googleusercontent.com/5CsRYuaxAhwi-RW5_-tBYoCqG022TcZoM6rHM_OOCV7Me3XJksxCHb7he8Wgq7Jh_fX3IOt9GkHowkXdrwKUrul3LBQ-dBEnHf4flFyQRA5AoXOb0t8uZicxkx0O3tRbgXK17a6s" class="CToWUd">';
            emailBody += '<span style="font-family:&quot;Arial&quot;,sans-serif;color:black">&nbsp;</span><u></u><u></u></p><p align="center" style="margin:0cm;text-align:center">';
            emailBody += '<a href="https://www.facebook.com/springfitmattressindia" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.facebook.com/springfitmattressindia&amp;source=gmail&amp;ust=1602736265103000&amp;usg=AFQjCNECgytjaC2y0UoJT7pLBoDD0sPQog">';
            emailBody += '<span style="color:#1155cc;text-decoration:none">';
            emailBody += '<img border="0" width="35" height="35" style="width:.368in;height:.368in" id="m_-7294728397434456129_x0000_i1029" src="https://ci3.googleusercontent.com/proxy/PLfNxEcf2uWcdV4lbfiRf55qvPnmP5FTJi4DASpADK2FtvHg-kBGNd3PoL0rzxXI99wZcQpeSkFOgHf1WjPrxl0yNvEz8wcRt-M3NvrGLPeb28cxIN0TawkKLQPlCis1B1tUa4HWzJX1jP5p53ZLoHMAxqTkUHujD6wRSNZaBshEk-pSrXnuxx3mvAVoThMj-MCJUZYfbYzhapNpwA=s0-d-e1-ft#https://docs.google.com/uc?export=download&amp;id=1AQBEvQVhNpYW6--Q0LbW-gDEvK9OoewL&amp;revid=0Byd-oXjsjdfwK3FLV01iWGhBMTk4VnhNdVNiU0tPbFJtcXI0PQ" class="CToWUd"></span>';
            emailBody += '</a>&nbsp;&nbsp;<a href="https://www.instagram.com/springfitsleep/" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.instagram.com/springfitsleep/&amp;source=gmail&amp;ust=1602736265103000&amp;usg=AFQjCNGOuRMHdXd-m1rbB1zZUvkRe2REEg">';
            emailBody += '<span style="color:#1155cc;text-decoration:none">';
            emailBody += '<img border="0" width="35" height="35" style="width:.368in;height:.368in" id="m_-7294728397434456129_x0000_i1028" src="https://ci3.googleusercontent.com/proxy/hyiys6l8836_fP8-Ul8JzW1U9N1VltaIGP4-sR7hfa9yzqL2JvlIx0l7p_AcAKCYnFQR_DWC26enMsZgZDdbNyzKaKuFLXrgUbVN6nxNmCnRZAm54GEfBGxqD5mkvuXeje_WgINiC_mSuRWkyM3EnO4IAjCt84CQZlUjZbiymIlRA3Rux4CUV9-cx_6KcFo9rkIKEAqX_AAc_dpi4Q=s0-d-e1-ft#https://docs.google.com/uc?export=download&amp;id=1LjHRUN3CX2ZrWi8slQPSXFaukEADTmTN&amp;revid=0Byd-oXjsjdfwTXZQTEhBZUZJT3AwSTdJcHhpeFpNUks5L3BVPQ" class="CToWUd"></span></a>&nbsp;&nbsp;';
            emailBody += '<a href="https://www.linkedin.com/company/springfitsleep" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.linkedin.com/company/springfitsleep&amp;source=gmail&amp;ust=1602736265103000&amp;usg=AFQjCNGwsRvvwbNiUlKyJuWolZ2p3KvNVw">';
            emailBody += '<span style="color:#1155cc;text-decoration:none">';
            emailBody += '<img border="0" width="35" height="35" style="width:.368in;height:.368in" id="m_-7294728397434456129_x0000_i1027" src="https://ci4.googleusercontent.com/proxy/zonhDOJJvyCiVFifxgLO2rapwkbfvWx2ABzLOw3FbmBGxGuWJnfYgtcNsvMYGepKEuYeXNi7LSJAumJFTB_rWjOrtIoZjy5V02LeVugrjjnNUgE3QbDLNT4TYqEenZr1NMCVT2bDO6IGDnImbMBV3IcRtav3ngbLR4-btpE6MSbkTV3Prc8fROUB0Rorl99n5IOFBVdYGqTFgl2DUw=s0-d-e1-ft#https://docs.google.com/uc?export=download&amp;id=1p_8R8phJUIv5XUPuvWHFTBSXHIv077f3&amp;revid=0Byd-oXjsjdfwWlEvb2Z0a25IUkp0ZzJwTWhmTi9zVEhlZmU4PQ" class="CToWUd"></span></a>&nbsp;&nbsp;';
            emailBody += '<a href="https://www.youtube.com/c/springfitmattresssleepsystems/" target="_blank" data-saferedirecturl="https://www.google.com/url?q=https://www.youtube.com/c/springfitmattresssleepsystems/&amp;source=gmail&amp;ust=1602736265103000&amp;usg=AFQjCNFSSCFg-z4ng1OQzF5LTPICOFpbIg">';
            emailBody += '<span style="color:#1155cc;text-decoration:none">';
            emailBody += '<img border="0" width="35" height="35" style="width:.368in;height:.368in" id="m_-7294728397434456129_x0000_i1026" src="https://ci4.googleusercontent.com/proxy/2vzvaN6iC12S9IOqCaWjGbHRoYcX6MY0-eobu050tLdXmp8yXnp8IsMLCNZ3bMOjOcyYByxUU6QojOe7s70JSnsp_lycyN84FGKEbr3wNAkSqJr78OWFE_gVq07XE1MFhvnoEsKMbS9ed6magHv9vmkQkz6tjCPBN_yaabK6Ng_t2c6mZJZgYUAlr01rJm_pM12iCQsOUcJnzmEE1Q=s0-d-e1-ft#https://docs.google.com/uc?export=download&amp;id=10RBMNp297CDU4_H18ZRjEa_ZUBJpVkrX&amp;revid=0Byd-oXjsjdfwMGxsZm1QS0pTRFozUzYzM2xFc1VZS1A0MTBZPQ" class="CToWUd"></span></a><u></u><u></u></p>';
            emailBody += '<p align="center" style="margin:0cm;text-align:center"><b><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">&nbsp;</span></b>';
            emailBody += '<span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif"><a href="http://www.springfit.com/" target="_blank" data-saferedirecturl="https://www.google.com/url?q=http://www.springfit.com/&amp;source=gmail&amp;ust=1602736265103000&amp;usg=AFQjCNGhdutBKyRgdl82y1dTH2tL71AC1w">';
            emailBody += '<span style="color:black">www.springfit.com</span></a></span><u></u><u></u></p></td>';
            emailBody += '<td valign="top" style="padding:5.0pt 5.0pt 5.0pt 5.0pt;height:125.25pt;overflow:hidden">';
            emailBody += '<p style="margin:0cm"><b><span style="font-family:&quot;Verdana&quot;,sans-serif;color:black">DALIP KUMAR</span></b><u></u><u></u></p><p style="margin:0cm"><b>';
            emailBody += '<span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">Institutional Sales Head</span></b><u></u><u></u></p><p style="margin:0cm"><b>';
            emailBody += '<span style="font-size:7.5pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">Call</span></b>';
            emailBody += '<span style="font-size:7.5pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">&nbsp;: + 91 9311987268</span><u></u><u></u></p>';
            emailBody += '<p style="margin:0cm"><b><span style="font-size:7.5pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">e-mail</span></b>';
            emailBody += '<span style="font-size:7.5pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">:dalip</span><span style="font-size:7.5pt;font-family:&quot;Verdana&quot;,sans-serif">';
            emailBody += '<a href="mailto:dalip@springfit.com" target="_blank"><span style="color:black">@springfit.com</span></a></span><u></u><u></u></p>';
            emailBody += '<p style="margin:0cm"><b><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">Address&nbsp;&nbsp;</span></b><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">: Springfit Mattresses,&nbsp;419,</span><u></u><u></u></p>';
            emailBody += '<p style="margin:0cm"><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">K.M.Trade Tower,&nbsp;(Hotel Radisson Blu),</span><u></u><u></u></p>';
            emailBody += '<p style="margin:0cm"><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">Sec-14,&nbsp;Kaushambi,&nbsp;</span><u></u><u></u></p>';
            emailBody += '<p style="margin:0cm"><span style="font-size:8.0pt;font-family:&quot;Verdana&quot;,sans-serif;color:black">Ghaziabad-201010</span><u></u><u></u></p></td>';
            emailBody += '<td valign="top" style="padding:5.0pt 5.0pt 5.0pt 5.0pt;height:125.25pt;overflow:hidden"><p style="margin:0cm">';
            emailBody += '<img border="0" width="140" height="140" style="width:1.4583in;height:1.4583in" id="m_-7294728397434456129_x0000_i1025" src="https://ci4.googleusercontent.com/proxy/_4tqjpFf-mhGIELceYqWMNn4fcFfGtoXCjCNXhVv-X7odHZpmByU97wI9x4ht1d6mDhiaRwz3I9MkQhVQjNy_AEW6qyhnk4yzjSP_MKHj77yId6DGRr9RINjWbsL0R7HtH2XrSjzF0CWB92DxeJS0pJI83_rU3YG0AGW1buV9ofOxNuCufDRyWhr1rFxnua1H48Zosz6ALNmUsNWAQ=s0-d-e1-ft#https://docs.google.com/uc?export=download&amp;id=1F1T3aywUkv3IV4iVDwH__twv4jMPPfTY&amp;revid=0Bxi2LouH3HFZdWN2U1J0WEtUQkdob0dRVnlPbUVVSGVHb2U0PQ" class="CToWUd"><u></u><u></u></p></td></tr></tbody></table>';*/
            string emailBody='Thank you for Booking a plot in Real Estate';
mail.setHtmlBody(emailBody);
            mails.add(mail);
        }
        Messaging.SendEmailResult[] results = new list<Messaging.SendEmailResult>();
        if(!test.isrunningtest()){
            results = Messaging.sendEmail(mails); 
            system.debug('bvhbhvhjvhvh'+results);
           /* if (results[0].success)
                System.debug('The email was sent successfully.');
            else
                System.debug('The email failed to send: ' + results[0].errors[0].message);*/
        }
        
        
        // create the new attachment
      /*  Attachment attach = new Attachment();
        
        // the contents of the attachment from the pdf
        Blob pdfFile;
        
        attach.Body = pdfContent;
        
        Integer attSize = [select Id from Attachment where ParentId = :recordId].size();
        
        // add the user entered name
        attach.Name = ('Quote for '+ accountName+''+city+'|#'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name+'_v'+(attSize+1)+'.pdf');
        //attach.Name = 'V1Test.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = recordId;
        insert attach;*/
    }
    
    // Assuming quote is a Quote variable set in the controller  
    
  /*  @AuraEnabled
    public static void saveToQuote(Id recordId)
    {
        Custom_Quote__c l = [SELECT Id,Name,Quote_Name__c,Mail_Format__c,Email_Content__c,Opportunity__r.name,Opportunity__r.AccountName__r.Name,Opportunity__r.Contact__r.FirstName,Opportunity__r.Contact__r.LastName,Opportunity__r.Contact_Email__c,Quote_Number__c,Email__c,Opportunity__r.Email__c,Opportunity__r.City__c FROM Custom_Quote__c where Id=:recordId];
        
        String accountName = l.Opportunity__r.AccountName__r.Name != null ? l.Opportunity__r.AccountName__r.Name : '';
        String city = l.Opportunity__r.City__c != null ? ', '+l.Opportunity__r.City__c : '';
        
        PageReference pdfPage = new PageReference('/apex/GenerateQuote');
        // add parent id to the parameters for standardcontroller
        pdfPage.getParameters().put('Id', recordId);
        
        // create the new attachment
        Attachment attach = new Attachment();
        
        // the contents of the attachment from the pdf
        Blob pdfFile;
        
        try {
            
            // returns the output of the page as a PDF
            pdfFile = pdfPage.getContent();
            
            // need to pass unit test -- current bug	
        } catch (VisualforceException e) {
            pdfFile = Blob.valueOf('Some Text');
        }
        
        attach.Body = pdfFile;
        
        Integer attSize = [select Id from Attachment where ParentId = :recordId].size();
        
        // add the user entered name
        attach.Name = ('Quote for '+ accountName+''+city+'|#'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name+'_v'+(attSize+1)+'.pdf');
        //attach.Name = 'V1Test.pdf';
        attach.IsPrivate = false;
        // attach the pdf to the account
        attach.ParentId = recordId;
        insert attach;
    }*/
    
    public static void SendSigningEmail(Id lst)
    {
        
        Booking__c l = [SELECT Id,Name,Email__C,Email1__c,lead1__r.Email__c FROM Booking__c where Id=:lst];
        List<String> lstCCEmail = new List<String>();
        if (l.Email__C != null && l.Email__C != '') {
            lstCCEmail = l.Email__C.split(',');
        }
        if (l.Email1__c != null && l.Email1__c != '') {
            lstCCEmail.addAll(l.Email1__c.split(','));
        }

        list<Messaging.SingleEmailMessage> mails = new list<Messaging.SingleEmailMessage>(); 
        PageReference pdfPage;
                pdfPage= page.BookingForm;
        pdfPage.getParameters().put('Id', lst);
        Blob pdfContent;
        if(!test.isRunningTest()){
            pdfContent = pdfPage.getContent();
        }else{
            pdfContent=Blob.valueOf('Test Content');
        }
        String accountName = l.Name != null ? l.Name : '';
       // String city = l.Opportunity__r.City__c != null ? ', '+l.Opportunity__r.City__c : '';
        String city='test';
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
        Messaging.Emailfileattachment efa1 = new Messaging.Emailfileattachment();
        efa1.setFileName('Booking form for '+ accountName+''+city+' | #'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name+'.Pdf');
        efa1.setBody(pdfContent);
        fileAttachments.add(efa1);
        
        if(l.Email__C != null && l.Email__C != ''){
            //List<String> lstCCEmail = l.Email__C != null ? l.Email__C.split(',') : new List<String>();
            List<String> lstBCCEmail = l.Email__C != null ? l.Email__C.split(',') : new List<String>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.toAddresses = new string[]{l.lead1__r.Email__c};
                mail.bccaddresses = lstBCCEmail;
            mail.ccaddresses = lstCCEmail;
            mail.setSubject('Booking form for '+ accountName+''+city+' | #'+system.today().year()+'-'+System.now().format('MMM')+'-'+system.today().day()+'-'+l.name);
            mail.setFileAttachments(fileAttachments);
            string emailBody='Thank you for Booking a plot in Real Estate';
mail.setHtmlBody(emailBody);
            mails.add(mail);
        }
        Messaging.SendEmailResult[] results = new list<Messaging.SendEmailResult>();
        if(!test.isrunningtest()){
            results = Messaging.sendEmail(mails); 
            system.debug(results);
           /* if (results[0].success)
                System.debug('The email was sent successfully.');
            else
                System.debug('The email failed to send: ' + results[0].errors[0].message);*/
        }
    }
}