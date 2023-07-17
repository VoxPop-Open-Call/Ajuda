import 'package:ajuda/Ui/Utils/alert.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/signup/language_spoken.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'package:provider/provider.dart';

import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/font_style.dart';
import '../../Utils/theme/appcolor.dart';
import '../auth_view_model.dart';

class ResidenceAreaScreen extends StatefulWidget {
  const ResidenceAreaScreen({Key? key}) : super(key: key);
  static const String route = "ResidenceAreaScreen";

  @override
  State<ResidenceAreaScreen> createState() => _ResidenceAreaScreenState();
}

class _ResidenceAreaScreenState extends State<ResidenceAreaScreen> {
  @override
  void initState() {
    withViewModel<AuthViewModel>(context, (viewModel) {
      viewModel.maxDistance = null;
      viewModel.getGeoLocationPosition(true);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Residence Area*/
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
              child: CommonText(
                text: SharedPrefHelper.userType == "1"
                    ? 'login.ResidenceArea'.tr()
                    : 'login.helpArea'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*volunteers You Request*/
            CommonText(
              text: SharedPrefHelper.userType == "1"
                  ? 'login.volunteersYouRequest'.tr()
                  : 'login.pleaseDefine'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 4,
            ),

            /*location*/
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.location'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                    ),
                  ),

                  SearchGooglePlacesWidget(
                    apiKey: 'MAPS_API_KEY',
                    // The language of the autocompletion
                    language: 'en',
                    // The position used to give better recommendations. In this case we are using the user position
                    // radius: 30000,
                    hasClearButton: true,
                    placeholder: provider.locationController!.text,

                    placeType: PlaceType.address,
                    icon: Icons.my_location,
                    iconColor: AppColors.mako,
                    onSelected: (Place place) async {
                      provider.setMapOnSearchLocation(place, true);
                    },
                    onSearch: (Place place) {},
                  ),

                  // TextFormField_Common(
                  //   contentPadding: 16,
                  //   textEditingController: provider.locationController,
                  //   textStyle: Poppins.semiBold(AppColors.mako).s15,
                  //   onChanged: (String? value) {
                  //     provider.addressLatLong(value!);
                  //   },
                  //   errorText: context.select<AuthViewModel, String?>(
                  //     (AuthViewModel state) => state.locationError,
                  //   ),
                  //   hintText: 'login.location'.tr(),
                  //   textInputType: TextInputType.visiblePassword,
                  //   maxLines: 1,
                  //   obscureText: false,
                  //   textColor: AppColors.mako,
                  //   textStyleHint:
                  //       Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                  //   suffixIcon: InkWell(
                  //     onTap: () {
                  //       provider.getGeoLocationPosition(true);
                  //     },
                  //     child: const Icon(
                  //       Icons.my_location,
                  //       color: AppColors.mako,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(
                    height: 32,
                  ),

                  /*MAP*/
                  SizedBox(
                    height: 325,
                    width: 325,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: false,
                      markers: Set<Marker>.of(provider.markers.values),
                      myLocationButtonEnabled: false,
                      initialCameraPosition: provider.initialLocation,
                      onMapCreated: (GoogleMapController controller) {
                        if (controller != null) {
                          provider.mapController = controller;
                        }
                      },
                      /*   circles: provider.position != null
                          ? {
                              Circle(
                                circleId: CircleId('currentCircle'),
                                center: LatLng(provider.position!.latitude,
                                    provider.position!.longitude),
                                radius: 4000,
                                fillColor:
                                    AppColors.bittersweet.withOpacity(0.05),
                                strokeColor:
                                    AppColors.bittersweet.withOpacity(0.05),
                                strokeWidth: 2,
                              ),
                            }
                          : {},*/
                    ),
                  ),

                  /*maximumDistance*/
                  if (SharedPrefHelper.userType == '2')
                    Padding(
                      padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
                      child: CommonText(
                        text: 'login.maximumDistance'.tr(),
                        textAlign: TextAlign.left,
                        style: Poppins.medium(AppColors.baliHai).s12,
                        maxLines: 1,
                      ),
                    ),
                  if (SharedPrefHelper.userType == '2')
                    DropdownButton<String>(
                      isExpanded: true,
                      value: provider.maxDistance,
                      elevation: 1,

                      borderRadius: BorderRadius.circular(8.0),
                      icon: const Padding(
                        padding: EdgeInsets.only(
                          right: 11,
                        ),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                      underline: const SizedBox.shrink(),

                      // style: Poppins.medium(AppColors.mako).s15,
                      items: <String>[
                        '10 km',
                        '20 km',
                        '30 km',
                        '40 km',
                        '50 km',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: CommonText(
                              text: value,
                              style: Poppins.medium(AppColors.mako).s16,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }).toList(),
                      hint: CommonText(
                        text: "   ${"login.chooseMaximumDistance".tr()}  ",
                        style: Poppins.medium(AppColors.mako.withOpacity(0.50))
                            .s13,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                      onChanged: (String? value) {
                        provider.maxDistance = value;
                      },
                    ),
                  /*
                  Padding(
                    padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
                    child: CommonText(
                      text: 'login.maximumDistance'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.medium(AppColors.baliHai).s12,
                      maxLines: 1,
                    ),
                  ),
                  DropdownButton<String>(
                    value: provider.maxDistance,
                    elevation: 1,
                    borderRadius: BorderRadius.circular(8.0),
                    icon: const Padding(
                      padding: EdgeInsets.only(
                        right: 11,
                      ),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                    underline: const SizedBox.shrink(),
                    // style: Poppins.medium(AppColors.mako).s15,
                    items: <String>[
                      '10 km',
                      '20 km',
                      '30 km',
                      '40 km',
                      '50 km',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: CommonText(
                            text: value,
                            style: Poppins.medium(AppColors.mako).s16,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }).toList(),
                    hint: CommonText(
                      text: "   ${"login.chooseMaximumDistance".tr()}  ",
                      style:
                          Poppins.medium(AppColors.mako.withOpacity(0.50)).s13,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                    ),
                    onChanged: (String? value) {
                      provider.maxDistance = value;
                    },
                  )*/
                ],
              ),
            ),

            /*next back*/
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, top: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    buttonText: 'login.back'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: AppColors.madison.withOpacity(0.08),
                    onPressed: () => Navigator.of(context).pop(),
                    borderRadius: 27.0,
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 145.0,
                  ),
                  if (SharedPrefHelper.userType == '2')
                    CommonButton(
                      buttonText: 'login.next'.tr(),
                      borderColor: provider.maxDistance != null &&
                              provider.maxDistance!.isNotEmpty
                          ? AppColors.madison
                          : AppColors.trans,
                      backgroundColor: provider.maxDistance != null &&
                              provider.maxDistance!.isNotEmpty
                          ? AppColors.madison
                          : AppColors.madison.withOpacity(0.08),
                      onPressed: provider.maxDistance != null &&
                              provider.maxDistance!.isNotEmpty
                          ? () => Navigator.pushNamed(
                              context, LanguagesSpoken.route)
                          : () {
                              Alert.showSnackBar(
                                  context, 'login.chooseMaximumDistance'.tr());
                            },
                      borderRadius: 27.0,
                      style: Poppins.bold(provider.maxDistance != null &&
                                  provider.maxDistance!.isNotEmpty
                              ? AppColors.white
                              : AppColors.madison)
                          .s14,
                      minimumSize: 145.0,
                    ),
                  if (SharedPrefHelper.userType == '1')
                    CommonButton(
                      buttonText: 'login.next'.tr(),
                      borderColor: AppColors.madison,
                      backgroundColor: AppColors.madison,
                      onPressed: () =>
                          Navigator.pushNamed(context, LanguagesSpoken.route),
                      borderRadius: 27.0,
                      style: Poppins.bold(AppColors.white).s14,
                      minimumSize: 145.0,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
