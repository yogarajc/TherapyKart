import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:therapy_kart/models/card_models/home_model_1.dart';
import 'package:therapy_kart/models/card_models/home_model_2.dart';
import 'package:therapy_kart/screens/search.dart';

class HomeScreen extends StatelessWidget {
  //final int productIndex; // Pass the product index as a parameter

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Hello ${user?.displayName ?? "User"} !",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                //IconButton(onPressed: (){}, icon: icon)
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 40,
                    width: width * 0.90,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Search here...",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Expanded(
              // Wrap StreamBuilder with Expanded
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset('assets/images/placeHolder.png'),
                  const SizedBox(height: 20),
                  const HomeCard2(firstProductIndex: 7, secondProductIndex: 9),
                  const SizedBox(height: 10),
                  const HomeCard1(productIndex: 8),
                  const HomeCard2(firstProductIndex: 2, secondProductIndex: 3),
                  const SizedBox(height: 10),
                  const HomeCard1(productIndex: 9),
                  const SizedBox(height: 30),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
}
