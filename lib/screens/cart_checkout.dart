// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/screens/cart_screen.dart';
import 'package:therapy_kart/utils/bottom_nav_bar.dart';

class CartCheckoutScreen extends StatefulWidget {
  final double productPrice;

  const CartCheckoutScreen({
    Key? key,
    required this.productPrice,
  }) : super(key: key);

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
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
    _fetchUserAddressData();
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
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await _firestore.collection("addresses").doc(user.email).get();

        if (snapshot.exists) {
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

  List<Map<String, dynamic>> orderItems = [];

  // Function to create orderItems
  // Future<void> _createOrderItems() async {
  //   final userCart = ApplicationState().cart;
  //   orderItems = []; // Clear the orderItems list before populating it

  //   for (CartItem cartItem in userCart) {
  //     String productId = cartItem.id;

  //     ProductDetails? productDetails =
  //         await ApplicationState().getProductDetailsById(productId);

  //     if (productDetails != null) {
  //       Map<String, dynamic> orderItem = {
  //         'productId': productId,
  //         'productTitle': productDetails.title,
  //         'productPrice': productDetails.price,
  //         'productDescription': productDetails.description,
  //         'quantity': cartItem.quantity,
  //       };
  //       orderItems.add(orderItem);
  //     }
  //   }
  // }

  List<Map<String, dynamic>> _createOrderItems(List<CartItem> cartItems) {
    List<Map<String, dynamic>> orderItems = [];

    for (CartItem cartItem in cartItems) {
      Map<String, dynamic> orderItem = {
        'productId': cartItem.id,
        'productTitle': cartItem.title,
        'productPrice': cartItem.price,
        'productDescription': cartItem.description,
        'quantity': cartItem.quantity,
        'productImage': cartItem.image,
      };
      orderItems.add(orderItem);
    }

    return orderItems;
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        final applicationState =
            Provider.of<ApplicationState>(context, listen: false);

        // Create a new order document in the "cart_orders" subcollection
        DocumentReference orderDocumentRef = await _firestore
            .collection("orders")
            .doc(user.email)
            .collection("cart_orders")
            .add({
          'paymentId': response.paymentId ?? '',
          'status': 'Successfully paid',
          'timestamp': FieldValue.serverTimestamp(), // Add a timestamp
        });

        // Use _createOrderItems to create order items based on the user's cart
        List<Map<String, dynamic>> orderItems =
            _createOrderItems(applicationState.cart);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );

        // Update the 'orderItems' array in Firestore with the list of order items
        await orderDocumentRef.update({
          'orderItems': orderItems,
        });

        print('Order details with cart items stored successfully');
      } catch (e) {
        print('Error storing order details with cart items: $e');
      }
    }

    // Clear the cart after successful payment
    // applicationState.clearCart();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Error: ${response.code} - ${response.message}");
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields."),
        ),
      );
      return false;
    }

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
        final userEmail = user.email;
        Map<String, dynamic> userData = {
          'name': nameTextEditingController.text,
          'contactNumber': numberTextEditingController.text,
          'houseNumber': houseNumberTextEditingController.text,
          'streetName': streetTextEditingController.text,
          'address': addressTextEditingController.text,
          'landmark': landmarkTextEditingController.text,
          'pincode': pincodeTextEditingController.text,
        };

        await _firestore.collection("addresses").doc(userEmail).set(userData);

        print('User data stored successfully');
      }
    } catch (e) {
      print('Error storing user data: $e');
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
                if (_validateFields()) {
                  _storeUserData();
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
    if (_validateFields()) {
      setState(() {
        isPaymentInProgress = true;
      });

      final options = {
        'key': 'rzp_test_OczHmSWtH1Ojre',
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
        setState(() {
          isPaymentInProgress = false;
        });
      }
    }
  }
}
