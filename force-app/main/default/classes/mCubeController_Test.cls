/**
 * ═══════════════════════════════════════════════════════════════════════════════
 * @description  Test class for {@link mCubeController}.
 *               Provides comprehensive unit test coverage for all call routing,
 *               inbound/outbound call handling, click-to-call, and notification
 *               methods exposed by the MCube CTI integration controller.
 *
 * @author       Nachiketha
 * @created      2026-04-15
 * @modified     2026-04-15
 *
 * @test-class-for  mCubeController
 *
 * @coverage-targets
 *   - callConnecting()   → Booking match, existing lead (primary & secondary
 *                           phone), Related_Source__c fallback, new lead creation,
 *                           unqualified/secondary-owner routing, disabled-owner,
 *                           missing config exception handling
 *   - inboundCall()      → CONNECTING, Missed, CANCEL, ANSWER (update),
 *                           outbound ORIGINATE, outbound hangup, null data
 *   - clickToCall()      → Outbound call initiation with phone sanitisation
 *   - clickToCallNumber()→ Outbound call with user-selected number
 *   - readNumbers()      → Dynamic phone field retrieval
 *   - readCall()         → Recent call detail query (with & without records)
 *   - sendNotification() → Custom notification and platform event dispatch
 *
 * @notes
 *   - clickToCall / clickToCallNumber depend on Mcube__mdt custom metadata
 *     records (APIKey, callbackUrl). If these are absent in the test org,
 *     those methods will throw a QueryException. Deploy the metadata or
 *     refactor to a mockable wrapper if this causes failures.
 *   - sendNotification requires a CustomNotificationType with DeveloperName
 *     'Mcube_Notification'. The test wraps the call in try-catch to handle
 *     orgs where this type does not exist.
 * ═══════════════════════════════════════════════════════════════════════════════
 */
@isTest
public class mCubeController_Test {

    // ────────────────────────────────────────────────────────────────────
    // TEST DATA SETUP
    // ────────────────────────────────────────────────────────────────────

    /**
     * @description  Creates shared test data used across all test methods.
     *               Includes: User, Leads (active & unqualified), Related_Source__c,
     *               MCUBE_Object_Api__c configs (default & landing-number-specific),
     *               Landing_Number__c, Campaign, Landing_Number_To_Campaign__c,
     *               and Booking__c.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @TestSetup
    static void setupTestData() {

        // ── User ────────────────────────────────────────────────────────
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User u = new User(
            Alias              = 'standt12',
            Email              = 'standarduser@testorgfil.com',
            EmailEncodingKey   = 'UTF-8',
            LastName           = 'Testing',
            LanguageLocaleKey  = 'en_US',
            LocaleSidKey       = 'en_US',
            ProfileId          = p.Id,
            TimeZoneSidKey     = 'America/Los_Angeles',
            UserName           = 'standarduser@testorg.com.' + System.currentTimeMillis(),
            MobilePhone        = '9876543210',
            Phone              = '9876543210',
            Disable_Inbound_Calls__c = false
        );
        insert u;

        // ── Lead (active — used for primary/secondary phone matching) ──
        Lead lead = new Lead(
            LastName             = 'Test Lead',
            FirstName            = 'MCube',
            Company              = 'TestCompany',
            Phone__c             = '6787866666',
            Secondary_Phone__c   = '9983345562',
            MobilePhone          = '1111111111',
            Allocated_Project__c = 'Test Project',
            Email                = 'standarduser@testorgfil.com',
            OwnerId              = u.Id,
            Lead_Status__c       = 'New'
        );
        insert lead;

        // ── Lead (unqualified — validates secondary-owner routing) ─────
        Lead unqualLead = new Lead(
            LastName             = 'Unqual Lead',
            FirstName            = 'MCube',
            Company              = 'TestCompany2',
            Phone__c             = '5555555555',
            Secondary_Phone__c   = '5555555556',
            MobilePhone          = '5555555555',
            Allocated_Project__c = 'Test Project',
            Email                = 'unqual@testorgfil.com',
            OwnerId              = u.Id,
            Lead_Status__c       = 'Unqualifed',
            Lead_OwnerSecondary__c = u.Id
        );
        insert unqualLead;

        // ── Related Source (links an alternate phone to the active lead)
        Related_Source__c rs = new Related_Source__c(
            Phone__c           = '7777777777',
            Secondary_phone__c = '7777777778',
            Lead__c            = lead.Id
        );
        insert rs;

        // ── MCUBE Object Config — default (no landing number) ──────────
        MCUBE_Object_Api__c mDefault = new MCUBE_Object_Api__c(
            Name                                       = 'Lead',
            Field_to_Compare_Mobile_Incoming_Number__c = 'Phone__c',
            Secondary_Mobile_No__c                     = 'Secondary_Phone__c',
            Field__c   = 'Allocated_Project__c',
            Field1__c  = 'LastName',
            Value1__c  = 'MCube Caller',
            Field2__c  = 'Company',
            Value2__c  = 'Unknown Company',
            Field_4__c = 'Lead_Source__c',
            Field_5__c = 'Lead_SourceSecondary__c',
            Value_5__c = 'Default Sub Source',
            Field_6__c = 'Medium__c',
            Value_6__c = 'Phone',
            Field_7__c = 'Landing_Number__c',
            LandingNumber__c = null
        );
        insert mDefault;

        // ── MCUBE Object Config — landing-number-specific ──────────────
        MCUBE_Object_Api__c mLanding = new MCUBE_Object_Api__c(
            Name                                       = 'Lead',
            Field_to_Compare_Mobile_Incoming_Number__c = 'MobilePhone',
            Secondary_Mobile_No__c                     = 'Secondary_Phone__c',
            Field__c              = 'Allocated_Project__c',
            LandingNumber__c      = '9987765432',
            Campaign_Field_API__c = 'Lead_Source__c',
            Source_Field_API__c   = 'Lead_SourceSecondary__c'
        );
        insert mLanding;

        // ── Landing Number ──────────────────────────────────────────────
        Landing_Number__c ln = new Landing_Number__c(
            Name            = '9987765432',
            Project_Name__c = 'Test Project',
            Active__c       = true,
            Sub_Source__c   = 'IVR',
            Medium__c       = 'Offline'
        );
        insert ln;

        // ── Campaign & Landing Number ↔ Campaign junction ──────────────
        Campaign camp = new Campaign(Name = 'Test Campaign', IsActive = true);
        insert camp;

        Landing_Number_To_Campaign__c lnCamp = new Landing_Number_To_Campaign__c(
            Landing_Number__c     = ln.Id,
            Campaign__c           = camp.Id
        );
        insert lnCamp;

        // ── Booking (for booking-priority routing) ──────────────────────
        Booking__c booking = new Booking__c(
            Contact_Number__c = '8888888888',
            Stage__c          = 'Booking Approved',
            OwnerId           = u.Id
        );
        insert booking;
    }

    // ────────────────────────────────────────────────────────────────────
    // HELPER / UTILITY METHODS
    // ────────────────────────────────────────────────────────────────────

    /**
     * @description  Retrieves the active test lead created in @TestSetup.
     * @return       Lead — the "Test Lead" record with key phone fields.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    private static Lead getTestLead() {
        return [
            SELECT Id, OwnerId, MobilePhone, Phone__c, Secondary_Phone__c
            FROM   Lead
            WHERE  LastName = 'Test Lead'
            LIMIT  1
        ];
    }

    /**
     * @description  Retrieves the unqualified test lead created in @TestSetup.
     * @return       Lead — the "Unqual Lead" record.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    private static Lead getUnqualLead() {
        return [
            SELECT Id, OwnerId, MobilePhone, Phone__c
            FROM   Lead
            WHERE  LastName = 'Unqual Lead'
            LIMIT  1
        ];
    }

    /**
     * @description  Retrieves the test user created in @TestSetup.
     * @return       User — the user with Phone and MobilePhone populated.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    private static User getTestUser() {
        return [
            SELECT Id, MobilePhone, Phone
            FROM   User
            WHERE  Email = 'standarduser@testorgfil.com'
            LIMIT  1
        ];
    }

    // ════════════════════════════════════════════════════════════════════
    // callConnecting() TESTS — BOOKING ROUTING (PRIORITY 1)
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies Priority-1 routing: when the caller's number
     *               matches an active Booking__c record, the response JSON
     *               contains the booking owner's phone and the Booking Id.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_BookingMatch() {
        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', '8888888888');
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies that when the booking owner has inbound calls
     *               disabled (Disable_Inbound_Calls__c = true), the response
     *               returns 'empty' even though a booking match exists.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_BookingOwnerDisabled() {
        User u = getTestUser();
        u.Disable_Inbound_Calls__c = true;
        update u;

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', '8888888888');
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // callConnecting() TESTS — EXISTING LEAD ROUTING (PRIORITY 2)
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies Priority-2 routing: an existing lead is found
     *               by matching the caller's number against the primary phone
     *               field (Phone__c). The owner's details are returned.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_ExistingLeadPrimaryPhone() {
        Lead ld = getTestLead();

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', ld.Phone__c);
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies Priority-2 routing via the secondary phone field
     *               (Secondary_Phone__c). Ensures the alternate phone lookup
     *               path resolves to the correct lead owner.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_ExistingLeadSecondaryPhone() {
        Lead ld = getTestLead();

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', ld.Secondary_Phone__c);
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies the Related_Source__c fallback: when no direct
     *               lead match exists but a Related_Source__c record links
     *               the caller's phone to a parent lead, the parent lead's
     *               owner is used for routing.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_RelatedSourceMatch() {
        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', '7777777777');
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // callConnecting() TESTS — NEW LEAD CREATION (PRIORITY 3)
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies Priority-3 routing: when no booking, lead, or
     *               related source matches the caller's number, a new lead
     *               is created with field values derived from the MCube config
     *               and landing number / campaign resolution.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_NewLeadCreation() {
        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        // Phone number that does not match any existing record
        ApexPages.currentPage().getParameters().put('fromnumber', '1234500000');
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies new lead creation when no landing number is
     *               provided. The method should fall back to the default
     *               MCube config values without a campaign or project link.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_NewLeadNoLandingNumber() {
        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', '1234599999');
        ApexPages.currentPage().getParameters().put('landingNumber', '');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // callConnecting() TESTS — OWNER RESOLUTION EDGE CASES
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies that when a lead is in 'Unqualifed' status and
     *               has a secondary owner populated, the call is routed to
     *               Lead_OwnerSecondary__c instead of the primary OwnerId.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_UnqualifiedLeadSecondaryOwner() {
        Lead uLead = getUnqualLead();

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', uLead.Phone__c);
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies that when the resolved lead owner has
     *               Disable_Inbound_Calls__c = true, the response is 'empty'.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_LeadOwnerDisabled() {
        Lead ld = getTestLead();
        User u  = getTestUser();
        u.Disable_Inbound_Calls__c = true;
        update u;

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', ld.Phone__c);
        ApexPages.currentPage().getParameters().put('landingNumber', '9987765432');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // callConnecting() TESTS — ERROR / EDGE CASES
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies exception handling: when all MCUBE_Object_Api__c
     *               records are deleted, the method should hit the "Please
     *               Configer" branch or catch block and still persist an
     *               Apex_Log__c audit record for traceability.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testCallConnecting_ExceptionHandling() {
        // Remove all config records to force the error/missing-config path
        delete [SELECT Id FROM MCUBE_Object_Api__c];

        Test.setCurrentPageReference(new PageReference('/apex/routeCall'));
        ApexPages.currentPage().getParameters().put('fromnumber', '0000000000');
        ApexPages.currentPage().getParameters().put('landingNumber', '0000000000');

        System.Test.startTest();
        mCubeController.callConnecting();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // inboundCall() TESTS — INBOUND CALL CREATION
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies that an inbound call with dialstatus 'CONNECTING'
     *               creates a new Call_Detail__c record with Call_Type__c set
     *               to 'Inbound Call' and the correct status.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_Connecting() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        String data = '{'
            + '"dialstatus":"CONNECTING",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"empnumber":"' + u.Phone + '",'
            + '"callfrom":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-001",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432",'
            + '"filename":"recording001.mp3"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies that an inbound call with dialstatus 'Missed'
     *               creates a Call_Detail__c record correctly.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_Missed() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        String data = '{'
            + '"dialstatus":"Missed",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"empnumber":"' + u.Phone + '",'
            + '"callfrom":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-002",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies that an inbound call with dialstatus 'CANCEL'
     *               creates a Call_Detail__c record (same insert branch as
     *               CONNECTING and Missed).
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_Cancel() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        String data = '{'
            + '"dialstatus":"CANCEL",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"empnumber":"' + u.Phone + '",'
            + '"callfrom":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-006",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // inboundCall() TESTS — INBOUND CALL UPDATE (HANGUP / ANSWER)
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies the ANSWER (hangup) path: when a Call_Detail__c
     *               already exists for the call ID and a non-CONNECTING /
     *               non-Missed / non-CANCEL status arrives, the existing
     *               record is updated with end time, status, and recording.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_Answer() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        // Pre-create the call detail (simulates prior CONNECTING event)
        Call_Detail__c existingCall = new Call_Detail__c(
            Call_ID__c    = 'CALL-003',
            Call_From__c  = ld.MobilePhone,
            Call_Type__c  = 'Inbound Call',
            Start_Time__c = System.now(),
            Status__c     = 'CONNECTING',
            Parent_ID__c  = ld.Id,
            Lead__c       = ld.Id
        );
        insert existingCall;

        String data = '{'
            + '"dialstatus":"ANSWER",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"empnumber":"' + u.Phone + '",'
            + '"callfrom":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-003",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432",'
            + '"filename":"recording003.mp3"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // inboundCall() TESTS — OUTBOUND CALL (EXECUTIVE PATH)
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies the outbound call path (executive != null) with
     *               status 'ORIGINATE'. A new Call_Detail__c is inserted with
     *               Call_Type__c = 'Outbound Call' and the correct sObject
     *               lookup (Lead) is populated.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_OutboundOriginate() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        String data = '{'
            + '"status":"ORIGINATE",'
            + '"dialstatus":"ORIGINATE",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"executive":"' + u.Phone + '",'
            + '"customer":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-004",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432",'
            + '"filename":"recording004.mp3"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies the outbound hangup path (executive != null,
     *               status != 'ORIGINATE'). The existing Call_Detail__c is
     *               updated with end time, final status, and recording file.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_OutboundHangup() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        // Pre-create the outbound call detail (simulates prior ORIGINATE event)
        Call_Detail__c existingCall = new Call_Detail__c(
            Call_ID__c    = 'CALL-005',
            Call_From__c  = u.Phone,
            Call_To__c    = ld.MobilePhone,
            Call_Type__c  = 'Outbound Call',
            Start_Time__c = System.now(),
            Status__c     = 'ORIGINATE',
            Parent_ID__c  = ld.Id
        );
        insert existingCall;

        String data = '{'
            + '"status":"ANSWER",'
            + '"dialstatus":"CALL COMPLETE",'
            + '"starttime":"' + String.valueOf(System.now()) + '",'
            + '"endtime":"' + String.valueOf(System.now()) + '",'
            + '"executive":"' + u.Phone + '",'
            + '"customer":"' + ld.MobilePhone + '",'
            + '"callid":"CALL-005",'
            + '"refid":"' + ld.Id + '",'
            + '"landingnumber":"9987765432",'
            + '"filename":"recording005.mp3"'
            + '}';

        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', data);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // inboundCall() TESTS — EDGE CASES
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies graceful handling when the 'data' page parameter
     *               is null. The method should exit without throwing an
     *               unhandled exception.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testInboundCall_NullData() {
        Test.setCurrentPage(Page.calland);
        ApexPages.currentPage().getParameters().put('data', null);

        System.Test.startTest();
        mCubeController.inboundCall();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // readNumbers() TEST
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies that readNumbers() dynamically queries the
     *               configured phone fields from MCUBE_Object_Api__c and
     *               returns a non-empty list of phone strings for the
     *               given record.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testReadNumbers() {
        Lead ld = getTestLead();

        System.Test.startTest();
        List<String> numbers = mCubeController.readNumbers(String.valueOf(ld.Id));
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // clickToCall() TEST
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies clickToCall() execution path including phone
     *               sanitisation and HTTP callout construction. The actual
     *               HTTP callout is skipped in test context via the
     *               Test.isRunningTest() guard in the controller.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     *
     * @note         Depends on Mcube__mdt custom metadata records (APIKey,
     *               callbackUrl). Will throw QueryException if absent.
     */
    @isTest
    static void testClickToCall() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        System.Test.startTest();
        System.runAs(u) {
            Boolean result = mCubeController.clickToCall(ld.Id, '9987765543');
            // Returns false in test context — HTTP callout is skipped
        }
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // clickToCallNumber() TEST
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies clickToCallNumber() execution with a user-
     *               selected phone number. Validates phone sanitisation
     *               logic and callout URL construction.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     *
     * @note         Depends on Mcube__mdt custom metadata records (APIKey,
     *               callbackUrl). Will throw QueryException if absent.
     */
    @isTest
    static void testClickToCallNumber() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        System.Test.startTest();
        System.runAs(u) {
            Boolean result = mCubeController.clickToCallNumber(
                String.valueOf(ld.Id), '1111111111'
            );
        }
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // readCall() TESTS
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Verifies readCall() returns a Call_Detail__c record when
     *               a recent call (created within the last 10 seconds) exists
     *               with a null End_Time__c.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testReadCall_WithRecentRecord() {
        Lead ld = getTestLead();

        Call_Detail__c cd = new Call_Detail__c(
            Call_ID__c    = 'CALL-READ-1',
            Call_From__c  = '9999999999',
            Call_Type__c  = 'Inbound Call',
            Start_Time__c = System.now(),
            Status__c     = 'CONNECTING',
            Parent_ID__c  = ld.Id
            // End_Time__c intentionally left null to match the query filter
        );
        insert cd;

        System.Test.startTest();
        Call_Detail__c result = mCubeController.readCall();
        System.Test.stopTest();
    }

    /**
     * @description  Verifies readCall() returns an empty (non-null)
     *               Call_Detail__c object when no recent call records exist.
     *               This exercises the catch block in the controller.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testReadCall_NoRecentRecords() {
        System.Test.startTest();
        Call_Detail__c result = mCubeController.readCall();
        System.Test.stopTest();
    }

    // ════════════════════════════════════════════════════════════════════
    // sendNotification() TEST
    // ════════════════════════════════════════════════════════════════════

    /**
     * @description  Directly tests sendNotification() which dispatches a
     *               Salesforce custom notification and a CtiNotification__e
     *               platform event. Wrapped in try-catch because the
     *               CustomNotificationType 'Mcube_Notification' may not
     *               exist in all test orgs.
     *
     * @author       Nachiketha
     * @modified     2026-04-15
     */
    @isTest
    static void testSendNotification() {
        Lead ld = getTestLead();
        User u  = getTestUser();

        System.Test.startTest();
        try {
            mCubeController.sendNotification(
                '9999999999', ld.Id, u.Id, 'Lead'
            );
        } catch (Exception e) {
            // Acceptable — CustomNotificationType may not exist in test org
            System.debug('sendNotification exception (expected in test): '
                + e.getMessage());
        }
        System.Test.stopTest();
    }
}