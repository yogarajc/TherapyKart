import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/screens/orders_screen.dart';
import 'package:therapy_kart/utils/user_form.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void signOutButtonPressed() {
    setState(() {});
    Provider.of<ApplicationState>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    // Get user details from the ApplicationState provider
    final user = Provider.of<ApplicationState>(context).user;

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 175,
                width: width,
                color: Colors.grey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UserForm()));
                          },
                          icon: const Icon(Icons.edit),
                          iconSize: 25,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                user?.displayName ??
                                    "Enter your username", // Display the username
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Text(
                                user?.email ??
                                    "cant get email", // Display the user email
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const ListTile(
                leading: Icon(Icons.settings),
                title: Text("Settings"),
              ),
              //Divider(thickness: 3),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.shopping_bag_outlined),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()));
                },
                title: const Text("My Orders"),
              ),
              //Divider(thickness: 3),
              const SizedBox(height: 10),
              const ListTile(
                leading: Icon(Icons.help_outline),
                title: Text("Help"),
              ),
              //Divider(thickness: 3),
              const SizedBox(height: 10),
              const ListTile(
                leading: Icon(Icons.question_answer_outlined),
                title: Text("FAQ"),
              ),
              //Divider(thickness: 3),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: signOutButtonPressed,
                child: const ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text("Logout"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
