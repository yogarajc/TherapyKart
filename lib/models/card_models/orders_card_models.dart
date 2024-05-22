import 'package:flutter/material.dart';

class OrdersCard extends StatelessWidget {
  final String title;
  final double price;
  final String image;
  final int quantity;

  const OrdersCard({
    Key? key,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 180.0, // Set the height to 180
        margin: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.network(
                  image,
                  height: 130,
                  width: 130,
                ),
                const SizedBox(width: 30),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Price : ₹${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16.0,
                          //color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Quantity : ${quantity.toString()}',
                        style: const TextStyle(
                          fontSize: 12.0,
                          //color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(4.0),
              color: Colors.green, // Green background color
              alignment: Alignment.center,
              child: const Text(
                'Status: Order Paid',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
