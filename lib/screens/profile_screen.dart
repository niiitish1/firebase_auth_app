import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:my_shop/screens/add_products_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 25),
            CircleAvatar(
              radius: 70,
              backgroundImage: Image.network(userData!.imgUrl.toString()).image,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('First Name : ${userData!.firstName}',
                  style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Lase Name : ${userData!.lastName}',
                  style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Email : ${userData!.emailId}',
                  style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Mobile No : ${userData!.mobileNo}',
                  style: TextStyle(fontSize: 24)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Address : ${userData!.address}',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => AddProducts()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
