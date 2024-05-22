// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:therapy_kart/models/product_detail.dart';

class CheckoutScreen extends StatefulWidget {
  // final ProductDetails productDetails;
  // final String userEmail;

  const CheckoutScreen({
    Key? key,
  }) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String mobileNumber = ''; // Store user's mobile number

  @override
  void initState() {
    super.initState();
    // Fetch user mobile number
    fetchUserMobileNumber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add your logic here for handling the checkout process
          },
          child: const Text("Proceed to Checkout"),
        ),
      ),
    );
  }

  void fetchUserMobileNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid ?? '';
      final docSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data() as Map<String, dynamic>;
        final userMobileNumber = userData['contact'] as String;

        setState(() {
          // Set the user's mobile number
          mobileNumber = userMobileNumber;
        });
      } else {
        print('User address not found in Firestore.');
      }
    } catch (e) {
      print('Error fetching user address: $e');
    }
  }
}
