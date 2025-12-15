import 'package:flutter/material.dart';

@immutable
sealed class ApiConst {
  // Base URL for different environments
  // static const String BASE_URL_DEV = "http://192.168.50.21:8000";
  static const String BASE_URL_DEV = "https://fakestoreapi.com";
  static const String BASE_URL_STAGING = "https://staging-api.example.com";
  static const String BASE_URL_PROD = "https://api.example.com";

  // Auth API paths (endpoints)
  static const String LOGIN = "/auth/login";
  static const String LOGOUT = "/auth/logout";
  static const String REGISTER = "/auth/register";
  static const String PROFILE = "/auth/profile";
  static const String DELETE_ACCOUNT = "/auth/delete-account";
  static const String FORGET_PASSWORD = "/auth/forget-password";
  static const String GET_OTP = "/auth/get-otp";
  static const String RESEND_OTP = "/auth/resend-otp";
  static const String CHANGE_PASSWORD = "/auth/change-password";
  static const String RESET_PASSWORD = "/auth/reset-password";
  static const String VERIFY_OTP = "/auth/verify-otp";

  /// Category API paths
  static const String CATEGORIES = "/categories";

  /// Products API paths
  static const String allProducts = "/products";
  static const String productsByCategory = "/categories";


  static const String error = "/error";

  // Timeout settings for network calls
  static const int TIMEOUT_DURATION_IN_SECONDS = 30;
}
