import 'package:admin/database/db.dart';
import 'package:admin/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static Future<void> saveInformation(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('_userID', id);
  }

  static Future<UserSchema?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('_userID');
    if (userID == null) {
      return null;
    }
    BookingAppDB db = BookingAppDB.instance;
    UserSchema? user = await db.getUser(userID);
    return user;
  }

  static Future<bool> isAuthenticated() async {
    int? id = await SharedPreferences.getInstance()
        .then((prefs) => prefs.getInt('_userID'));
    return id != null;
  }

  static Future<void> removeAuthenticationInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('_userID');
  }
}
