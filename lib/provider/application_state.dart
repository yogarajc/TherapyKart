// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:therapy_kart/models/product_detail.dart';
import 'package:therapy_kart/screens/cart_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ApplicationLoginState { loggetOut, loggedIn }

class ApplicationState extends ChangeNotifier {
  User? user;
  ApplicationLoginState loginState = ApplicationLoginState.loggetOut;
  List<CartItem> cart = [];
  bool cartDataLoaded = false;

  ApplicationState() {
    init();
    loadCartData();
  }

  Future<void> init() async {
    FirebaseAuth.instance.userChanges().listen((userFir) {
      if (userFir != null) {
        loginState = ApplicationLoginState.loggedIn;
        user = userFir;
      } else {
        loginState = ApplicationLoginState.loggetOut;
      }
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password,
      void Function(FirebaseAuthException e) errorCallBack) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorCallBack(e);
    }
  }

  Future<void> signUp(String email, String password,
      void Function(FirebaseAuthException e) errorCallBack) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      errorCallBack(e);
    }
  }

  void signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  static showAlert(context, String heading, String body) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(heading),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, "Ok");
            },
            child: const Text("Ok"),
          )
        ],
      ),
    );
  }

  Stream<List<CartItem>> get cartStream {
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('carts')
          .doc(user?.email)
          .snapshots()
          .map((docSnapshot) {
        final cartData = docSnapshot.data();
        if (cartData != null && cartData['cartItems'] is List) {
          List<dynamic> cartItems = cartData['cartItems'];
          return cartItems
              .map((item) => CartItem(
                    id: item['productId'],
                    title: item['title'],
                    price: item['price'].toDouble(),
                    quantity: item['quantity'],
                    description: item['description'],
                    image: item['image'],
                  ))
              .toList();
        } else {
          return <CartItem>[];
        }
      });
    } else {
      return const Stream<List<CartItem>>.empty();
    }
  }

  Future<void> loadCartData() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString('cart');
    if (cartData != null) {
      cart = CartItem.decode(cartData);
      cartDataLoaded = true;
      print('Loaded Cart Items: $cart'); // Add this line for debugging
      notifyListeners();
    }
  }

  Future<void> saveCartData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', CartItem.encode(cart));
  }

  Future<ProductDetails?> getProductDetailsById(String productId) async {
    // Replace this logic with your actual data retrieval mechanism
    // For example, you can fetch product details from Firebase Firestore or an API
    // This is a placeholder example, replace with your actual implementation
    try {
      final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return ProductDetails(
          id: productId,
          title: data['title'] as String,
          price: (data['price'] as num).toDouble(),
          description: data['description'] as String,
          image: data['imageUrl'] as String,
        );
      } else {
        return null; // Product not found
      }
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  Future<ProductDetails?> getProductDetailsByCartItem(CartItem cartItem) async {
    String productId = cartItem.id;
    try {
      final DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return ProductDetails(
          id: productId,
          title: data['title'] as String,
          price: (data['price'] as num).toDouble(),
          description: data['description'] as String,
          image: data['imageUrl'] as String,
        );
      } else {
        return null; // Product not found
      }
    } catch (e) {
      print('Error fetching product details: $e');
      return null;
    }
  }

  void addToCart(ProductDetails product, BuildContext context) async {
    final existingIndex = cart.indexWhere((item) => item.id == product.id);

    if (existingIndex >= 0) {
      // If the product is already in the cart, show a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is already in the cart.'),
        ),
      );
    } else {
      // If the product is not in the cart, add it as a new CartItem
      cart.add(CartItem(
        id: product.id,
        title: product.title,
        price: product.price,
        quantity: 1,
        image: product.image,
        description: product.description,
      ));

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cartCollection = FirebaseFirestore.instance.collection('carts');
        final cartDocument = cartCollection.doc(user.email);

        // Get the current cart items from Firestore
        final docSnapshot = await cartDocument.get();
        final cartData = docSnapshot.data();
        if (cartData != null && cartData['cartItems'] is List) {
          List<dynamic> cartItems = List.from(cartData['cartItems']);

          // Add the new item to the cartItems list in Firestore
          cartItems.add({
            'productId': product.id,
            'title': product.title,
            'price': product.price,
            'quantity': 1,
            'image': product.image,
            'description': product.description,
          });

          // Update the 'cartItems' array in Firestore with the updated cart items
          await cartDocument.update({
            'cartItems': cartItems,
          });
        } else {
          // If there are no cart items in Firestore, create a new cart document
          await cartDocument.set({
            'cartItems': [
              {
                'productId': product.id,
                'title': product.title,
                'price': product.price,
                'quantity': 1,
                'image': product.image,
                'description': product.description,
              },
            ],
          });
        }
      }
    }
  }

  void removeFromCart(String productId) async {
    if (user != null) {
      final cartCollection = FirebaseFirestore.instance.collection('carts');
      final cartDocument = cartCollection.doc(user!.email);

      // Get the current cart items from Firestore
      final docSnapshot = await cartDocument.get();
      final cartData = docSnapshot.data();
      if (cartData != null && cartData['cartItems'] is List) {
        List<dynamic> cartItems = List.from(cartData['cartItems']);

        // Find the index of the item with the specified productId
        int itemIndex = -1;
        for (int i = 0; i < cartItems.length; i++) {
          if (cartItems[i]['productId'] == productId) {
            itemIndex = i;
            break;
          }
        }

        // Remove the item from the cartItems list
        if (itemIndex != -1) {
          cartItems.removeAt(itemIndex);

          // Update the 'cartItems' array in Firestore
          await cartDocument.update({
            'cartItems': cartItems,
          });

          // Remove the item from the local 'cart' list
          cart.removeWhere((item) => item.id == productId);
        }
      }
    }
  }

  // Define a function for order placement
  void placeOrder() async {
    // Create an empty list to store order items
    List<Map<String, dynamic>> orderItems = [];

    // Fetch the user's cart
    List<CartItem> userCart = ApplicationState().cart;

    // Iterate through each item in the cart
    for (CartItem cartItem in userCart) {
      // Fetch product details for the current cart item
      ProductDetails? productDetails =
          await ApplicationState().getProductDetailsByCartItem(cartItem);

      if (productDetails != null) {
        // Create an order item map and add it to the list
        Map<String, dynamic> orderItem = {
          'productId': cartItem.id,
          'productTitle': productDetails.title,
          'productPrice': productDetails.price,
          'productDescription': productDetails.description,
          'quantity': cartItem.quantity,
        };

        orderItems.add(orderItem);
      }
    }

    // Now, the orderItems list should contain the data from the user's cart
    // You can use this list to process the order further or send it to a backend server
  }

//  List<CartItem> _cart = [];
  void updateCartItemQuantity(String itemId, int newQuantity) async {
    final cartItemIndex = cart.indexWhere((item) => item.id == itemId);

    if (cartItemIndex != -1) {
      // Check if the new quantity is valid (greater than or equal to 1)
      if (newQuantity >= 1) {
        cart[cartItemIndex].quantity = newQuantity;

        // Update the cart data in Firestore if the user is logged in
        if (user != null) {
          final cartCollection = FirebaseFirestore.instance.collection('carts');
          final cartDocument = cartCollection.doc(user!.email);

          // Get the current cart items from Firestore
          final docSnapshot = await cartDocument.get();
          final cartData = docSnapshot.data();
          if (cartData != null && cartData['cartItems'] is List) {
            List<dynamic> cartItems = List.from(cartData['cartItems']);

            // Find the item in the cartItems list and update its quantity
            for (int i = 0; i < cartItems.length; i++) {
              if (cartItems[i]['productId'] == itemId) {
                cartItems[i]['quantity'] = newQuantity;
                break;
              }
            }

            // Update the 'cartItems' array in Firestore with the updated cart items
            await cartDocument.update({
              'cartItems': cartItems,
            });
          }
        }

        // Notify listeners that the cart has been updated
        saveCartData(); // Save cart data locally
        notifyListeners();
      }
    }
  }

  bool isProductInCart(String productId) {
    return cart.any((item) => item.id == productId);
  }
}
