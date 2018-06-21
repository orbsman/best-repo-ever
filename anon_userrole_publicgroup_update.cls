List<user> ul=[SELECT 
               id
               , username
               , business_unit__c
               , region_5__c
               , userroleid
               , userrole.developername 
               from User
               where 
               business_unit__c <> ''
               AND region_5__c <> ''
             ];
//              business_unit__c <> ''
//              AND region_5__c <> ''
//              Id='0059E000001wgvUQAQ'
               
Set<ID> UserSet = new Set<ID>();
for (user u: ul)
{
    UserSet.add(u.id);
}
    
 
List<User>  UpdatedUserList = new List<User>();
List<Group> grouplst=[select 
                      DeveloperName
                      ,Id
                      
                      from Group
                      where type='Regular'
                     ];
Map<String,String> GroupMap = new Map<String,String>();
for(group g: grouplst)
{
    GroupMap.put(g.DeveloperName.toUpperCase(), g.Id);
}
 
Map<String,String> RoleMap = new Map<String,String>();
 
List<UserRole> roleLst = [ select 
                          DeveloperName
                          , Id
                          ,  Name 
                          from UserRole 
                          ];
for(UserRole g: roleLst)
{
    RoleMap.put(g.DeveloperName.toUpperCase(), g.Id);
}
 
system.debug('## roleLst:'+roleLst);
system.debug('## RoleMap:'+RoleMap);
 
 
// select GroupId, Id, SystemModstamp, UserOrGroupId from GroupMember
List<GroupMember>    groupmemberLst= new List<GroupMember>();
 
system.debug('## groups:'+ grouplst);
system.debug('## GroupMap:'+ GroupMap);


 
for (user u: ul)
{
    system.debug('########### start user ############');
    system.debug('## user - inital:'+u + ' ,'+u.userrole.developername) ;
    if ( ( u.business_unit__c.length() > 0 ) 
        && ( u.region_5__c.length() > 0) 
        )
    {

        string[] BuLst = u.business_unit__c.split(';');
        string[] RegLst = u.region_5__c.split(';'); 
        system.debug(u);
        system.debug('## BuLst'+BuLst );
        system.debug('## RegLst'+RegLst );
        boolean RoleOK=false;
        for (string s: BuLst)
        {
            for (string r : RegLst) 
            {
                String RoleStr = 'MVP_'+s +'_' +r.replaceAll('[/ ]', '_');
                RoleStr = RoleStr.toUpperCase();
                system.debug('## RoleStr:'+RoleStr + ' RoleOK='+RoleOK);
                if(!RoleOK) {
                    String RoleId = RoleMap.get(RoleStr);
                    system.debug('## found RoleId:'+RoleId);
                    u.userroleid = RoleId;
                    UpdatedUserList.add(u);
                    system.debug('## user - updated:'+u);
                    RoleOK=true;
                } else
                {
                    RoleStr += '_PG';
                    system.debug('## Group-RoleStr:'+RoleStr);
                    String GroupID = GroupMap.get(RoleStr);
                    system.debug('## GroupID:'+GroupID);
                    GroupMember gmember= new GroupMember();
                    gmember.UserOrGroupId = u.id;
                    gmember.GroupId =GroupID;
                    system.debug('## gmember:'+gmember);
                    groupmemberLst.add(gmember);
                }
            }
            
        }
    }
    else 
    {
        system.debug('## the user is not correctly defined for auto association');
    }
}
 
list<GroupMember> gmtodelete = [select 
                                Id
                                , UserOrGroupId 
                                from GroupMember 
                                where UserOrGroupId in :UserSet
                                ];
 
system.debug('## gmtodelete:'+gmtodelete.size());
system.debug('## groupmemberLst:'+groupmemberLst.size());
system.debug('## UpdatedUserList:'+UpdatedUserList.size());
 
 
//database.delete(gmtodelete);
//database.insert(groupmemberLst, false) ;
//database.update(UpdatedUserList, false) ;