import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final void Function()? onPress; // Accept a nullable function
  final bool loading;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPress,
    required this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 60,
      width: width * 0.9,
      child: ElevatedButton(
        onPressed: onPress, // You can directly use the nullable function
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.orange),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
