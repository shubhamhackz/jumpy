import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHelper {
  static late SharedPreferences _sharedPreferences;

  static init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  SharedPreferences get sharedPrefs => _sharedPreferences;

  static setBool(String key, bool value) {
    _sharedPreferences.setBool(key, value);
  }

  static getBool(String key) => _sharedPreferences.getBool(key);

  static setInt(String key, int value) {
    _sharedPreferences.setInt(key, value);
  }

  static getInt(String key) => _sharedPreferences.getInt(key);

  static setString(String key, String value) {
    _sharedPreferences.setString(key, value);
  }

  static getString(String key) => _sharedPreferences.getString(key);

  static setDouble(String key, double value) {
    _sharedPreferences.setDouble(key, value);
  }

  static getDouble(String key) => _sharedPreferences.getDouble(key);

  static set setHighscore(int value) {
    setInt(PreferenceConstants.highScore, value);
  }

  static get getHighscore =>
      _sharedPreferences.getInt(PreferenceConstants.highScore);
}

class PreferenceConstants {
  static const highScore = "Highscore";
}
