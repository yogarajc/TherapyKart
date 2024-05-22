import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  String? userEmail = FirebaseAuth.instance.currentUser!.email;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  //final TextEditingController _phoneController = TextEditingController();

  Future<void> _submitButton() async {
    if (formKey.currentState!.validate()) {
      final batch = FirebaseFirestore.instance.batch();

      // Update user data in Firestore
      final userDocRef =
          FirebaseFirestore.instance.collection("user_form").doc(userEmail);
      batch.set(userDocRef, {
        'name': _nameController.text,
        //'phone number': _phoneController.text,
        // ... other fields
      });

      // Update user display name
      final user = FirebaseAuth.instance.currentUser;
      final displayName = _nameController.text;
      if (user != null) {
        await user.updateDisplayName(displayName);
      }

      try {
        await batch.commit();
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      } catch (e) {
        // ignore: avoid_print
        print("Error updating user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal information"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == "") {
                    return "please enter your name";
                  } else {
                    return null;
                  }
                },
                controller: _nameController,
                decoration: const InputDecoration(
                    hintText: "Input your name",
                    labelText: "name",
                    prefixIcon: Icon(Icons.account_circle)),
              ),
              // SizedBox(height: 20),
              // TextFormField(
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return "Please enter your mobile number";
              //     } else if (value.length < 10 || int.tryParse(value) == null) {
              //       return "Please enter a valid 10-digit mobile number";
              //     } else {
              //       return null;
              //     }
              //   },
              //   controller: _phoneController,
              //   keyboardType: TextInputType.number,
              //   decoration: const InputDecoration(
              //     hintText: "Input your mobile number",
              //     labelText: "number",
              //     prefixIcon: Icon(Icons.phone),
              //   ),
              // ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitButton,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
