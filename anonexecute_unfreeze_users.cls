// unfreeze users during a deployment run:
// author: thoeger@salesforce.com

// set to true, if you really want to freeze users; else only test run
Boolean DoIt=false; 

String OrgUrl = URL.getSalesforceBaseUrl().toExternalForm(); 
ID myuser = userinfo.getUserId();  
system.debug('## my user='+myuser + ' in '+OrgUrl); // shows where you are

// add here the profiles which you want to infreeze
Set<String> InclusionProfiles = new Set<String>{'Standard User','Standard Playground User'}; 

List<user> AllUSers= new List<user>([SELECT Id
                                     , username
                                     , profile.name
                                     from user
                                     where IsActive = true
                                    ]);
Map<ID, string> ID_Profile_Map = new Map<ID, string>();
for (user us:AllUSers) {
    ID_Profile_Map.put(us.id, us.profile.name);
}
system.debug('## ID_Profile_Map='+ID_Profile_Map );
system.debug('## ID_Profile_Map.size='+ID_Profile_Map.size() + ' AllUSers_cnt=' + AllUSers.size());

List<UserLogin> freezeLst= new List<UserLogin>([SELECT Id
                                                , UserId
                                                , IsFrozen
                                                FROM UserLogin
                                                where IsFrozen = true
                                                ]);

Integer UnFreezeCount=0;

for (UserLogin u : freezeLst)
    if ( (InclusionProfiles.contains( ID_Profile_Map.get(u.UserId)) )
       )
        {
            u.IsFrozen = false;
            UnFreezeCount++;   
        }
        else
        {
            System.debug('## user :'+u.id + ' not unfrozen - profile is:'+ID_Profile_Map.get(u.UserId));
        }

system.debug('## UnfreezeLst='+freezeLst);
system.debug('## UnFreezeCount='+UnFreezeCount);
Integer SuccessCount=0;

if (DoIt) {
    list<database.saveresult> dbsFreezeLst= database.update(freezeLst);
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