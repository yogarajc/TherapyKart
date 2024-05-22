import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:therapy_kart/models/card_models/orders_card_models.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case when the user is not signed in
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: const Center(
          child: Text('Please sign in to view your orders.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .doc(user.email) // Set the document ID to the current user's email
            .collection('cart_orders')
            .snapshots(),
        builder: (context, cartSnapshot) {
          if (cartSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (cartSnapshot.hasError) {
            return Text('Error: ${cartSnapshot.error}');
          }

          if (!cartSnapshot.hasData || cartSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }

          final cartOrders = cartSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .doc(user.email)
                .collection('user_orders')
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Text('Error: ${userSnapshot.error}');
              }

              if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No orders found.'),
                );
              }

              final userOrders = userSnapshot.data!.docs;

              // Combine and display data from both 'cart_orders' and 'user_orders'
              final combinedOrders = <QueryDocumentSnapshot>[];
              combinedOrders.addAll(cartOrders);
              combinedOrders.addAll(userOrders);

              // Sort the combined orders by timestamp (latest first)
              combinedOrders.sort((a, b) {
                final aTimestamp = a['timestamp'] as Timestamp;
                final bTimestamp = b['timestamp'] as Timestamp;
                return bTimestamp.compareTo(aTimestamp);
              });

              return ListView.builder(
                itemCount: combinedOrders.length,
                itemBuilder: (context, index) {
                  final orderData =
                      combinedOrders[index].data() as Map<String, dynamic>;

                  if (orderData.containsKey('orderItems')) {
                    // Display 'cart_orders' using the ProductCard widget
                    final List<Map<String, dynamic>> orderItems =
                        List<Map<String, dynamic>>.from(
                            orderData['orderItems'] ?? []);

                    return Column(
                      children: orderItems.map((orderItem) {
                        return OrdersCard(
                          title: orderItem['productTitle'],
                          price: orderItem['productPrice'],
                          image: orderItem['productImage'] ??
                              'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80',
                          quantity: orderItem['quantity'],
                        );
                      }).toList(),
                    );
                  } else {
                    // Display 'user_orders' using the ProductCard widget
                    return Column(
                      children: [
                        OrdersCard(
                          title: orderData['productTitle'],
                          price: orderData['productPrice'],
                          image: orderData['productImage'] ??
                              'https://images.unsplash.com/photo-1546868871-7041f2a55e12?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80',
                          quantity: orderData['quantity'],
                        ),
                        const SizedBox(height: 10), // Add spacing between orders
                      ],
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
