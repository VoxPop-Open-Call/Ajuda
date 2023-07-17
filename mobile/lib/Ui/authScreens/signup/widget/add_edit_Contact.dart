import 'package:ajuda/Ui/Utils/commanWidget/common_validations.dart';
import 'package:ajuda/Ui/Utils/theme/appcolor.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/commanWidget/CommonButton.dart';
import '../../../Utils/commanWidget/commonText.dart';
import '../../../Utils/commanWidget/textform_field.dart';
import '../../../Utils/font_style.dart';

class AddEditContact extends StatefulWidget {
  final number;
  final name;
  final Function(String, String) add;

  const AddEditContact({
    Key? key,
    this.number,
    this.name,
    required this.add,
  }) : super(key: key);

  @override
  State<AddEditContact> createState() => _AddEditContactState();
}

class _AddEditContactState extends State<AddEditContact>
    with CommonValidations {
  String? contactNameError, contactNumberError;
  String? contactName, contactNumber;

  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    if (widget.name != null) {
      nameController.text = widget.name;
      contactName = widget.name;
    }
    if (widget.number != null) {
      numberController.text = widget.number;
      contactNumber = widget.number;
    }
    setState(() {});
    super.initState();
  }

  void validateNumber(String? number) {
    contactNumberError = isValidPhoneNumber(number);
    setState(() {});
  }

  void validateName(String? name) {
    contactNameError = isValidName(name, 'login.name'.tr());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: AppColors.black.withOpacity(0.79),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: const BorderSide(color: AppColors.white),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 27,
                bottom: 32,
                left: 30,
                right: 30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  /*logo*/
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: SvgPicture.asset(
                      'assets/icon/profile_colored.svg',
                      height: 50,
                      width: 50,
                    ),
                  ),

                  /*new Contact*/
                  CommonText(
                    text: 'login.newContact'.tr(),
                    textAlign: TextAlign.left,
                    style: Poppins.semiBold(AppColors.mako).s18,
                    maxLines: 4,
                  ),

                  /*name*/
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CommonText(
                          text: 'login.name'.tr(),
                          textAlign: TextAlign.left,
                          style: Poppins.medium(AppColors.baliHai).s12,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  TextFormField_Common(
                    textEditingController: nameController,
                    contentPadding: 16,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
                    onChanged: (String? value) {
                      validateName(value);
                      contactName = value;
                    },
                    errorText: contactNameError,
                    hintText: 'login.name'.tr(),
                    textInputType: TextInputType.name,
                    maxLines: 1,
                    obscureText: false,
                    textColor: AppColors.mako,
                    textStyleHint:
                        Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                  ),

                  /*Phone number*/
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0, bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CommonText(
                          text: 'login.phoneNumber'.tr(),
                          textAlign: TextAlign.left,
                          style: Poppins.medium(AppColors.baliHai).s12,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  TextFormField_Number(
                    // textEditingController: numberController,
                    maxLines: 1,
                    contentPadding: 16,
                    textStyle: Poppins.semiBold(AppColors.mako).s15,
                    textInputType: const TextInputType.numberWithOptions(
                        signed: false, decimal: false),
                    errorText: contactNumberError,
                    onChanged: (String? value) {
                      validateNumber(value);
                      contactNumber = value;
                    },
                    hintText: '000-000-000',
                    obscureText: false,
                    initialText: numberController.text,
                    textColor: AppColors.mako,
                    textStyleHint:
                        Poppins.medium(AppColors.mako.withOpacity(0.7)).s15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40, bottom: 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonButton(
                          buttonText: 'login.cancel'.tr(),
                          borderColor: AppColors.madison.withOpacity(0.40),
                          backgroundColor: AppColors.trans,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          borderRadius: 27.0,
                          style: Poppins.bold(AppColors.madison).s14,
                          minimumSize: 110.0,
                          minimumWidget: 40,
                        ),
                        CommonButton(
                          buttonText: 'login.add'.tr(),
                          borderColor: AppColors.trans,
                          backgroundColor: AppColors.madison,
                          onPressed: () {
                            validateNumber(contactNumber);
                            validateName(contactName);
                            if (contactNameError == null &&
                                contactNameError == null) {
                              Navigator.of(context).pop();
                              widget.add(contactName!, contactNumber!.replaceAll(RegExp("[()-]"), ""));
                            }
                          },
                          borderRadius: 27.0,
                          style: Poppins.bold(AppColors.white).s14,
                          minimumSize: 110.0,
                          minimumWidget: 40,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
