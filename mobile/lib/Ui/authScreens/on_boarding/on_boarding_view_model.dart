import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';

import '../../Utils/view_model.dart';
import '../../../data/remote/model/onBoardingModel/info_model.dart';

class OnBoardingViewModel extends ViewModel with CommonValidations {
  int _initialIndex = 0;

  int get initialIndex => _initialIndex;

  set initialIndexSet(val) {
    _initialIndex = val;
    notifyListeners();
  }

  List<InfoModel> infoList = [
    InfoModel(
      title: 'onBoarding.lookingForHelp?',
      imagePath: "assets/images/onBoarding/illustrations-1.svg",
      subtitle: 'onBoarding.HelpOrGetHelp',
      description: 'onBoarding.helpOrLookForSomeoneToHelpWithDayToDayTasks',
    ),

    InfoModel(
      title: 'onBoarding.services',
      imagePath: "assets/images/onBoarding/illustrations.svg",
      subtitle: 'onBoarding.selectTheServices',
      description: 'onBoarding.selectTheServicesYouNeed',
    ),

    InfoModel(
      title: 'onBoarding.volunteers',
      imagePath: "assets/images/onBoarding/illustrations-7.svg",
      subtitle: 'onBoarding.chooseWhoCanHelpYou',
      description: 'onBoarding.listOfAvailableVolunteers',
    ),

    InfoModel(
      title: 'onBoarding.availability',
      imagePath: "assets/images/onBoarding/illustrations-6.svg",
      subtitle: 'onBoarding.pickDateAndTime',
      description: 'onBoarding.residenceAndTheTimes',
    ),

    InfoModel(
      title: 'onBoarding.history',
      imagePath: "assets/images/onBoarding/illustrations-3.svg",
      subtitle: 'onBoarding.servicesHistory',
      description: 'onBoarding.consultTheHistory',
    ),
    InfoModel(
      title: 'onBoarding.joinUs',
      imagePath: "assets/images/onBoarding/illustrations-2.svg",
      subtitle: 'onBoarding.chooseYourUserType',
      description: 'onBoarding.userDepending',
    )
  ];
}
