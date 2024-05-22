import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback? onPress;
  const CategoryCard({super.key, required this.name, required this.imageUrl, this.onPress});

  @override
  Widget build(BuildContext context) {
       var width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onPress,
      child: Container(
        height: width*0.55,
        width: width * 0.95,
        // Replaced the red color with Image.network
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl), // Use the provided imageUrl
            fit: BoxFit.cover,
          ),
        ),
        //width: width * 0.43,
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
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}