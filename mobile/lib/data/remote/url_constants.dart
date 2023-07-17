class Endpoints {
  /*Base URl*/

  static const kApiBaseUrl = 'https://api.ajudamais.bymobinteg.com/api';
  static const kApiTokenCrateUrl =
      'https://api.ajudamais.bymobinteg.com/dex/token';

  //static const kApiBaseUrl = 'https://mmfinfotech.website/intelar_app';

  /*  user API */
  static const kUserUrl = '$kApiBaseUrl/users';

  /*  auth APIs */
  static const kFcmUrl = '$kApiBaseUrl/fcm/register';
  static const kTasksUrl = '$kApiBaseUrl/task-types';
  static const kLanguagesUrl = '$kApiBaseUrl/languages';
  static const kResetUrl = '$kApiBaseUrl/password/reset';
  static const kConditionsUrl = '$kApiBaseUrl/user-conditions';
  static const kUploadImageUrl = '/picture-put-url';
  static const kGetImageUrl = '/picture-get-url';

  /* Home APIs */
  static const kNewsUrl = '$kApiBaseUrl/external';
  static const kNewsTabUrl = '$kApiBaseUrl/external/subjects';
  static const kGetVolunteerList = '$kApiBaseUrl/volunteers';
  // ?date=2023-03-30&search=shahbaj&taskTypeCode=pharmacy&timeFrom=12%3A00&timeTo=02%3A00
  static const kGetTaskList = '$kApiBaseUrl/tasks';
  //completed=false&limit=10&offset=0&orderBy=id%20asc&upcoming=true
  static const kCreateTaskUrl = '$kApiBaseUrl/tasks';
  static const kAssignmentsUrl = '$kApiBaseUrl/assignments';

  static const kLeaderListUrl = '$kApiBaseUrl/api/agent/leaderList';
  /*Profile*/
  static const kGetProfileUrl = '$kApiBaseUrl/api/getprofile';
  static const kUpdateProfileUrl = '$kApiBaseUrl/api/updateProfile';
  static const kNewsListUrl = '$kApiBaseUrl/api/agent/newsList';


  /*SupportChat*/
  static const kGetTermConditionUrl =
      '$kApiBaseUrl/api/agent/getTermsConditionFaqInstruction';

  //chat
  static const kChat = '$kApiBaseUrl/chat';
  static const kGetChatToken = '$kChat/token';
}
