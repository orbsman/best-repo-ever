// freeze users during a deployment run:
// author: thoeger@salesforce.com

// set to true, if you really want to freeze users; else only test run
Boolean DoIt=false; 

String OrgUrl = URL.getSalesforceBaseUrl().toExternalForm(); 
ID myuser = userinfo.getUserId();  //make sure to not freeze yourself
system.debug('## my user='+myuser + ' in '+OrgUrl);

Set<String> ExceptionProfiles = new Set<String>{'System Administrator','Wacker Sysadmin'}; 
    // add here other profile (e.g. data migration users which are needed during deployment)
    
    List<user> AllUSers= new List<user>([SELECT Id
                                         , username
                                         , profile.name
                                         from user
                                         where IsActive = true
                                        ]); // only work on active users

Map<ID, string> ID_Profile_Map = new Map<ID, string>(); // map to check for Exception Profile
for (user us:AllUSers) {
    ID_Profile_Map.put(us.id, us.profile.name);
} 

system.debug('## ID_Profile_Map='+ID_Profile_Map );
system.debug('## ID_Profile_Map.size='+ID_Profile_Map.size() + ' AllUSers_cnt=' + AllUSers.size());

List<UserLogin> freezeLst= new List<UserLogin>([SELECT Id
                                                , UserId
                                                , IsFrozen
                                                FROM UserLogin]);

Integer FreezeCount=0;

for (UserLogin u : freezeLst)
    
{
    
    if ((u.UserId <> myuser)
        && (!ExceptionProfiles.contains( ID_Profile_Map.get(u.UserId)) )
       )
    {
        u.IsFrozen = true;
        FreezeCount++;
        system.debug('## u.UserId='+u.UserId + ' frozen');
    }
    else {
        system.debug('## Exception ID_Profile_Map='+ID_Profile_Map.get(u.UserId));
        system.debug('## for u.UserId='+u.UserId + ' to not freeze:'+u.IsFrozen);
    }
    
}

system.debug('## freezeLst='+freezeLst);
system.debug('## FreezeCount='+FreezeCount);

Integer SuccessCount=0;
system.debug('## DoIt='+DoIt);

if (DoIt) {
    list<database.saveresult> dbsFreezeLst= database.update(freezeLst);
	System.debug('## dbsFreezeLst result count:'+dbsFreezeLst.size());
    for (Database.SaveResult sr : dbsFreezeLst) {
        if (sr.isSuccess()) SuccessCount++;
        else {
            // Operation failed, so get all errors
            for(Database.Error err : sr.getErrors()) {
                System.debug('## The following error has occurred.');
                System.debug('## '+err.getStatusCode() + ': ' + err.getMessage());
                System.debug('## UserLogin fields that affected this error: ' + err.getFields());
            }
        }        
    }    
}
else
{
    System.debug('## test run only');
}
system.debug('##\n######### DONE #######');
