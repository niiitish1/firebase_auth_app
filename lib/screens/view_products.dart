import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_shop/const/my_string.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';

class ViewProduct extends StatefulWidget {
  const ViewProduct({Key? key}) : super(key: key);

  @override
  _ViewProductState createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  late Razorpay _razorpay;
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentScussess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentFailed);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  void handlePaymentScussess() {
    _razorpay.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Scuccess')));
  }

  void handlePaymentFailed() {
    _razorpay.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Failed')));
  }

  void handleExternalWallet() {
    _razorpay.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('handle wallet')));
  }

  void handlePaymentCancelled() {
    _razorpay.clear();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('payment cancelled')));
  }

  void openCheckOut() async {
    var options = {
      'key': 'rzp_test_F9xb9Z1B9MdiXG',
      'amount': num.parse(_controller.text) * 100,
      'name': 'Nitish Gupta',
      'currency': 'INR',
      'description': 'Payment for random products',
      'prefill': {'contact': '8879753332', 'email': 'nitishg887975@gmail.com'},
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      print(e.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productList[whichIndex].productName.toString()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () async {
                final urlImage = productList[whichIndex].productImg.toString();
                final url = Uri.parse(urlImage);
                final response = await http.get(url);
                final bytes = response.bodyBytes;

                final temp = await getTemporaryDirectory();
                final path = '${temp.path}/share.png';
                File(path).writeAsBytes(bytes);

                await Share.shareFiles(
                  [path],
                  text: productList[whichIndex].productDesc,
                );
              },
              child: const Icon(Icons.share),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: double.infinity,
                height: 400,
                child: Image(
                    fit: BoxFit.contain,
                    image: Image.network(
                            productList[whichIndex].productImg.toString())
                        .image)),
            Text(
              'Price: ${productList[whichIndex].productPrice}',
              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700),
            ),
            Text(
              'Description: ${productList[whichIndex].productDesc}',
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: _controller,
              decoration: const InputDecoration(
                  hintText: 'enter amount', border: OutlineInputBorder()),
            ),
            ElevatedButton(
                onPressed: () {
                  openCheckOut();
                },
                child: const Text('Pay with razorpay')),
          ],
        ),
      ),
    );
  }
}
