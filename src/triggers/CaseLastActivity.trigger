trigger CaseLastActivity on Task (after insert, after update) {
/****************************************************************************************
 * Name    : CaseLastActivity
 * Author  : Eric Nelson
 * Date    : 01-18-2012
 * Purpose : When an activity is added (Email or phone call), updates the last activity date 
 *           and activity type on the parent Case record.
 *
 * ========================
 * = MODIFICATION HISTORY =
 * ========================
 * DATE        AUTHOR               CHANGE
 * ----        ------               ------
 * 01-18-2012  Eric Nelson        Created
 *
 *****************************************************************************************/
 
   //Put these in maps to ensure that each object is only in there once
  Map<Id,Case> casesToUpdate = new Map<Id,Case>();
 

  for (Task tsk:System.Trigger.new) {
    if (tsk.WhatId!=null) {
        String whatId = tsk.WhatId;
        String whatIdPrefix = whatId.substring(0,3);

         if (whatIdPrefix.equalsIgnoreCase('500')) {  
          Case act = new Case(Id=tsk.WhatId, LastActivityType__c=tsk.Type, LastActivity__c=tsk.CreatedDate);      
          casesToUpdate.put(tsk.WhatId, act);

        }
      }
    }

  try {
    if (casesToUpdate.size()>0) {
      List<Case> cases = casesToUpdate.values();
      update cases;
    }

  } catch (System.DmlException e) {
    System.debug(e.getMessage());
  }
}