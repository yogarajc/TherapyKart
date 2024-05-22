// ignore_for_file: unused_import, library_private_types_in_public_api, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/screens/checkout.dart';
import 'package:therapy_kart/screens/cart_screen.dart';

class ProductDetails {
  final String id; // Unique product ID
  final String title;
  final double price;
  final String description;
  final String image;

  ProductDetails({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
  });
}

class ProductDetailPage extends StatefulWidget {
  final ProductDetails productDetails;

  const ProductDetailPage({Key? key, required this.productDetails})
      : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _razorpay = Razorpay();
  late String buttonText;

  @override
  void initState() {
    super.initState();
    checkIfProductInCart();
    // _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    // _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void checkIfProductInCart() async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    final isInCart = appState.isProductInCart(widget.productDetails.id);

    setState(() {
      buttonText = isInCart ? 'Go to Cart' : 'Add to Cart';
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ApplicationState>(context);
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productDetails.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.network(
                      widget.productDetails.image), // Display the image
                  Text("Name: ${widget.productDetails.title}"),
                  Text(
                    'Price: \$${widget.productDetails.price.toStringAsFixed(2)}',
                  ),
                  Text('Description: ${widget.productDetails.description}'),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (buttonText == 'Go to Cart') {
                        // If the product is in the cart, navigate to the cart screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CartScreen(),
                          ),
                        );
                      } else {
                        // If the product is not in the cart, add it to the cart
                        appState.addToCart(widget.productDetails, context);
                        checkIfProductInCart(); // Update the button state
                      }
                    },
                    child: Container(
                      height: 45,
                      width: width * 0.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orange,
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Calculate the single product price
                      double singleProductPrice = widget.productDetails.price;

                      // Navigate to AddressStore page with the product price and product details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            productPrice: singleProductPrice,
                            productDetails: widget.productDetails,
                            productId: widget
                                .productDetails.id, // Pass the product details
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 45,
                      width: width * 0.43,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.orangeAccent,
                      ),
                      child: Center(
                        child: const Text(
                          'Buy Now',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
