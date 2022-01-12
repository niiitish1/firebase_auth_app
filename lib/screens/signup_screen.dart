// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:my_shop/widgets/same_widget.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:geolocator/geolocator.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  Position? _currentPosition;
  String? _currentAddress;

  final formKey = GlobalKey<FormState>();
  TextEditingController _controllerAdd = TextEditingController();
  File? selectImage;
  Map<String, String> listofDetails = {
    "firstName": '',
    "lastName": '',
    "mobileNo": '',
    "emailID": '',
    "address": '',
    "imgUrl": '',
  };

  Future<Position> _getPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location not available");
      }
    } else {
      print('location not available');
    }
    return await Geolocator.getCurrentPosition();
  }

  bool isUploading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildMytext(
                          text: singupText,
                          textAlign: TextAlign.start,
                          textSize: 34,
                          fontWeight: FontWeight.w500),
                      StatefulBuilder(builder: (_, reCreate) {
                        return InkWell(
                          onTap: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );
                            if (result != null) {
                              selectImage =
                                  File(result.files.single.path.toString());
                              reCreate(() {});
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Please Select Image')));
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              color: Colors.grey[350],
                              width: 80,
                              height: 80,
                              child: selectImage != null
                                  ? Image.file(
                                      selectImage!,
                                      fit: BoxFit.fill,
                                    )
                                  : Icon(Icons.photo_camera_back_sharp),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                createForm(),
                ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        isUploading = true;
                      });
                      if (formKey.currentState!.validate() &&
                          selectImage != null) {
                        bool a = await uploadImage();
                        if (a) {
                          await addUser();
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('User Added')));
                          Navigator.of(context).pop();
                        }
                      }
                      setState(() {
                        isUploading = false;
                      });
                    },
                    child: const Text(singupText)),
                if (isUploading) ...[
                  CircularProgressIndicator(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form createForm() {
    return Form(
      key: formKey,
      child: Column(
        children: List.generate(listofDetails.length - 1, (index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: index == 4 ? _controllerAdd : null,
              textInputAction:
                  index == 4 ? TextInputAction.done : TextInputAction.next,
              keyboardType:
                  index == 2 ? TextInputType.number : TextInputType.text,
              onChanged: (value) {
                listofDetails[listofDetails.keys.elementAt(index)] = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return thisField;
                } else if (index == 2 && value.length != 10) {
                  return 'enter 10 number';
                }
              },
              decoration: InputDecoration(
                  suffixIcon: index == 4
                      ? InkWell(
                          onTap: () async {
                            if (MediaQuery.of(context).viewInsets.bottom != 0) {
                              FocusScope.of(context).unfocus();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('getting address')));
                            _currentPosition = await _getPosition();
                            _getAddress(_currentPosition!.longitude,
                                _currentPosition!.latitude);
                          },
                          child: Icon(Icons.location_pin),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                  hintText: listofDetails.keys.elementAt(index)),
            ),
          );
        }),
      ),
    );
  }

  void _getAddress(longitude, latitude) async {
    try {
      List<Placemark> placemark = await GeocodingPlatform.instance
          .placemarkFromCoordinates(latitude, longitude);
      Placemark place = placemark[0];
      _currentAddress =
          '${place.locality},${place.subLocality},${place.street},${place.postalCode},${place.country}';
      setState(() {
        _controllerAdd.text = _currentAddress.toString();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<bool> uploadImage() async {
    try {
      final fileName = selectImage!.path.split("/").last;
      final ref =
          firebase_storage.FirebaseStorage.instance.ref('usersPhoto/$fileName');
      // final ref = FirebaseStorage.instance.ref('usersPhoto/');
      firebase_storage.UploadTask uploadTask = ref.putFile(selectImage!);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      listofDetails["imgUrl"] = urlDownload;
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    }
  }

  Future<bool> addUser() async {
    listofDetails['address'] = _controllerAdd.text;
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref(userDetails)
          .child(listofDetails.values.elementAt(2));
      await ref.set(listofDetails);
      return true;
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controllerAdd.dispose();
  }
}
