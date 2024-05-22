import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:therapy_kart/models/card_models/home_model_1.dart';
import 'package:therapy_kart/models/card_models/home_model_2.dart';
import 'package:therapy_kart/models/product_detail.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String name = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  name = value.trim(); // Update the search query
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search by product name...',
              ),
            ),
          ),
          // Display matching products only when there's a search query
          if (name.isNotEmpty)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  List<QueryDocumentSnapshot> matchingProducts = snapshot
                      .data!.docs
                      .where((product) => product['title']
                          .toString()
                          .toLowerCase()
                          .contains(name.toLowerCase()))
                      .toList();

                  if (matchingProducts.isEmpty) {
                    return const Center(
                      child: Text('No results found'),
                    );
                  }

                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var data = matchingProducts[index].data()
                          as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          double price = data['price'].toDouble();
                          // Navigate to the product details page and pass the product information
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                productDetails: ProductDetails(
                                  id: data["id"],
                                  image: data["image"],
                                  title: data['title'],
                                  price: price,
                                  description: data['description'],
                                ),
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(data['title']),
                          leading: Image.network(data['image']),
                          subtitle: Text(data['price'].toString()),
                        ),
                      );
                    },
                    itemCount: matchingProducts.length,
                  );
                },
              ),
            ),
          // Only show these containers when there's no search query
          if (name.isEmpty)
            const Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "New Arrivals",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  children: [
                    HomeCard1(productIndex: 3),
                    HomeCard2(
                      firstProductIndex: 2,
                      secondProductIndex: 7,
                    )
                  ],
                )
              ],
            ),
        ],
      ),
    );
  }
}
