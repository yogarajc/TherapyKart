// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:therapy_kart/models/product_detail.dart';
import 'package:therapy_kart/utils/bottom_nav_bar.dart';

class CheckoutScreen extends StatefulWidget {
  final double productPrice;
  final String productId;
  final ProductDetails productDetails;

  const CheckoutScreen(
      {Key? key,
      required this.productPrice,
      required this.productDetails,
      required this.productId})
      : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  bool isPaymentInProgress = false;

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController streetTextEditingController = TextEditingController();
  TextEditingController houseNumberTextEditingController =
      TextEditingController();
  TextEditingController addressTextEditingController = TextEditingController();
  TextEditingController landmarkTextEditingController = TextEditingController();
  TextEditingController pincodeTextEditingController = TextEditingController();
  TextEditingController numberTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the user's address data if it exists
    _fetchUserAddressData();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  Future<void> _fetchUserAddressData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Fetch the user's address data from Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection("addresses").doc(user.email).get();

        if (snapshot.exists) {
          // Address data exists, display it in the input fields
          setState(() {
            nameTextEditingController.text = snapshot.data()!["name"] ?? "";
            numberTextEditingController.text =
                snapshot.data()!["contactNumber"] ?? "";
            houseNumberTextEditingController.text =
                snapshot.data()!["houseNumber"] ?? "";
            streetTextEditingController.text =
                snapshot.data()!["streetName"] ?? "";
            addressTextEditingController.text =
                snapshot.data()!["address"] ?? "";
            landmarkTextEditingController.text =
                snapshot.data()!["landmark"] ?? "";
            pincodeTextEditingController.text =
                snapshot.data()!["pincode"] ?? "";
          });
        }
      } catch (e) {
        print("Error fetching user address data: $e");
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    print("Payment ID: ${response.paymentId}");
    print("Order ID: ${response.orderId}");
    print("Signature: ${response.signature}");

    // You can navigate to a success screen or perform any other necessary action here.

    // Store the order details in Firestore
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BottomNavBar()),
    );
    //_storeOrderDetails(response.paymentId, response.orderId);
    _storeOrderDetails(response.paymentId ?? '', response.orderId ?? '');

    // Set the payment in progress flag to false
    setState(() {
      isPaymentInProgress = false;
    });

    // Navigate to the HomeScreen after successful payment
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print("Error: ${response.code} - ${response.message}");

    // You can display an error message to the user or perform any other necessary action here.

    // Set the payment in progress flag to false
    setState(() {
      isPaymentInProgress = false;
    });
  }

  bool _validateFields() {
    if (nameTextEditingController.text.isEmpty ||
        numberTextEditingController.text.isEmpty ||
        houseNumberTextEditingController.text.isEmpty ||
        streetTextEditingController.text.isEmpty ||
        addressTextEditingController.text.isEmpty ||
        landmarkTextEditingController.text.isEmpty ||
        pincodeTextEditingController.text.isEmpty) {
      // Show an error message for empty fields
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
        ),
      );
      return false;
    }

    // Validate the mobile number length (must be exactly 10 digits)
    if (numberTextEditingController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mobile number must be exactly 10 digits."),
        ),
      );
      return false;
    }

    return true;
  }

  void _storeUserData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        // User is signed in, use their email as the document ID
        final userEmail = user.email;

        // Create a map with the user's data
        Map<String, dynamic> userData = {
          'name': nameTextEditingController.text,
          'contactNumber': numberTextEditingController.text,
          'houseNumber': houseNumberTextEditingController.text,
          'streetName': streetTextEditingController.text,
          'address': addressTextEditingController.text,
          'landmark': landmarkTextEditingController.text,
          'pincode': pincodeTextEditingController.text,
        };

        // Store the user's data in Firestore
        await _firestore.collection("addresses").doc(userEmail).set(userData);

        print('User data stored successfully');
      }
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  void _storeOrderDetails(String paymentId, String orderId) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Use the product details passed from ProductDetailPage
        ProductDetails productDetails = widget.productDetails;

        // Define the default quantity
        int quantity = 1;

        // Now, you can store the order details with the product details and quantity
        Map<String, dynamic> orderData = {
          'productTitle': productDetails.title,
          'productImage': productDetails.image,
          'productPrice': productDetails.price,
          'productDescription': productDetails.description,
          'quantity': quantity, // Add the quantity field with a default value
          'paymentId': paymentId,
          'timestamp': FieldValue.serverTimestamp(),
          'status':
              'Successfully paid', // You can set this to 'pending' initially
        };

        // Get a reference to the "user_orders" subcollection
        CollectionReference userOrdersCollection = _firestore
            .collection("orders")
            .doc(user.email)
            .collection("user_orders");

        // Add a new document with an automatically generated ID to the "user_orders" subcollection
        await userOrdersCollection.add(orderData);

        print('Order details stored successfully');
      } catch (e) {
        print('Error storing order details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Address Store"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameTextEditingController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: numberTextEditingController,
              decoration: const InputDecoration(labelText: "Contact Number"),
            ),
            TextField(
              controller: houseNumberTextEditingController,
              decoration: const InputDecoration(labelText: "House Number"),
            ),
            TextField(
              controller: streetTextEditingController,
              decoration: const InputDecoration(labelText: "Street Name"),
            ),
            TextField(
              controller: addressTextEditingController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextField(
              controller: landmarkTextEditingController,
              decoration: const InputDecoration(labelText: "Landmark"),
            ),
            TextField(
              controller: pincodeTextEditingController,
              decoration: const InputDecoration(labelText: "Pincode"),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Validate the fields before proceeding
                if (_validateFields()) {
                  // Store the user's data in Firestore
                  _storeUserData();

                  // Proceed to make the payment
                  _initiatePayment();
                }
              },
              child: const Text("Proceed to Payment"),
            ),
          ],
        ),
      ),
    );
  }

  void _initiatePayment() {
    // Validate the fields
    if (_validateFields()) {
      // Set the payment in progress flag to true
      setState(() {
        isPaymentInProgress = true;
      });

      final options = {
        'key': 'rzp_test_OczHmSWtH1Ojre', // Replace with your Razorpay key
        'amount': (widget.productPrice * 100).toInt(),
        'name': 'Therapy Kart',
        'description': 'Payment for your order',
        'prefill': {
          'contact': numberTextEditingController.text,
          'email': _auth.currentUser?.email ?? "",
        },
        'external': {
          'wallets': [],
        },
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        print("Error initializing Razorpay: $e");

        // Set the payment in progress flag to false
        setState(() {
          isPaymentInProgress = false;
        });
      }
    }
  }
}
