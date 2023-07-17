import 'dart:io';

import 'package:ajuda/Ui/Utils/font_style.dart';
import 'package:ajuda/Ui/Utils/view_model.dart';
import 'package:ajuda/Ui/authScreens/auth_view_model.dart';
import 'package:ajuda/Ui/authScreens/signup/residence_area_screen.dart';
import 'package:ajuda/data/local/shared_pref_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Utils/alert.dart';
import '../../Utils/base_screen.dart';
import '../../Utils/commanWidget/CommonButton.dart';
import '../../Utils/commanWidget/commonText.dart';
import '../../Utils/commanWidget/video_or_image.dart';
import '../../Utils/theme/appcolor.dart';

class CoverPhotoScreen extends StatefulWidget {
  static const String route = "CoverPhotoScreen";

  const CoverPhotoScreen({Key? key}) : super(key: key);

  @override
  State<CoverPhotoScreen> createState() => _CoverPhotoScreenState();
}

class _CoverPhotoScreenState extends State<CoverPhotoScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final provider = Provider.of<AuthViewModel>(context, listen: false);
    provider.imageUploaded = () {
      Navigator.pushNamed(context, ResidenceAreaScreen.route);
    };
    withViewModel<AuthViewModel>(context, (viewModel) {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthViewModel>();
    return BaseScreen<AuthViewModel>(
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 30, bottom: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            /*coverPicture*/
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 5.0),
              child: CommonText(
                text: 'login.profilePicture'.tr(),
                textAlign: TextAlign.left,
                style: Poppins.bold(AppColors.madison).s18,
                maxLines: 1,
              ),
            ),

            /*knowing*/
            CommonText(
              text: SharedPrefHelper.userType == '2'
                  ? 'login.knowing'.tr()
                  : 'login.adding'.tr(),
              textAlign: TextAlign.left,
              style: Poppins.medium(AppColors.baliHai).s15,
              maxLines: 6,
            ),

            /*image*/
            Expanded(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 33),
                    decoration: BoxDecoration(
                        color: AppColors.mako.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6.0)),
                    height: 325,
                    width: 325,
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6.0),
                          child: provider.changeImage != null
                              ? Center(
                                  child: Image.file(
                                    provider.changeImage!,
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                  ),
                                )
                              : Center(
                                  child: SvgPicture.asset(
                                    'assets/icon/cover_profile.svg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(right: 16.0, bottom: 15),
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
                                provider.changeImage != null
                                    ? 'assets/icon/delete.svg'
                                    : 'assets/icon/camera.svg',
                                height: 50,
                                width: 50,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /*back-next*/
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonButton(
                    buttonText: 'login.back'.tr(),
                    borderColor: AppColors.trans,
                    backgroundColor: AppColors.madison.withOpacity(0.08),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    borderRadius: 27.0,
                    style: Poppins.bold(AppColors.madison).s14,
                    minimumSize: 145.0,
                  ),
                  SharedPrefHelper.userType == '1'
                      ? CommonButton(
                          buttonText: 'login.next'.tr(),
                          borderColor: AppColors.madison,
                          backgroundColor: AppColors.madison,
                          onPressed: () {
                            Navigator.pushNamed(
                                context, ResidenceAreaScreen.route);
                          },
                          borderRadius: 27.0,
                          style: Poppins.bold(AppColors.white).s14,
                          minimumSize: 145.0,
                        )
                      : CommonButton(
                          buttonText: 'login.next'.tr(),
                          borderColor: provider.changeImage == null
                              ? AppColors.trans
                              : AppColors.madison,
                          backgroundColor: provider.changeImage == null
                              ? AppColors.madison.withOpacity(0.08)
                              : AppColors.madison,
                          onPressed: provider.changeImage != null
                              ? () {
                                  provider.getImageUrl();
                                }
                              : () {},
                          borderRadius: 27.0,
                          style: Poppins.bold(provider.changeImage == null
                                  ? AppColors.madison.withOpacity(0.30)
                                  : AppColors.white)
                              .s14,
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

  PickedFile? _imageFile;
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
      _imageFile = PickedFile(filePath);
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
