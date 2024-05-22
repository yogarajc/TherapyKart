// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomTextFeild extends StatefulWidget {
  final String hintText;
  final String helperText;
  final TextEditingController textEditingController;
  final bool password;

  const CustomTextFeild({
    Key? key,
    required this.hintText,
    required this.textEditingController,
    required this.password,
    required this.helperText,
  }) : super(key: key);

  @override
  _CustomTextFeildState createState() => _CustomTextFeildState();
}

class _CustomTextFeildState extends State<CustomTextFeild> {
  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Row(
            children: [
              Text(
                widget.helperText,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 90,
          width: width * 0.99,
          child: TextField(
            controller: widget.textEditingController,
            obscureText: widget.password ? _obscureText : false,
            enableSuggestions: !widget.password,
            autocorrect: !widget.password,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0), // Set border radius
                borderSide: BorderSide.none, // Remove border line
              ),
              hintText: widget.hintText,
              filled: true, // Fill the input field with color
              fillColor: Colors.grey[200], // Set the background color
              suffixIcon: widget.password
                  ? Theme(
                      data: ThemeData(
                        // Set the icon color to the default color (black)
                        iconTheme: const IconThemeData(color: Colors.black),
                      ),
                      child: IconButton(
                        onPressed: _togglePasswordVisibility,
                        icon: Icon(
                          _obscureText
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
