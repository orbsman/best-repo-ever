Boolean isSandboxflg = [select IsSandbox from Organization ].IsSandbox;
string SandboxNameExtension = isSandboxflg ? '.'+URL.getSalesforceBaseUrl().getHost().split('\\.')[0].split('--')[1] : '';
string ParameterStr ='##Input##'; // to be filled be shell script
// string ParameterStr= 'demo#demo#th.hoeger@gmail.com#Data Migration Admin'; 

system.debug('## ParameterStr '+ParameterStr);
List<String> ls= ParameterStr.split('#');
system.debug('## ls '+ls);   
String ProfileName = ls[3].replaceAll('-', ' ');
system.debug('## ProfileName '+ProfileName);
try {
    String prId = [select id from profile where name=:ProfileName].Id;
    user u = new user();
    u.Email = ls[2];
    u.Username =u.Email.split('@')[0] +'@wacker.com' +SandboxNameExtension.toLowerCase() ;  // username gets set every time
    u.alias =  u.Email.left(8);
    u.emailencodingkey = 'UTF-8';
    u.lastname = ls[1];
    u.firstname = ls[0];
    u.languagelocalekey = 'en_US';
    u.localesidkey = 'en_US';
    u.timezonesidkey = 'America/Los_Angeles';
    u.ProfileId = prId;
    system.debug('## Username '+u.Username);
    insert u;
    system.debug('## user is:'+u);
    system.resetPassword(u.id, true);
} 
catch (Exception e)
{
    system.debug('## Exception '+e);
} 
 