// ignore_for_file: unused_import, no_leading_underscores_for_local_identifiers, avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapy_kart/models/product_detail.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/screens/cart_checkout.dart';
import 'package:therapy_kart/utils/bottom_nav_bar.dart';

class CartItem {
  final String id;
  final String title;
  final String description;
  final double price;
  int quantity;
  final String image;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.quantity,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'quantity': quantity,
      'image': image,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      title: map['title'],
      price: map['price'],
      quantity: map['quantity'],
      description: map['description'],
      image: map['image'],
    );
  }

  static String encode(List<CartItem> cartItems) {
    final List<Map<String, dynamic>> cartList =
        cartItems.map((item) => item.toMap()).toList();
    return jsonEncode(cartList);
  }

  static List<CartItem> decode(String cartData) {
    final List<dynamic> cartList = jsonDecode(cartData);
    return cartList.map((item) => CartItem.fromMap(item)).toList();
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController numberTextEditingController =
      TextEditingController();
  User? user;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<ApplicationState>(context);
    // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // final FirebaseAuth _auth = FirebaseAuth.instance;

    return StreamBuilder<List<CartItem>>(
      stream: cartProvider.cartStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Your cart")),
            body: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Your Cart")),
            body: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Icon(
                        Icons.add_shopping_cart_outlined,
                        size: 250,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Your cart is empty",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        } else {
          final cartItems = snapshot.data;
          double totalPrice = 0.0;
          cartItems?.forEach((item) {
            totalPrice += item.price * item.quantity;
          });

          return Scaffold(
            appBar: AppBar(
              title: const Text('Your Cart'),
            ),
            body: Column(
              children: [
                Expanded(
                  key: UniqueKey(),
                  child: ListView.builder(
                    itemCount: cartItems?.length,
                    itemBuilder: (context, index) {
                      final cartItem = cartItems![index];
                      bool isUpdating = false;

                      return GestureDetector(
                        onTap: () {
                          _navigateToProductDetail(context, cartItem);
                        },
                        child: Center(
                          child: Stack(
                            children: [
                              Card(
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width * 0.9,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Image.network(
                                        cartItem.image,
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover,
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cartItem.title,
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '₹${cartItem.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 16.0,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Quantity: ',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                DropdownButton<int>(
                                                  value: cartItem.quantity,
                                                  onChanged: (newQuantity) {
                                                    isUpdating = true;
                                                    cartProvider
                                                        .updateCartItemQuantity(
                                                      cartItem.id,
                                                      newQuantity!,
                                                    );

                                                    Future.delayed(
                                                      const Duration(
                                                        milliseconds: 500,
                                                      ),
                                                      () {
                                                        isUpdating = false;
                                                      },
                                                    );
                                                  },
                                                  items:
                                                      List.generate(5, (index) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: index + 1,
                                                      child: Text((index + 1)
                                                          .toString()),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          CupertinoIcons.trash_fill,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text('Remove Item'),
                                                content: const Text(
                                                    'Do you want to remove this item from your cart?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      // Remove the item from the cart
                                                      cartProvider
                                                          .removeFromCart(
                                                              cartItem.id);

                                                      Navigator.of(context)
                                                          .pop(); // Close the dialog
                                                    },
                                                    child: const Text('Remove'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isUpdating)
                                Positioned.fill(
                                  child: Scaffold(
                                    body: Container(
                                      color: Colors.black.withOpacity(0.3),
                                      child: const Scaffold(
                                        body: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                priceFooter(totalPrice),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartCheckoutScreen(
                            productPrice: totalPrice,
                          ),
                        ),
                      );
                    },
                    child: Container(
                        height: 50,
                        width: 190,
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(20),
                          // border: Border.all(color: Colors.black)
                        ),
                        //color: Colors.red,
                        child: const Center(
                            child: Text(
                          "Proceed to Payment",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ))),
                  ),
                ),
                const SizedBox(height: 19),
              ],
            ),
          );
        }
      },
    );
  }

  void _navigateToProductDetail(BuildContext context, CartItem cartItem) {
    final productDetails = ProductDetails(
      id: cartItem.id,
      image: cartItem.image,
      title: cartItem.title,
      price: cartItem.price,
      description: cartItem.description,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          productDetails: productDetails,
        ),
      ),
    );
  }

  Widget priceFooter(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "Total:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '₹${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Text(
                "Shipping:",
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '₹0.00',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
