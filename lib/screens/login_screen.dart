// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:my_shop/models/user_details.dart';
import 'package:my_shop/screens/home_screen.dart';
import 'package:my_shop/screens/signup_screen.dart';
import 'package:my_shop/widgets/same_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isNotExit = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _phoneNo = TextEditingController();
  String verificationId = '';
  String otp = '';
  bool closeDialog = true;
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _phoneNo.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  width: double.infinity,
                  child: buildMytext(
                      text: logInText,
                      textAlign: TextAlign.start,
                      textSize: 34,
                      fontWeight: FontWeight.w500),
                ),
                TextFormField(
                    controller: _phoneNo,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        hintText: 'Phone No',
                        border: const OutlineInputBorder()),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'this field cannot be empty';
                      } else if (value.length != 10) {
                        return 'enter 10 digit mobile number';
                      } else if (isNotExit) {
                        isNotExit = false;
                        return 'this mobile number is not register';
                      } else {
                        return null;
                      }
                    }),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      if (MediaQuery.of(context).viewInsets.bottom != 0) {
                        FocusScope.of(context).unfocus();
                      }
                      if (formKey.currentState!.validate()) {
                        login();
                      } else {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    child: const Text(logInText)),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => SignUpScreen()));
                    },
                    child: const Text(singupText)),
                if (isLoading) ...[CircularProgressIndicator()]
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createBottomSheetDialog(DataSnapshot snap) {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return Container(
            child: Column(
              children: [
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    otp = value;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'enter OTP'),
                ),
                ElevatedButton(
                    onPressed: () {
                      PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: otp);
                      signinWithPhoneAuthCrendentials(
                          phoneAuthCredential, snap);
                    },
                    child: Text('verify OTP'))
              ],
            ),
          );
        }).whenComplete(() {
      closeDialog = false;
    });
  }

  login() async {
    try {
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("users/${_phoneNo.text}");
      DataSnapshot snap = await ref.get();
      if (snap.exists) {
        setState(() {
          isLoading = false;
        });
        await _auth.verifyPhoneNumber(
          phoneNumber: "+91 ${_phoneNo.text}",
          verificationCompleted: (phoneAuthCredential) {},
          verificationFailed: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message.toString())));
            print(error);
          },
          codeSent: (verificationId, forceResendingToken) {
            this.verificationId = verificationId;
            createBottomSheetDialog(snap);
          },
          codeAutoRetrievalTimeout: (verificationId) {},
        );
      } else {
        setState(() {
          isLoading = false;
        });
        isNotExit = true;
        formKey.currentState!.validate();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void signinWithPhoneAuthCrendentials(
      PhoneAuthCredential phoneAuthCredential, DataSnapshot snap) async {
    try {
      final authCrendential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (authCrendential.user != null) {
        final value = await SharedPreferences.getInstance();
        value.setBool("a", true);
        value.setString("userData", jsonEncode(snap.value));
        final data = jsonEncode(snap.value);
        userData = UserDetails.fromJson(jsonDecode(data));
        if (closeDialog) {
          Navigator.of(context).pop();
        }
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        print('authCrendential is not null');
      }
    } catch (e) {
      print(e);
    }
  }
}
