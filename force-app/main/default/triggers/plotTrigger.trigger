trigger plotTrigger on Plot__c (before update) {
    String restrictedUserIdsLabel = Label.RestrictedEditError;
    List<String> restrictedUserIds = restrictedUserIdsLabel.split(',');
    for (Plot__c plot : Trigger.new) {
        if (restrictedUserIds.contains(UserInfo.getUserId())) {
            plot.addError('You Dont have necessary to edit the record');
        }
    }

}