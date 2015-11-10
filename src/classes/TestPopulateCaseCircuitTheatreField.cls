@isTest
private class TestPopulateCaseCircuitTheatreField {

    static testMethod void runTest() {
    	
    	/*
		 *  IF: Theatre Name and/or Circuit is blank AND screen is NOT blank, populate Theatre and/or 
		 *      Circuit with corresponding records linked to screen
		 *   IF: Circuit is blank AND Theatre is NOT blank, populate Circuit with corresponding record 
		 *       linked to Theatre
		 */
		 
		
        // Create  some test data
        Circuits__c cir = TestClientUtility.createCircuit();
        cir.Circuit_Type__c = 'Cinema';
        insert cir; 
        
        Account t = TestClientUtility.createAccount();
        t.Circuit__c = cir.Id;
        insert t;
        
        if(Default_Destination_Warehouse__c.getInstance('Default') == null)
		{
			Warehouse__c wh = TestClientUtility.createWarehouse(t.Id);
			insert wh;
			Default_Destination_Warehouse__c ddw = new Default_Destination_Warehouse__c(name ='Default', Warehouse_Id__c = wh.id);
			insert ddw;
		}
        
        Screens__c s = TestClientUtility.createScreen(t.Id);
        insert s;
        Case c = TestClientUtility.createCase();
        c.screen__c = s.Id;
        insert c;
        
        //Test to see if we have supported the first requirement
        System.assertEquals(t.Id, ([Select AccountId from Case where Id = :c.Id]).AccountId);
        System.assertEquals(cir.Id, ([Select Circuit__c from Case where Id = :c.Id]).Circuit__c);
        
        //Test the second scenario -- populating the circuit from the Account
        c.Circuit__c= null;
        c.AccountId = t.Id;
        update c;
        
        System.assertEquals(cir.Id, ([Select Circuit__c from Case where Id = :c.Id]).Circuit__c);
    }
}