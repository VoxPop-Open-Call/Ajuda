import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String _userIDPrefKey = 'user_id_pref_key';
  static const String _emailIDPrefKey = 'Email_id_pref_key';
  static const String _accessTokenPrefKey = 'auth_token_pref_key';
  static const String _fcmTokenPrefKey = 'fcm_token_pref_key';
  static const String _refreshTokenPrefKey = 'refresh_token_pref_key';
  static const String _userTypePrefKey = 'user_type_pref_key';
  static const String _onBoardingPrefKey = 'onBoardingSeen';
  static const String _stayLoggedInPrefKey = 'stay_logged_in_key';
  static const String _otpPrefKey = 'otp_key';
  static const String _emailPrefKey = 'email_key';
  static const String _packagePrefKey = 'package_key';
  static const String _loginTypePrefKey = 'loginType_key';
  static const String _idTokenPrefKey = 'id_token_key';

  SharedPrefHelper._();

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ///loginType
  static set loginType(String value) {
    _prefs.setString(_loginTypePrefKey, value);
  }

  static String get loginType {
    return _prefs.getString(_loginTypePrefKey)!;
  }

  ///userid
  static String? get userId {
    return _prefs.getString(_userIDPrefKey);
  }

  static set userId(String? value) {
    if (value != null) {
      _prefs.setString(_userIDPrefKey, value);
    } else {
      _prefs.remove(_userIDPrefKey);
    }
  }

  ///emailId
  static int? get emailId {
    return _prefs.getInt(_emailIDPrefKey);
  }

  static set emailId(int? value) {
    if (value != null) {
      _prefs.setInt(_emailIDPrefKey, value);
    } else {
      _prefs.remove(_emailIDPrefKey);
    }
  }

  ///isLogged in
  static bool get isLoggedIn {
    return userId != null;
  }

  ///onBoardingShown
  static bool get onBoardingShown {
    return _prefs.getBool(_onBoardingPrefKey) ?? false;
  }

  static set onBoardingShown(bool value) {
    _prefs.setBool(_onBoardingPrefKey, value);
  }

  ///auth token
  static String get accessToken {
    return _prefs.getString(_accessTokenPrefKey) ?? "";
  }

  static set accessToken(String value) {
    _prefs.setString(_accessTokenPrefKey, value);
  }

  ///fcm token
  static String get fcmToken {
    return _prefs.getString(_fcmTokenPrefKey) ?? "";
  }

  static set fcmToken(String value) {
    _prefs.setString(_fcmTokenPrefKey, value);
  }

  ///refresh token
  static String get refreshToken {
    return _prefs.getString(_refreshTokenPrefKey) ?? "";
  }

  static set refreshToken(String value) {
    _prefs.setString(_refreshTokenPrefKey, value);
  }

  ///id token
  static String get idToken {
    return _prefs.getString(_idTokenPrefKey) ?? "";
  }

  static set idToken(String value) {
    _prefs.setString(_idTokenPrefKey, value);
  }

  ///user type
  static String get userType {
    return _prefs.getString(_userTypePrefKey) ?? "0";
  }

  static set userType(String value) {
    _prefs.setString(_userTypePrefKey, value);
  }

  ///stay logged in
  static bool get stayLoggedIn {
    return _prefs.getBool(_stayLoggedInPrefKey) ?? true;
  }

  static set stayLoggedIn(bool value) {
    _prefs.setBool(_stayLoggedInPrefKey, value);
  }

  ///otp
  static int? get otp {
    return _prefs.getInt(_otpPrefKey);
  }

  static set otp(int? otp) {
    if (otp != null) {
      _prefs.setInt(_otpPrefKey, otp);
    }
  }

  ///auth token
  static String get email {
    return _prefs.getString(_emailPrefKey) ?? "";
  }

  static set email(String value) {
    _prefs.setString(_emailPrefKey, value);
  }

  ///selected package id
  static int? get packageId {
    return _prefs.getInt(_packagePrefKey);
  }

  static set packageId(int? packageId) {
    if (packageId != null) {
      _prefs.setInt(_packagePrefKey, packageId);
    } else {
      _prefs.remove(_packagePrefKey);
    }
  }
}
