// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:therapy_kart/authentication/forget_password.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/authentication/custom_button.dart';
import 'package:therapy_kart/authentication/login_data.dart';
import 'package:therapy_kart/authentication/textfeild.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loadingButton = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  Map<String, String> data = {};
  bool isRegistration = false; // Track the registration state

  @override
  void initState() {
    super.initState();
    data = LoginData.signIn;
  }

  loginError(FirebaseAuthException e) {
    if (e.message != "") {
      setState(() {
        _loadingButton = false;
      });
      ApplicationState.showAlert(
          context, "Error processing your request", e.message.toString());
    }
  }

  void switchLogin() {
    setState(() {
      if (mapEquals(data, LoginData.signUp)) {
        data = LoginData.signIn;
      } else {
        data = LoginData.signUp;
      }

      // Toggle the registration state
      isRegistration = !isRegistration;
    });
  }

  void loginButtonPressed() {
    setState(() {
      _loadingButton = true;
    });
    ApplicationState applicationState =
        Provider.of<ApplicationState>(context, listen: false);
    if (mapEquals(data, LoginData.signUp)) {
      applicationState.signUp(
          _emailController.text, _passwordController.text, loginError);
    } else {
      applicationState.signIn(
          _emailController.text, _passwordController.text, loginError);
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 70),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(
                    data["heading"] as String,
                    style: const TextStyle(
                        fontSize: 29, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Text(
                    data["subHeading"] as String,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                        fontSize: 17),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomTextFeild(
              hintText: "Enter your e-mail here",
              textEditingController: _emailController,
              password: false,
              helperText: 'e-mail address',
            ),
            CustomTextFeild(
              hintText: "Enter your password here",
              textEditingController: _passwordController,
              password: true,
              helperText: 'password',
            ),
            Visibility(
              // Use Visibility widget to conditionally show/hide the button
              visible: !isRegistration, // Hide when in registration state
              child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  child: Container(
                      padding: const EdgeInsets.only(
                        right: 20,
                        bottom: 10,
                      ),
                      child: Ink(
                          child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.orange),
                      ))),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgetPassword()));
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: data['label'] as String,
              onPress: loginButtonPressed,
              loading: _loadingButton,
            ),
            const SizedBox(
                height: 20), // Add space between the button and the line
            Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      color: Color.fromARGB(255, 144, 143, 143),
                      // Choose the color you want for the line
                      thickness:
                          2, // Adjust the thickness of the line as needed
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 1.0),
                  child: const Text(
                    "or",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Color.fromARGB(255, 144, 143, 143),
                    ),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Divider(
                      color: Color.fromARGB(255, 144, 143,
                          143), // Choose the color you want for the line
                      thickness:
                          2, // Adjust the thickness of the line as needed
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            //const SizedBox(height: 30),
            SizedBox(
              height: 60,
              width: width * .9,
              child: GestureDetector(
                onTap: signInWithGoogle,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 100),
                      Image.asset(
                        "assets/images/google.png",
                        width: 22,
                      ),
                      const SizedBox(width: 20),
                      Text(
                        data["google"] as String,
                        style: const TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: switchLogin,
                    child: Text(
                      data["footer"] as String,
                      style: const TextStyle(color: Colors.orange),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    // ignore: avoid_print
    print(userCredential.user?.displayName);
  }

  void resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ApplicationState.showAlert(
        context,
        "Password Reset Email Sent",
        "An email has been sent to reset your password. Please check your inbox.",
      );
    } catch (e) {
      ApplicationState.showAlert(
        context,
        "Password Reset Failed",
        "Failed to send a password reset email. Please check your email address.",
      );
    }
  }
}
