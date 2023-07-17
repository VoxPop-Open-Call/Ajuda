import 'package:easy_localization/easy_localization.dart';

import 'email_Validator.dart';

mixin CommonValidations {
  static const int passwordMinLength = 8;
  static const int cvvMinLength = 3;
  static const int cvvMaxLength = 4;

  String? isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return "validate.passwordRequired".tr();
    } else if (password.length < passwordMinLength) {
      return "${"validate.passwordShouldBe".tr()} $passwordMinLength ${"validate.passwordShouldBe1".tr()}";
    } else {
      return null;
    }
  }

  String? isValidConfirmPasswords(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "validate.conPasswordRequired".tr();
    } else if (confirmPassword.length < passwordMinLength) {
      return "${"validate.confirm_passwordShouldBe".tr()} $passwordMinLength ${"validate.passwordShouldBe1".tr()}";
    } else if (password != confirmPassword) {
      return "validate.passwordNotMatched".tr();
    } else {
      return null;
    }
  }

  String? isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "validate.emailRequired".tr();
    }

/*    final isValid = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    ).hasMatch(email.trim());*/

    final isValid = EmailValidator.validate(email);


    if (isValid) {
      return null;
    } else {
      return "validate.wrongEmail".tr();
    }
  }

  String? isValidPhoneNumber(String? phone) {
    phone = phone?.trim();
    // final specialCharacterRegex = RegExp(r'[!@#$%&*()_=|<>?{}~]');
    // final phoneUnformatted = phone!.replaceAll(RegExp("[()-]"), "");

    if (phone == null || phone.isEmpty) {
      return "validate.phoneRequired".tr();
    }
    /*else if (specialCharacterRegex.hasMatch(phone)) {
      return "Phone Number should not contain any special characters";
    }*/
    else {
      final phoneUnformatted = phone.replaceAll(RegExp("[()-]"), "");
      if (phoneUnformatted.length > 9) {
        return "validate.Phone_cannot_contain_more_than_characters".tr();
      } else if (phoneUnformatted.length < 9) {
        return "validate.Phone_cannot_contain_less_than_characters".tr();
      } else {
        return null;
      }
    }
  }

  String? isReTypePasswordValidation(
      String? password, String? Confirm_Password) {
    if (Confirm_Password == null || Confirm_Password.isEmpty) {
      return "validate.reTypeNeWPassCannotEmpty".tr();
    }
    if (Confirm_Password.trim() == password?.trim()) {
      return null;
    } else {
      return "validate.PasswordsNotMatch".tr();
    }
  }

  String? isConfirmPasswordValid(String? password, String? Confirm_Password) {
    if (Confirm_Password == null || Confirm_Password.isEmpty) {
      return "validate.conPasswordRequired".tr();
    }
    if (Confirm_Password.trim() == password?.trim()) {
      return null;
    } else {
      return "validate.PasswordsNotMatch".tr();
    }
  }

  String? isValidName(String? name, String fieldName) {
    // String pattern = r'^[a-z A-Z,`~.\-]+$';
    String pattern = r'[a-z A-Z,_`-]';
    RegExp regExp = RegExp(pattern);

    if (name == null || name.isEmpty) {
      return "$fieldName ${'validate.canNotEmpty'.tr()}";
    }

    if (!regExp.hasMatch(name.trim())) {
      return "${"validate.pleaseEnter".tr()} $fieldName";
    } else {
      return null;
    }
  }

  String? isNotEmpty(String? value, String? fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName ${'validate.canNotEmpty'.tr()}";
    } else {
      return null;
    }
  }

  bool isAdult(String birthDateString) {
    String datePattern = "dd-MM-yyyy";

    DateTime birthDate = DateFormat(datePattern).parse(birthDateString);
    DateTime today = DateTime.now();

    int yearDiff = today.year - birthDate.year;
    int monthDiff = today.month - birthDate.month;
    int dayDiff = today.day - birthDate.day;

    return yearDiff > 18 || yearDiff == 18 && monthDiff >= 0 && dayDiff >= 0;
  }

  /* PAYMENT VALIDATION */

  String? isValidCardNumber(String? CardNumber, String? fieldName) {
    if (CardNumber == null || CardNumber.isEmpty) {
      return "$fieldName validate.canNotEmpty".tr();
    }

    final isValid = RegExp(
            r"^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$")
        .hasMatch(CardNumber.trim());

    if (isValid) {
      return null;
    } else {
      return "${"validate.entered".tr()} $fieldName ${"validate.isNotValid".tr()}";
    }
  }

  String? isValidCVV(String? cvv, String? fieldName) {
    if (cvv == null || cvv.isEmpty) {
      return "$fieldName validate.canNotEmpty".tr();
    } else if (cvv.length < cvvMinLength || cvv.length > cvvMaxLength) {
      return "$fieldName ${"validate.shouldBeAtLeast".tr()} $cvvMinLength ${"validate.or".tr()} $cvvMaxLength ${"validate.passwordShouldBe1".tr()}";
    } else {
      return null;
    }
  }
}

String? Function(String? value) createEmptyValidator(String fieldName) {
  return (String? value) {
    if (value?.isEmpty == true) {
      return "$fieldName validate.canNotEmpty".tr();
    } else {
      return null;
    }
  };
}
