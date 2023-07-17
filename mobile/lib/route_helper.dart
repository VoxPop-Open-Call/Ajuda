// Global Access
import 'package:ajuda/Ui/Utils/transitions.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/authScreens/forgot_password/forgot_password.dart';
import 'package:ajuda/Ui/authScreens/login/login_screen.dart';
import 'package:ajuda/Ui/authScreens/on_boarding/on_boarding_screen.dart';
import 'package:ajuda/Ui/authScreens/on_boarding/on_boarding_view_model.dart';
import 'package:ajuda/Ui/authScreens/signup/availability_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/cover_photo_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/emergency_contacts_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/language_spoken.dart';
import 'package:ajuda/Ui/authScreens/signup/residence_area_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/service_needs.dart';
import 'package:ajuda/Ui/authScreens/signup/sign_up_screen.dart';
import 'package:ajuda/Ui/authScreens/signup/with_us_screen.dart';
import 'package:ajuda/Ui/bottombarScreen/HomeMainScreen.dart';
import 'package:ajuda/Ui/mainScreens/HomeUi/homeViewModel.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsDetailsScreen.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsViewModel.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AboutUs_Sreen/about_us_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/app_setting_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/delete_account_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/AppSetting_Screen/language_screen/language.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/EditProfile_Screen/address_search.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/EditProfile_Screen/edit_profile_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/HelpContact_Screen/help_contacts_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/History_Screen/history_screen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileViewModel.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/chat_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/ChatUi/chat_view_model.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/PendingRequestUi/pading_request_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/PendingRequestUi/pending_request_details.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RateUsUi/reateUsScreen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/AfterCancelationUi/canceldScreen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/AfterCancelationUi/selectNewVolunteerScreen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/RequestDetailUi/request_details_screen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestViewModel.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/NewRequestScreen/newRequestStepScreen.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/NewRequestScreen/new_request_screen.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/VolunteersProfile/VolunteersProfileScreen.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteerViewModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Ui/authScreens/forgot_password/conform_email.dart';

ValueNotifier<int> changeIndex = ValueNotifier<int>(0);

class RouteHelper with Transitions {
  final _homeViewModel = HomeViewModel();
  final _requestViewModel = RequestViewModel();
  final _volunteerViewModel = VolunteerViewModel();
  final _newsViewModel = NewsViewModel();
  final _profileViewModel = ProfileViewModel();
  final _authViewModel = AuthViewModel();

  Map<String, WidgetBuilder> createRoutes() {
    return {
      //----TabBar's Screen Route-----//
      HomeMainScreen.route: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: _homeViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _requestViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _volunteerViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _newsViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _authViewModel,
              ),
            ],
            child: const HomeMainScreen(),
          ),

      NewRequestStepScreen.route: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: _homeViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _volunteerViewModel,
              ),
            ],
            child: const NewRequestStepScreen(),
          ),

      //----Auth's Screen Route-----//
      LoginScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const LoginScreen(),
          ),
      ForgotPassword.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const ForgotPassword(),
          ),
      ConformEmail.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const ConformEmail(),
          ),
      OnBoardingScreen.route: (_) => ChangeNotifierProvider.value(
            value: OnBoardingViewModel(),
            child: const OnBoardingScreen(),
          ),
      SignUpScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const SignUpScreen(),
          ),
      WithUsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const WithUsScreen(),
          ),
      CoverPhotoScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const CoverPhotoScreen(),
          ),
      LanguagesSpoken.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const LanguagesSpoken(),
          ),
      ResidenceAreaScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const ResidenceAreaScreen(),
          ),
      ServiceAndNeedScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const ServiceAndNeedScreen(),
          ),
      AvailabilityScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const AvailabilityScreen(),
          ),
      EmergencyContactsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const EmergencyContactsScreen(),
          ),

      //
      NewsDetailsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _newsViewModel,
            child: const NewsDetailsScreen(),
          ),

      //----Profile's Screen Route-----//
      LanguageScreen.route: (_) => ChangeNotifierProvider.value(
            value: _profileViewModel,
            child: const LanguageScreen(),
          ),
      AccountDeleteScreen.route: (_) => ChangeNotifierProvider.value(
            value: _profileViewModel,
            child: const AccountDeleteScreen(),
          ),
      AppSettingScreen.route: (_) => ChangeNotifierProvider.value(
            value: _profileViewModel,
            child: const AppSettingScreen(),
          ),
      AboutUsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _profileViewModel,
            child: const AboutUsScreen(),
          ),
      HelpContactsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const HelpContactsScreen(),
          ),
      HistoryScreen.route: (_) => ChangeNotifierProvider.value(
            value: _profileViewModel,
            child: const HistoryScreen(),
          ),

      EditProfileScreen.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const EditProfileScreen(),
          ),

      AddressSearch.route: (_) => ChangeNotifierProvider.value(
            value: _authViewModel,
            child: const AddressSearch(),
          ),

      //----Volunteers Profile's Screen Route-----//
      VolunteersProfileScreen.route: (_) => ChangeNotifierProvider.value(
            value: _volunteerViewModel,
            child: const VolunteersProfileScreen(),
          ),
      NewRequestScreen.route: (_) => ChangeNotifierProvider.value(
            value: _volunteerViewModel,
            child: const NewRequestScreen(),
          ),

      //----Rate Us Screen Route-----//

      RateUsScreen.route: (_) => ChangeNotifierProvider.value(
            value: _requestViewModel,
            child: const RateUsScreen(),
          ),
      //----Request Detail Screen Route-----//

      RequestDetailScreen.route: (_) => ChangeNotifierProvider.value(
            value: _requestViewModel,
            child: const RequestDetailScreen(),
          ),

      CanceledScreen.route: (_) => ChangeNotifierProvider.value(
            value: _requestViewModel,
            child: const CanceledScreen(),
          ),

      ChatScreen.route: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => ChatViewModel()),
              ChangeNotifierProvider.value(
                value: _requestViewModel,
              ),
              ChangeNotifierProvider.value(
                value: _authViewModel,
              ),
            ],
            child: const ChatScreen(),
          ),

      SelectNewVolunteerScreen.route: (_) => ChangeNotifierProvider.value(
            value: _volunteerViewModel,
            child: const SelectNewVolunteerScreen(),
          ),

      PendingRequestScreen.route: (_) => ChangeNotifierProvider.value(
            value: _requestViewModel,
            child: const PendingRequestScreen(),
          ),

      PendingRequestDetails.route: (_) => ChangeNotifierProvider.value(
            value: _requestViewModel,
            child: const PendingRequestDetails(),
          ),
    };
  }
}
