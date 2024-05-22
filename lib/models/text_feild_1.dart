import 'package:flutter/material.dart';

class TextFeild1 extends StatefulWidget {
  final String hintText;
  final String label;
  final TextEditingController textEditingController;
  const TextFeild1(
      {super.key,
      required this.hintText,
      required this.label,
      required this.textEditingController});

  @override
  State<TextFeild1> createState() => _TextFeild1State();
}

class _TextFeild1State extends State<TextFeild1> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      height: 50,
      width: width * .98,
      child: TextField(
        controller: widget.textEditingController,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: widget.hintText,
          label: Text(widget.label),
        ),
      ),
    );
  }
}
