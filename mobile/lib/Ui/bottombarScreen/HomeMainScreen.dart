import 'package:ajuda/Ui/mainScreens/HomeUi/homeScreen.dart';
import 'package:ajuda/Ui/mainScreens/NewsUi/newsScreen.dart';
import 'package:ajuda/Ui/mainScreens/ProfileUi/profileScreen.dart';
import 'package:ajuda/Ui/mainScreens/RequestUi/requestScreen.dart';
import 'package:ajuda/Ui/mainScreens/VolunteersUi/volunteersScreen.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../route_helper.dart';
import '..//Utils/font_style.dart';

class HomeMainScreen extends StatefulWidget {
  static const String route = "HomeMainScreen";

  const HomeMainScreen({Key? key}) : super(key: key);

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  final screens1 = [
    const HomeScreen(),
    const RequestScreen(),
    const VolunteersScreen(),
    const NewsScreen(),
    const ProfileScreen(),
  ];

  final screens2 = [
    const HomeScreen(),
    const RequestScreen(),
    const NewsScreen(),
    const ProfileScreen(),
  ];

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      key: scaffoldKey,
      // drawer: const MainDrawer(),
      body: ValueListenableBuilder<int>(
        valueListenable: changeIndex,
        builder: (_, int x, __) {
          return SharedPrefHelper.userType=='1'?screens1[x]:screens2[x];
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: changeIndex,
        builder: (_, int x, __) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: BottomNavigationBar(
              backgroundColor: AppColors.white,
              type: BottomNavigationBarType.fixed,
              iconSize: 30,
              showSelectedLabels: true,
              selectedLabelStyle: Poppins.semiBold(AppColors.bittersweet).s10,
              unselectedLabelStyle:
                  Poppins.medium(AppColors.mako.withOpacity(0.40)).s10,
              currentIndex: x,
              onTap: (index) => setState(
                () {
                  changeIndex.value = index;
                  changeIndex.notifyListeners();
                },
              ),
              items: [
                /*Home*/
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/home.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.mako.withOpacity(0.40),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/home.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.bittersweet,
                  ),
                  label: 'homeName'.tr(),
                  backgroundColor: AppColors.bittersweet,
                ),

                /*Requests*/
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/requests.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.mako.withOpacity(0.40),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/requests.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.bittersweet,
                  ),
                  label: 'requests'.tr(),
                  backgroundColor: AppColors.bittersweet,
                ),

                /*Volunteers*/
                if(SharedPrefHelper.userType=='1')
                BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/icon/volunteers.svg',
                      width: 25,
                      height: 25,
                      color: AppColors.mako.withOpacity(0.40),
                    ),
                    activeIcon: SvgPicture.asset(
                      'assets/icon/volunteers.svg',
                      width: 25,
                      height: 25,
                      color: AppColors.bittersweet,
                    ),
                    label: 'volunteers'.tr(),
                    backgroundColor: AppColors.bittersweet),

                /*News*/
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/news.svg',
                    width: 22,
                    height: 22,
                    color: AppColors.mako.withOpacity(0.40),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/news.svg',
                    color: AppColors.bittersweet,
                    width: 22,
                    height: 22,
                  ),
                  label: 'news'.tr(),
                  backgroundColor: AppColors.bittersweet,
                ),

                /*Profile*/
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icon/profileBottom.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.mako.withOpacity(0.40),
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icon/profileBottom.svg',
                    width: 20,
                    height: 20,
                    color: AppColors.bittersweet,
                  ),
                  label: 'profileName'.tr(),
                  backgroundColor: AppColors.bittersweet,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
