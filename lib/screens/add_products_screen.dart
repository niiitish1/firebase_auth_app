import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddProducts extends StatefulWidget {
  const AddProducts({Key? key}) : super(key: key);

  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final formKey = GlobalKey<FormState>();
  TextEditingController _name = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _desc = TextEditingController();

  File? file;
  bool isLoading = false;
  String imgDownloadUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: Form(
        key: formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return thisField;
                  } else {
                    return null;
                  }
                },
                controller: _name,
                decoration: const InputDecoration(
                    hintText: 'Name', border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return thisField;
                  } else {
                    return null;
                  }
                },
                controller: _desc,
                decoration: const InputDecoration(
                    hintText: 'Description', border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextFormField(
                validator: (value) {
                  if (value!.isEmpty) {
                    return thisField;
                  } else {
                    return null;
                  }
                },
                controller: _price,
                decoration: const InputDecoration(
                    hintText: 'Price', border: OutlineInputBorder()),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: RichText(
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          style: const TextStyle(color: Colors.black),
                          text: file == null
                              ? 'select an image file'
                              : file!.path.split("/").last),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false,
                          type: FileType.image,
                        );
                        if (result != null) {
                          file = File(result.files.single.path.toString());
                          setState(() {
                            print(file!.path);
                          });
                        }
                      },
                      child: Text(file == null ? 'Upload' : 'done'))
                ],
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  if (file != null) {
                    setState(() {
                      isLoading = true;
                    });
                    addDatainFireStore();
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select image')));
                  }
                },
                child: const Text('Submit')),
            if (isLoading) ...[CircularProgressIndicator()]
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _price.dispose();
    _desc.dispose();
  }

  addDatainFireStore() async {
    bool a = await uploadImage();
    if (a) {
      Map<String, dynamic> data = {
        "product_name": _name.text,
        "product_desc": _desc.text,
        "product_price": _price.text,
        "product_img": imgDownloadUrl,
      };
      await FirebaseFirestore.instance
          .collection(fireStoreRef)
          .doc(_name.text)
          .set(data)
          .then((value) {})
          .catchError((onError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(onError)));
        setState(() {
          isLoading = false;
        });
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Product Addeded')));
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('error')));
    }
  }

  Future<bool> uploadImage() async {
    try {
      final fileName = file!.path.split("/").last;
      final ref = firebase_storage.FirebaseStorage.instance
          .ref('productImage/$fileName');
      // final ref = FirebaseStorage.instance.ref('usersPhoto/');
      firebase_storage.UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      imgDownloadUrl = urlDownload;
      print(imgDownloadUrl);
      return true;
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
      return false;
    }
  }
}
