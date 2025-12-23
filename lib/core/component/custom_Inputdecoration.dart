//Helper widget for labels
import 'package:flutter/material.dart';

Widget buildLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
    ),
  );
}

// Helper for input decoration
InputDecoration buildInputDecoration({
  required String hintText,
  IconData? prefixIcon,
  Widget? suffixIcon,
  bool isPrefix = true,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: isPrefix && prefixIcon != null ? Icon(prefixIcon) : null,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(width: 1.5),
    ),
  );
}
