
 mixin CommonValidations {
  static const int passwordMinLength = 8;
  static const int cvvMinLength = 3;
  static const int cvvMaxLength = 4;

  String? isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < passwordMinLength) {
      return "Password should be at least $passwordMinLength characters long";
    } else {
      return null;
    }
  }
  String? isValidConfirmPassword(String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "Confirm Password cannot be empty";
    } else if (confirmPassword.length < passwordMinLength) {
      return "Confirm Password should be at least $passwordMinLength characters long";
    } else {
      return null;
    }
  }

  String? isValidOldPassword(String? password,String? oldPassword) {
    if (password == null || password.isEmpty) {
      return "Old Password cannot be empty";
    } else if (password.length < passwordMinLength) {
      return "Old Password should be at least $passwordMinLength characters long";
    } else if (oldPassword!.trim()==password.trim()) {
      return "New password can not be same as any old Password";
    }else {
      return null;
    }
  }

  String? isValidNewPassword(String? password,String? newPassword) {
    if (password == null || password.isEmpty) {
      return "New Password cannot be empty";
    } else if (password.length < passwordMinLength) {
      return "New Password should be at least $passwordMinLength characters long";
    } else if (newPassword!.trim()==password.trim()) {
      return "New password can not be same as any old Password";
    }else {
      return null;
    }
  }
  String? isValidConfirmPasswords(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return "Confirm Password cannot be empty";
    } else if (confirmPassword.length < passwordMinLength) {
      return "Confirm Password should be at least $passwordMinLength characters long";
    } else if (password != confirmPassword) {
      return "Password did not match";
    } else {
      return null;
    }
  }
  String? isValidReTypeNewPassword(String? password,String? reTypeNewPassword) {
    if (password == null || password.isEmpty) {
      return "Confirm password cannot be empty";
    } else if (password.length < passwordMinLength) {
      return "Confirm password  should be at least $passwordMinLength characters long";
    } else if (reTypeNewPassword!.trim()==password.trim()) {
      return "Confirm password can not be same as any old Password";
    }else {
      return null;
    }

  }
  String? isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return "Email Address cannot be empty";
    }

    final isValid = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    ).hasMatch(email.trim());

    if (isValid) {
      return null;
    } else {
      return "Entered Email is not valid";
    }
  }

  String? isValidPhoneNumber(String? phone) {
    phone = phone?.trim();
    final specialCharacterRegex = RegExp(r'[!@#$%&*()_=|<>?{}~]');
    final phoneUnformatted = phone!.replaceAll(RegExp("[()-]"), "");

    if (phone == null || phone.isEmpty) {
      return "Phone Number cannot be empty";
    } /*else if (specialCharacterRegex.hasMatch(phone)) {
      return "Phone Number should not contain any special characters";
    }*/ else {
      final phoneUnformatted = phone.replaceAll(RegExp("[()-]"), "");
      if (phoneUnformatted.length > 15) {
        return "Phone cannot contain more than 15 characters";
      } else if (phoneUnformatted.length < 11) {
        return "Phone cannot contain less than 8 characters";
      } else {
        return null;
      }
    }
  }
  String? isReTypePasswordValidation(String? password, String? Confirm_Password) {
    if (Confirm_Password == null || Confirm_Password.isEmpty) {
      return "Re-type New Password cannot be empty";
    }
    if (Confirm_Password.trim() == password?.trim()) {
      return null;
    } else  {
      return "Passwords did not match";
    }
  }
  String? isConfirmPasswordValid(String? password, String? Confirm_Password) {
    if (Confirm_Password == null || Confirm_Password.isEmpty) {
      return "Confirm Password cannot be empty";
    }
    if (Confirm_Password.trim() == password?.trim()) {
      return null;
    } else  {
      return "Passwords did not match";
    }
  }
  String? isValidName(String? name, String fieldName) {
    String pattern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = RegExp(pattern);

    if (name == null || name.isEmpty) {
      return "$fieldName cannot be empty";
    }

    if (!regExp.hasMatch(name.trim())) {
      return "Please enter a valid $fieldName";
    } else {
      return null;
    }
  }
  String? isValidNames(String? name, String fieldNames) {
    String pattern = r'^[a-z A-Z,.\-]+$';
    RegExp regExp = RegExp(pattern);

    if (name == null || name.isEmpty) {
      return "$fieldNames cannot be empty";
    }

    if (!regExp.hasMatch(name.trim())) {
      return "Please enter a valid $fieldNames";
    } else {
      return null;
    }
  }
  String? isNotEmpty(String? value, String? fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName cannot be empty";
    } else {
      return null;
    }
  }

    /* PAYMENT VALIDATION */

  String? isValidCardNumber(String? CardNumber, String? fieldName) {
    if (CardNumber == null || CardNumber.isEmpty) {
      return "$fieldName cannot be empty";
    }

    final isValid = RegExp(
        r"^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$"
    ).hasMatch(CardNumber.trim());

    if (isValid) {
      return null;
    } else {
      return "Entered $fieldName is not valid";
    }
  }
  String? isValidCVV(String? cvv, String? fieldName) {
    if (cvv == null || cvv.isEmpty) {
      return "$fieldName cannot be empty";
    } else if (cvv.length < cvvMinLength || cvv.length>cvvMaxLength) {
      return "$fieldName should be at least $cvvMinLength Or $cvvMaxLength characters long ";
    } else {
      return null;
    }
  }
 }

 String? Function(String? value) createEmptyValidator(String fieldName) {
  return (String? value) {
    if (value?.isEmpty == true) {
      return "$fieldName cannot be empty";
    } else {
      return null;
    }
  };
}
