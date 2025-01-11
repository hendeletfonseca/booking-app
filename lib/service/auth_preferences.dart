import 'package:booking_app/database/db.dart';
import 'package:booking_app/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {

  static Future<void> saveInformation(String name, String email, String password) async {
    BookingAppDB db = BookingAppDB.instance;
    UserSchema newUser = await db.insertUser(UserSchema(username: name, email: email, password: password));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('User ID: ${newUser.id}');
    await prefs.setInt('_userID', newUser.id!);
  }

  static Future<UserSchema?> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userID = prefs.getInt('_userID');
    if (userID == null) {
      return null;
    }
    BookingAppDB db = BookingAppDB.instance;
    UserSchema user = await db.getUser(userID);
    return user;
  }

  static Future<bool> isAuthenticated() async {
    int? id = await SharedPreferences.getInstance().then((prefs) => prefs.getInt('_userID'));
    return id != null;
  }

  static Future<void> removeAuthenticationInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('_userID');
  }
}