@isTest
private class TestFileTrigger {
	@isTest
    public static void testRestrictFileDel(){
        User salesUser = [SELECT Id FROM User WHERE Profile.Name = 'Yotta Sales Profile' and isActive = True limit 1];
        system.runAs(salesUser){
            try{
                ContentVersion contentVersion_1 = new ContentVersion(
                    Title = 'Penguins',
                    PathOnClient = 'Penguins.jpg',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true
                );
                insert contentVersion_1;
            	ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
    			ContentDocument cd1 = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument where id =: contentVersion_2.ContentDocumentId LIMIT 1];
                delete cd1;
            }catch(Exception e){
            	Boolean expectedExceptionThrown =  e.getMessage().contains('File Cannot be deleted, please contact administrator.');
                System.AssertEquals(expectedExceptionThrown, true);
            }
        }
    }
}