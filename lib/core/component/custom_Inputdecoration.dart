//Helper widget for labels
  import 'package:flutter/material.dart';

Widget buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey
        ),
      ),
    );
  }

  // Helper for input decoration
  InputDecoration buildInputDecoration({
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isPrefix= true,
  }) {
    return InputDecoration(
      // filled: true,
      // fillColor: Colors.white,
      hintText: hintText,
      // hintStyle: TextStyle(color: _textGrey),
      prefixIcon: isPrefix? Icon(prefixIcon):SizedBox(),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide( width: 1.5),
      ),
    );
  }