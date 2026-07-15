trigger FollowUpTrigger on Follow_up__c (before insert,after insert,after update, after delete, after undelete)
{
    if(trigger.isafter && trigger.isinsert)
    {
        Map<Id,String> ldIds = new Map<Id,String>();
        for(Follow_up__c sv : trigger.new){
            if(sv.SLead__c != null && sv.Feedback__c != null){
                ldIds.put(sv.SLead__c,sv.Feedback__c);
            }
        }
        if(ldIds.size()>0 ){
            CreateALogAfterLeasdUpdate.updateLastNoteInBulk(ldIds);
        }
    }
}