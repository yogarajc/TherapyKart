import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:therapy_kart/models/product_detail.dart';

class SubSubCollectionScreen extends StatelessWidget {
  final CollectionReference collectionReference;

  const SubSubCollectionScreen({Key? key, required this.collectionReference})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(collectionReference.id),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionReference.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final productDocs = snapshot.data!.docs;

          return Column(
            children: productDocs.map((productDoc) {
              final productName = productDoc['title'];
              final productPrice = productDoc['price'];
              final productDescription = productDoc['description'];
              final productId = productDoc['productId'];
              final productImage = productDoc['image'];

              return GestureDetector(
                onTap: () {
                  final productDetails = ProductDetails(
                    id: productId,
                    title: productName,
                    price: productPrice.toDouble(),
                    description: productDescription,
                    image: productImage,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(
                        productDetails: productDetails,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Card(
                        shadowColor: Colors.grey,
                        elevation: 5,
                        color: Colors.white,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: 0.9 * MediaQuery.of(context).size.width,
                          height: 150,
                          child: Row(
                            children: [
                              Container(
                                height: 130,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0)),
                                width: 0.30 * MediaQuery.of(context).size.width,
                                child: Image.network(
                                  productImage, // Use your product image URL here
                                  fit: BoxFit
                                      .contain, // Make the image cover the container
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    productName,
                                    style: const TextStyle(
                                      fontSize: 18, // Adjust font size
                                      fontWeight:
                                          FontWeight.bold, // Adjust font weight
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Price: \$${productPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors
                                          .green, // Change price color to green
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
