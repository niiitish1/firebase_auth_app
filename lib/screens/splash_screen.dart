import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:my_shop/models/user_details.dart';
import 'package:my_shop/screens/home_screen.dart';
import 'package:my_shop/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  checkUserExit() async {
    final pref = await SharedPreferences.getInstance();
    bool? a = pref.getBool("a");
    if (a != null && a) {
      String? b = pref.getString('userData');
      if (b != null) {
        userData = UserDetails.fromJson(jsonDecode(b));
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    } else {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserExit();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
