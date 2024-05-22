import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:therapy_kart/models/card_models/product_card1.dart';
import 'package:therapy_kart/screens/collections/sub_sub_collection.dart';

class SubCollectionScreen extends StatelessWidget {
  final CollectionReference collectionReference;

  const SubCollectionScreen({Key? key, required this.collectionReference})
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

          final subCollectionDocs = snapshot.data!.docs;

          return GridView.count(
            crossAxisCount: 2, // Display two columns
            childAspectRatio: 0.75, // Adjust this ratio for card proportions
            mainAxisSpacing: 8.0, // Adjust spacing between rows
            crossAxisSpacing: 8.0, // Adjust spacing between columns
            padding: const EdgeInsets.all(8.0), // Add padding around the grid
            children: subCollectionDocs.map((subCollectionDoc) {
              final subCollectionDocName = subCollectionDoc['name'];
              final subCollectionDocImage = subCollectionDoc['imageUrl'];

              return ProductCard1(
                name: subCollectionDocName,
                imageUrl: subCollectionDocImage, // Provide the actual image URL
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SubSubCollectionScreen(
                        collectionReference: subCollectionDoc.reference
                            .collection(subCollectionDocName),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
