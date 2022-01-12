import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:my_shop/models/product_details.dart';
import 'package:my_shop/screens/profile_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:my_shop/screens/view_products.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    _usersStream =
        FirebaseFirestore.instance.collection(fireStoreRef).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    productList.clear();
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder: (_, snapShot) {
            if (snapShot.hasError) {
              return const Center(child: Text('Something went wrong'));
            } else if (snapShot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              for (var item in snapShot.data!.docs) {
                Map<String, dynamic> productsData =
                    item.data()! as Map<String, dynamic>;
                productList.add(ProductDetails.fromJson(productsData));
              }
              return ListView.builder(
                itemCount: productList.length,
                itemBuilder: (_, index) {
                  return GestureDetector(
                      onTap: () {
                        whichIndex = index;
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => ViewProduct()));
                      },
                      child: buildProductsUI(index));
                },
              );
              // snapShot.data!.docs.map((myDocument) {
              //   Map<String, dynamic> productsData = myDocument.data()! as Map<String, dynamic>;
              //   productList.add(ProductDetails.fromJson(productsData));
              // });
              // return ListView.builder(
              //   itemCount: productList.length,
              //   itemBuilder: (_, index) {
              //     return Text(productList[index].productName.toString());
              //   },
              // );
              // return ListView(
              //   children: snapShot.data!.docs.map((document) {
              //     Map<String, dynamic> productsData =
              //         document.data()! as Map<String, dynamic>;
              //     productList.add(ProductDetails.fromJson(productsData));
              //     return ListTile(
              //       title: Text(productsData['product_name'].toString()),
              //       subtitle: Text(productsData['product_desc'].toString()),
              //     );
              //   }).toList(),
              // );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final _auth = FirebaseAuth.instance;
          final value = await SharedPreferences.getInstance();
          value.remove('a');
          value.remove('userData');
          value.clear();
          await _auth.signOut();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => SplashScreen()));
        },
        child: const Icon(Icons.logout),
      ),
    );
  }

  buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text('List of Products'),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: Image.network(userData!.imgUrl.toString()).image,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductsUI(int index) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Image(
                image: Image.network(productList[index].productImg.toString())
                    .image),
          ),
          Column(
            children: [
              Text(
                productList[index].productName.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              Text(
                '${productList[index].productPrice.toString()} RS',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                productList[index].productDesc.toString(),
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
