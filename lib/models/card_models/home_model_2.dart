import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:therapy_kart/models/product_detail.dart';

class HomeCard2 extends StatefulWidget {
  final int firstProductIndex;
  final int secondProductIndex;

  const HomeCard2({
    Key? key,
    required this.firstProductIndex,
    required this.secondProductIndex,
  }) : super(key: key);

  @override
  State<HomeCard2> createState() => _HomeCard2State();
}

class _HomeCard2State extends State<HomeCard2> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    final firstProductIndex = widget.firstProductIndex;
    final secondProductIndex = widget.secondProductIndex;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        if (firstProductIndex < 0 ||
            firstProductIndex >= snapshot.data!.docs.length ||
            secondProductIndex < 0 ||
            secondProductIndex >= snapshot.data!.docs.length) {
          return const Text('Product not found');
        }

        final firstDoc = snapshot.data!.docs[firstProductIndex];
        final secondDoc = snapshot.data!.docs[secondProductIndex];

        final firstProductName = firstDoc['title'];
        final firstProductPrice = firstDoc['price'];
        final firstProductImage = firstDoc['image'];

        final secondProductName = secondDoc['title'];
        final secondProductPrice = secondDoc['price'];
        final secondProductImage = secondDoc['image'];

        return Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _navigateToProductDetail(
                      context,
                      firstDoc,
                    );
                  },
                  child: Container(
                    height: 210,
                    width: width * 0.45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(firstProductImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 60,
                            width: width * 0.45,
                            color: Colors.white.withOpacity(0.3),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          firstProductName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '₹${firstProductPrice.toString()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
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
                GestureDetector(
                  onTap: () {
                    _navigateToProductDetail(
                      context,
                      secondDoc,
                    );
                  },
                  child: Container(
                    height: 210,
                    width: width * 0.45,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(secondProductImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 60,
                            width: width * 0.45,
                            color: Colors.white.withOpacity(0.3),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          secondProductName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          '₹${secondProductPrice.toString()}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
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
