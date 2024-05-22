// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'package:therapy_kart/authentication/login.dart';
import 'package:therapy_kart/firebase_options.dart';
import 'package:therapy_kart/provider/application_state.dart';
import 'package:therapy_kart/utils/bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Razorpay
  final _razorpay = Razorpay();

  // Define a function to handle payment success
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Handle payment success
    print("Payment ID: ${response.paymentId}");
    print("Order ID: ${response.orderId}");
    print("Signature: ${response.signature}");
    // You can navigate to a success screen or perform any other necessary action here.
  }

  // Define a function to handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle payment failure
    print("Error: ${response.code} - ${response.message}");
    // You can display an error message to the user or perform any other necessary action here.
  }

  // Define a function to handle external wallet selection
  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet selection
    print("External Wallet: ${response.walletName}");
    // You can perform any necessary action here.
  }

  // Set up payment event handlers
  _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
  _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: (context, _) => Consumer<ApplicationState>(
        builder: (context, applicationState, _) {
          Widget child;
          switch (applicationState.loginState) {
            case ApplicationLoginState.loggetOut:
              child = const LoginPage();
              break;
            case ApplicationLoginState.loggedIn:
              child = const MyApp();
              break;
            default:
              child = const LoginPage();
          }
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: child,
          );
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.orange,
        primarySwatch: Colors.orange,
      ),
      title: "Therapy kart",
      debugShowCheckedModeBanner: false,
      home: const BottomNavBar(),
    );
  }
}
