@isTest
public class OppLineItemHelperTest {
    
    @TestSetup
    static void makeData(){
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity opp1 = new Opportunity(
            Name = 'Test Opp 1',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        
        Opportunity opp2 = new Opportunity(
            Name = 'Test Opp 2',
            AccountId = testAccount.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        
        insert new List<Opportunity>{opp1, opp2};
        
        Product2 prod = new Product2(Name = 'Test Product', IsActive = true);
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = Test.getStandardPricebookId(),
            Product2Id = prod.Id,
            UnitPrice = 100,
            IsActive = true
        );
        insert pbe;
    }
    
    @isTest
    static void testUpdateOriginalAmount() {
        // Get the opportunities created in the setup
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>();
        for(Opportunity opp : opps) {
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Quantity = 5,
                UnitPrice = 100,
                PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id
            );
            olis.add(oli);
        }
        
        Test.startTest();
        insert olis;
        OppLineItemDiscountHelper.updateOriginalAmount(olis);
        Test.stopTest();
        
        // Verify the results
        List<Opportunity> updatedOpps = [SELECT Id, Original_Amount__c FROM Opportunity];
        System.assertEquals(500, updatedOpps[0].Original_Amount__c, 'Original Amount should be 500');
        System.assertEquals(500, updatedOpps[1].Original_Amount__c, 'Original Amount should be 500');
    }
    
    @isTest
    static void testCalculateDiscountLowAmount() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 100,
            UnitPrice = 1000,
            PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id
        );
        
        Test.startTest();
        insert oli;
        OppLineItemDiscountHelper.updateOriginalAmount(new List<OpportunityLineItem>{oli});
        OppLineItemDiscountHelper.calculateDiscount(new List<OpportunityLineItem>{oli});
        Test.stopTest();
        
        // Verify the results
        OpportunityLineItem updatedOli = [SELECT Id, Discount FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals(5, updatedOli.Discount, 'Discount should be 5% for amount between 50000 and 200000');
    }
    
    @isTest
    static void testCalculateDiscountHighAmount() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 2500,
            UnitPrice = 100,
            PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id
        );
        
        Test.startTest();
        insert oli;
        OppLineItemDiscountHelper.updateOriginalAmount(new List<OpportunityLineItem>{oli});
        OppLineItemDiscountHelper.calculateDiscount(new List<OpportunityLineItem>{oli});
        Test.stopTest();
        
        // Verify the results
        OpportunityLineItem updatedOli = [SELECT Id, Discount FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals(10, updatedOli.Discount, 'Discount should be 10% for amount over 200000');
    }
    
    @isTest
    static void testCalculateDiscountNoDiscount() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 10,
            UnitPrice = 100,
            PricebookEntryId = [SELECT Id FROM PricebookEntry LIMIT 1].Id
        );
        
        Test.startTest();
        insert oli;
        OppLineItemDiscountHelper.updateOriginalAmount(new List<OpportunityLineItem>{oli});
        OppLineItemDiscountHelper.calculateDiscount(new List<OpportunityLineItem>{oli});
        Test.stopTest();
        
        // Verify the results
        OpportunityLineItem updatedOli = [SELECT Id, Discount FROM OpportunityLineItem WHERE Id = :oli.Id];
        System.assertEquals(0, updatedOli.Discount, 'Discount should be 0% for amount less than 50000');
    }
}
