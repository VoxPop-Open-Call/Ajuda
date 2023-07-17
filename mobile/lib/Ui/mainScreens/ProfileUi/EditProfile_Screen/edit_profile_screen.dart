import 'dart:io';

import 'package:ajuda/Ui/Utils/commanWidget/commonButtons.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:google_places_for_flutter/google_places_for_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../my_app.dart';
import '../../../Utils/alert.dart';
import '../../../Utils/base_screen.dart';
import '../../../Utils/commanWidget/CommonButton.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/network_image.dart';
import '../../../Utils/commanWidget/textform_field.dart';
import '../../../Utils/commanWidget/video_or_image.dart';
import '../../../Utils/font_style.dart';
import '../../../Utils/theme/appcolor.dart';
import '../../../Utils/view_model.dart';
import '../../../authScreens/signup/widget/add_edit_Contact.dart';
import '../../../authScreens/signup/widget/availability_widget.dart';
import '../widget/app_bar_widget.dart';

class EditProfileScreen extends StatefulWidget {
  static const String route = "EditProfileScreen";

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  void initState() {
    withViewModel<AuthViewModel>(context, (viewModel) {
      viewModel.setDataOfProfile();
      if (viewModel.userModel!.birthday != null) {
        viewModel.dobController!.text = DateFormat('dd-MM-yyyy')
            .format(DateTime.parse(viewModel.userModel!.birthday!))
            .toString();
      }
      if (viewModel.userModel!.location['address'] != null) {
        viewModel.locationController!.text =
            viewModel.userModel!.location['address']!;
      }
      viewModel.getGeoLocationPosition(false);
    });
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.profileEdited = () {
      Alert.showSnackBarSuccess(
          navigatorKey.currentContext!, provider.snackBarText!);
      Navigator.of(context).pop();
    };
    super.initState();
  }

  TextEditingController controller = TextEditingController();

  placesAutoCompleteTextField() {
    return GooglePlaceAutoCompleteTextField(
        textEditingController: controller,
        googleAPIKey: "MAPS_API_KEY",
        debounceTime: 800,
        countries: const ["in", "fr"],
        isLatLngRequired: true,
        getPlaceDetailWithLatLng: (Prediction prediction) {
          print("placeDetails" + prediction.lng.toString());
        },
        itmClick: (Prediction prediction) {
          print('prediction ${prediction.lat}');
          controller.text = prediction.description!;

          controller.selection = TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length));
        });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      color: AppColors.white,
      appBar: CommonAppBar(
        title: 'profile.editProfile'.tr(),
        color: AppColors.white,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding:
            const EdgeInsets.only(top: 20, right: 25, left: 22, bottom: 31),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.baliHai.withOpacity(0.10),
                              width: 6),
                        ),
                        child: provider.changeImage != null
                            ? CircleAvatar(
                                backgroundImage:
                                    FileImage(provider.changeImage!),
                                radius: 50,
                              )
                            : SizedBox(
                                height: 110,
                                width: 110,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(80.0),
                                  child: MyNetworkImage.circular(
                                      url: provider.userModel?.image ?? ''),
                                ),
                              ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell(
                          splashFactory: NoSplash.splashFactory,
                          onTap: () {
                            if (provider.changeImage != null) {
                              provider.changeImage = null;
                            } else {
                              showModalBottomSheet(
                                context: context,
                                builder: ((builder) => bottomSheet()),
                              );
                            }
                          },
                          child: SvgPicture.asset(
                            'assets/icon/camera.svg',
                            height: 36.0,
                            width: 36.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

            /*first Last Name*/
            Padding(
              padding: const EdgeInsets.only(top: 35.0, bottom: 5.0),
              child: CommonText(
                text: 'login.firstLastName'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().validateName(value);
                context.read<AuthViewModel>().userModel!.name = value;
              },
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.usernameError,
              ),
              hintText: 'login.firstLastName'.tr(),
              textInputType: TextInputType.name,
              maxLines: 1,
              obscureText: false,
              textColor: AppColors.mako,
              initialText: provider.userModel!.name,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),

            /*mobile Phone*/
            Padding(
              padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
              child: CommonText(
                text: 'login.mobilePhone'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Number(
              maxLines: 1,
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              textInputType: const TextInputType.numberWithOptions(
                  signed: false, decimal: false),
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.phoneNumberError,
              ),
              onChanged: (String? value) {
                context.read<AuthViewModel>().validateNumber(value);
                context.read<AuthViewModel>().userModel!.phoneNumber = value;
              },
              hintText: '000-000-000',
              obscureText: false,
              textColor: AppColors.mako,
              initialText: provider.userModel!.phoneNumber,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),

            /*Date Of Birth*/
            Padding(
              padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
              child: CommonText(
                text: 'login.dateOfBirth'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              contentPadding: 16,
              textEditingController: provider.dobController,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {},
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.dobError,
              ),
              onTap: () {
                provider.selectDate();
              },
              readOnly: true,
              hintText: '00-00-0000',
              textInputType: TextInputType.visiblePassword,
              maxLines: 1,
              obscureText: false,
              textColor: AppColors.mako,
              // initialText: provider.userModel!.birthday,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
              suffixIcon: const Icon(
                Icons.arrow_drop_down_sharp,
                color: AppColors.mako,
              ),
            ),

            /*email*/
            Padding(
              padding: const EdgeInsets.only(top: 35.0, bottom: 5.0),
              child: CommonText(
                text: 'login.email'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.medium(AppColors.baliHai).s12,
                maxLines: 1,
              ),
            ),
            TextFormField_Common(
              contentPadding: 16,
              textStyle: Poppins.semiBold(AppColors.mako).s15,
              onChanged: (String? value) {
                context.read<AuthViewModel>().validateEmail(value);

                context.read<AuthViewModel>().userModel!.email = value;
              },
              errorText: context.select<AuthViewModel, String?>(
                (AuthViewModel state) => state.emailError,
              ),

              readOnly: true,
              hintText: 'login.email'.tr(),
              textInputType: TextInputType.emailAddress,
              initialText: provider.userModel!.email,
              maxLines: 1,
              obscureText: false,
              textColor: AppColors.mako,
              textStyleHint:
                  Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
            ),

            /*Emergency Contact*/
            if (SharedPrefHelper.userType == '1')
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: 'login.emergencyContacts'.tr(),
                      textAlign: TextAlign.left,
                      style: Poppins.bold(AppColors.madison).s18,
                      maxLines: 1,
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddEditContact(
                              add: (String name, String number) {
                                provider.editContact(name, number);
                              },
                            );
                          },
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/icon/add.svg',
                        height: 36,
                        width: 36,
                      ),
                    )
                  ],
                ),
              ),
            if (SharedPrefHelper.userType == '1')
              provider.userModel!.elder != null &&
                      provider.userModel!.elder['emergencyContacts'] != null &&
                      provider.userModel!.elder['emergencyContacts'].isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(
                        top: 17,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          provider.userModel!.elder['emergencyContacts'].length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 17.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.0),
                              color: AppColors.alabaster,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15, right: 20.0, top: 15, bottom: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icon/profile_colored.svg',
                                          height: 50,
                                          width: 50,
                                        ),
                                        const SizedBox(
                                          width: 12.0,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              CommonText(
                                                text: provider.userModel!.elder[
                                                            'emergencyContacts']
                                                        ?[index]?['name'] ??
                                                    '',
                                                textAlign: TextAlign.left,
                                                style: Poppins.semiBold(
                                                        AppColors.madison)
                                                    .s16,
                                                maxLines: 3,
                                              ),
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'assets/images/call.svg',
                                                    height: 14,
                                                    width: 9.74,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  CommonText(
                                                    text: provider.userModel!
                                                                        .elder[
                                                                    'emergencyContacts']
                                                                ?[index]
                                                            ?['phoneNumber'] ??
                                                        '',
                                                    textAlign: TextAlign.left,
                                                    style: Poppins.regular(
                                                            AppColors.mako)
                                                        .s13,
                                                    maxLines: 1,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton(
                                    offset: const Offset(0, 75),
                                    icon: SvgPicture.asset(
                                      'assets/images/Combined Shape.svg',
                                      width: 5.8,
                                      height: 25,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                    ),
                                    itemBuilder: (_) => <PopupMenuEntry>[
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AddEditContact(
                                                  name: provider
                                                              .userModel!.elder[
                                                          'emergencyContacts']
                                                      [index]['name']!,
                                                  number: provider
                                                              .userModel!.elder[
                                                          'emergencyContacts']
                                                      [index]['phoneNumber']!,
                                                  add: (String name,
                                                      String number) {
                                                    provider.editContact(
                                                        name, number,
                                                        index: index);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 10.0, bottom: 30.0),
                                            alignment: Alignment.centerLeft,
                                            height: 55.0,
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.fantasy,
                                            ),
                                            child: CommonText(
                                              text: 'login.editContact'.tr(),
                                              style: Poppins.semiBold(
                                                      AppColors.bittersweet)
                                                  .s16,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          splashFactory: NoSplash.splashFactory,
                                          onTap: () {
                                            provider.removeContact(
                                                index, false);
                                          },
                                          child: Container(
                                            alignment: Alignment.centerLeft,
                                            height: 55.0,
                                            padding: const EdgeInsets.only(
                                                left: 24.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.fantasy,
                                            ),
                                            child: CommonText(
                                              text: 'login.deleteContact'.tr(),
                                              style: Poppins.semiBold(
                                                      AppColors.bittersweet)
                                                  .s16,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                          },
                                          splashFactory: NoSplash.splashFactory,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                              color: AppColors.trans,
                                            ),
                                            child: CommonText(
                                              text: 'login.cancel'.tr(),
                                              style: Poppins.semiBoldUnderLine(
                                                      AppColors.madison)
                                                  .s13,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: SvgPicture.asset(
                        'assets/images/onBoarding/illustrations-4.svg',
                        width: 268.8,
                        height: 218.74,
                      ),
                    ),

            /*Residence Area*/
            Padding(
              padding: const EdgeInsets.only(top: 60.0, bottom: 5.0),
              child: CommonText(
                text: SharedPrefHelper.userType == '1'
                    ? 'login.ResidenceArea'.tr()
                    : 'login.helpArea'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            // placesAutoCompleteTextField(),

            /*location*/
            Padding(
              padding: const EdgeInsets.only(top: 9.0, bottom: 5.0),
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
                provider.setMapOnSearchLocation(place, false);
              },
              onSearch: (Place place) {},
            ),
            // TextFormField_Common(
            //   contentPadding: 16,
            //   textEditingController: provider.locationController,
            //   textStyle: Poppins.semiBold(AppColors.mako).s15,
            //   onChanged: (String? value) {
            //     provider.addLatLong(value!, false);
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
            //       Navigator.pushNamed(context, AddressSearch.route);
            //       // provider.addLatLong(provider.locationController!.text, true);
            //       // provider.getGeoLocationPosition(type);
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
                myLocationButtonEnabled: false,
                initialCameraPosition: provider.initialLocation,
                onMapCreated: (GoogleMapController controller) {
                  if (controller != null) {
                    provider.mapController = controller;
                  }
                },
                /*    circles: provider.userModel!.location != null
                    ? {
                        Circle(
                          circleId: const CircleId('currentCircle'),
                          center: LatLng(
                              provider.userModel!.location['lat'] != 0
                                  ? provider.userModel!.location['lat']
                                  : double.parse(provider
                                      .userModel!.location['lat']
                                      .toString()),
                              provider.userModel!.location['long'] != 0
                                  ? provider.userModel!.location['long']
                                  : double.parse(provider
                                      .userModel!.location['long']
                                      .toString())),
                          radius: 400,
                          fillColor: AppColors.bittersweet.withOpacity(0.05),
                          strokeColor: AppColors.black.withOpacity(0.05),
                          strokeWidth: 2,
                        ),
                      }
                    : {},*/
                markers: Set<Marker>.of(
                    provider.markers.values), // YOUR MARKS IN MAP
              ),
            ),

            /*language*/
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
              child: CommonText(
                text: 'language.languagesSpoken'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.mako).s16,
                maxLines: 1,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 9.0),
              decoration: BoxDecoration(
                color: AppColors.alabaster,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 17, right: 20, left: 20),
                itemCount: provider.language.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      provider.selectService(3, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: CommonText(
                              text:  ('language.${provider.language[index].id}').tr(),
                              textAlign: TextAlign.left,
                              style: Poppins.medium(AppColors.mako).s15,
                              maxLines: 3,
                            ),
                          ),
                          SvgPicture.asset(provider.language[index].select
                              ? 'assets/icon/checkbox-on.svg'
                              : "assets/icon/checkbox-off.svg"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /*desiredServices*/
            if (SharedPrefHelper.userType == '2')
              Padding(
                padding: const EdgeInsets.only(top: 60.0, bottom: 5.0),
                child: CommonText(
                  text: 'login.servicesProvided'.tr(),
                  textAlign: TextAlign.left,
                  style: Poppins.bold(AppColors.mako).s16,
                  maxLines: 1,
                ),
              ),
            if (SharedPrefHelper.userType == '2')
              Container(
                margin: const EdgeInsets.only(top: 9.0),
                decoration: BoxDecoration(
                  color: AppColors.alabaster,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 17, right: 20, left: 20),
                  itemCount: provider.desiredServices.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        provider.selectService(1, index);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 17.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            CommonText(
                              text: 'servicesNeeds.${provider
                                  .desiredServices[index].title}'.tr(),
                              textAlign: TextAlign.left,
                              style: Poppins.medium(AppColors.mako).s15,
                              maxLines: 1,
                            ),
                            SvgPicture.asset(
                                provider.desiredServices[index].select
                                    ? 'assets/icon/checkbox-on.svg'
                                    : "assets/icon/checkbox-off.svg"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            /*conditions*/
            Padding(
              padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
              child: CommonText(
                text: 'login.conditions'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.mako).s16,
                maxLines: 1,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 9.0),
              decoration: BoxDecoration(
                color: AppColors.alabaster,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 17, right: 20, left: 20),
                itemCount: provider.conditions.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      provider.selectService(2, index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 17.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CommonText(
                            text: provider
                                .capitalize('servicesNeeds.${provider
                                .conditions[index].title}'.tr()),
                            textAlign: TextAlign.left,
                            style: Poppins.medium(AppColors.mako).s15,
                            maxLines: 1,
                          ),
                          SvgPicture.asset(provider.conditions[index].select
                              ? 'assets/icon/checkbox-on.svg'
                              : "assets/icon/checkbox-off.svg"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            /*availability*/
            if (SharedPrefHelper.userType == '2')
              Padding(
                padding: const EdgeInsets.only(top: 32.0, bottom: 5.0),
                child: CommonText(
                  text: 'Availability.availability'.tr(),
                  textAlign: TextAlign.left,
                  style: Poppins.bold(AppColors.mako).s16,
                  maxLines: 1,
                ),
              ),
            if (SharedPrefHelper.userType == '2')
              ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: provider.weekdays.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return AvailabilityWidget(
                    tab: () {
                      provider.selectService(4, index);
                    },
                    title: provider.weekdays[index].title!.tr(),
                    startTime: provider.weekdays[index].startTime ??
                        DateFormat('h:mm').format(DateTime.now()),
                    endTime: provider.weekdays[index].endTime ??
                        DateFormat('h:mm').format(DateTime.now()),
                    selected: provider.weekdays[index].select,
                    startDateTab: () {
                      provider.showTimePickerView(true, index, context);
                    },
                    endDateTab: () {
                      provider.showTimePickerView(false, index, context);
                    },
                  );
                },
              ),

            /*cancel-save*/
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    buttonText: 'login.cancel'.tr(),
                    borderColor: AppColors.madison,
                    backgroundColor: AppColors.trans,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: 20.0,
                    style: Poppins.semiBold(AppColors.madison).s15,
                    minimumSize: 148.0,
                    minimumWidget: 50,
                  ),
                  CommonButtonLoading<AuthViewModel>(
                    text: 'volunteer.save'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: AppColors.madison,
                    onPressed: () {
                      provider.updateProfile(
                          SharedPrefHelper.userType == '2' ? true : false);
                    },
                    borderRadius: 20.0,
                    style: Poppins.semiBold(AppColors.white).s15,
                    minimumSize: 148.0,
                    // minimumWidget: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PickedFile? imageFile;
  final ImagePicker picker = ImagePicker();

  void takePhoto(ImageSource pickerSource) async {
    String filePath;
    final pickedFile = await ImagePicker().pickImage(
      source: pickerSource,
    );
    filePath = pickedFile!.path;

    if (filePath == null) return;

    File file = File(filePath);

    double size = await ImageOrVideo.getSizeInMb(file);

    print('original Size: $size');
    // image compression started
    file = await ImageOrVideo.getCompressedImage(file);
    // image compression successful
    double compressedSize = await ImageOrVideo.getSizeInMb(file);
    print('Compressed Size: $compressedSize');
    // if size of image is greater than 10MB DO NOT ALLOW THAT image
    if (compressedSize > 30) {
      // context.loaderOverlay.hide();
      /* before showing alert, delete this useless file */
      file.deleteSync();

      return Alert.showSnackBar(
        context,
        'login.imageSize'.tr(),
        durationInMilliseconds: 4000,
      );
    }

    filePath = file.path;
    if (filePath == null) return;

    print(filePath);

    setState(() {
      imageFile = PickedFile(filePath);
    });

    context.read<AuthViewModel>().changeImage = File(filePath);
  }

  Widget bottomSheet() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 10,
        ),
        CommonText(
            text: "Choose Profile Photo",
            style: Poppins.semiBold(AppColors.madison).s15,
            maxLines: 1,
            textAlign: TextAlign.center),
        const SizedBox(
          height: 10,
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            takePhoto(ImageSource.camera);
          },
          label: CommonText(
              text: "Camera",
              style: Poppins.semiBold(AppColors.madison).s15,
              maxLines: 1,
              textAlign: TextAlign.center),
          icon: const Icon(
            Icons.camera,
            color: AppColors.madison,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            takePhoto(ImageSource.gallery);
          },
          label: CommonText(
              text: "Gallery",
              style: Poppins.semiBold(AppColors.madison).s15,
              maxLines: 1,
              textAlign: TextAlign.center),
          icon: const Icon(
            Icons.image,
            color: AppColors.madison,
          ),
        ),
      ],
    );
  }
}
