import 'package:flutter/material.dart';

class ProductCard1 extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback? onPress;

  const ProductCard1({
    Key? key,
    required this.name,
    required this.imageUrl,
    this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPress,
      child: Card(
        elevation: 4, // Add elevation for a shadow effect
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          height: width * 0.47,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          width: width * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 50,
                width: width,
                color: Colors.white.withOpacity(0.6),
                child: Center(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
