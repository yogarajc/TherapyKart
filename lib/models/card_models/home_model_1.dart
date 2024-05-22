import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:therapy_kart/models/product_detail.dart';

class HomeCard1 extends StatefulWidget {
  final int productIndex;
  const HomeCard1({Key? key, required this.productIndex}) : super(key: key);

  @override
  State<HomeCard1> createState() => _HomeCard1State();
}

class _HomeCard1State extends State<HomeCard1> {
  @override
  Widget build(BuildContext context) {
    // Use widget.productIndex to access the passed value
    var width = MediaQuery.of(context).size.width;
    final productIndex = widget.productIndex; // Access productIndex here

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(); // Loading indicator
        }

        if (productIndex < 0 || productIndex >= snapshot.data!.docs.length) {
          return const Text('Product not found');
        }

        final doc = snapshot.data!.docs[productIndex];
        final productName = doc['title'];
        final productPrice = doc['price'];
        final productImage =
            doc['image']; // Ensure it matches your Firestore field name

        return Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                _navigateToProductDetail(
                  context,
                  doc,
                );
              },
              child: Container(
                height: 200,
                width: width * 0.9,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                        productImage), // Use the correct field name
                    fit: BoxFit.cover, // You can adjust the fit as needed
                  ),
                ),
                //color: Colors.red[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 50,
                        width: width,
                        color: Colors.white.withOpacity(0.3),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                'Product name : $productName',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Price : $productPrice',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToProductDetail(BuildContext context, DocumentSnapshot? doc) {
    if (doc != null) {
      ProductDetails productDetails = ProductDetails(
        id: doc["id"],
        title: doc["title"],
        price: (doc["price"] ?? 0).toDouble(),
        description: doc["description"],
        image: doc["image"],
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ProductDetailPage(productDetails: productDetails),
        ),
      );
    }
  }
}
