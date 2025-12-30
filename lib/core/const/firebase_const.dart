import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

@immutable
class FirebaseConst {
  /// Firebase Project name
  static const projectName = "project-management-app-7ace8";

  /// Firebase service json name
  static const serviceJson = {
    "type": "service_account",
    "project_id": "project-management-app-7ace8",
    "private_key_id": "df81fa7f2823ee9285a0ec51f667fd62e959d851",
    "private_key":"MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC/Nsf5azqe+f9QJg3jeW2zN9W792fDuaNJTFE+cZR4xu8h6R/mm8aS1/IbOOrngXT9VL9YkeHm07MCwJHf6bbghHgg7stl4YjMr0STkW+QRas6ByaX4auPJyGjCN/v5DtZtA+wC1RH3rTYvzfqF0JVNEV7pYyO3oWBlxUXLFtYRYBKHAq2h+C8hgP3e2i71ws/EoGFLDL+RU0WKMN5szkR9FSpQxd7v3rmr7QvKnsjB24T+MzBXmQOJSDmoCLs+vFiTtlLdhekwOpq4+/o007gZEOPvl5Zfmplwp06cL7acaKgqW/AfSwyC6s7zSZAqLKywqnXsrrYuolkGFla3jftAgMBAAECggEAC46LDZcehudDOBvksP/w0mkogODWI60/ojl7m5OPzrDvWRRW+kAmA1AL8PtCr1VStdD+c6L1jVb0NdFfv7HHfNBk1lC4eGLmOsDJG0YqAQVE8Q/nlDxuewt5a/ooVr5rm+NXI2O751AdjBAamApp1u5+2JdL5IKsfQWdn7Xtm2sVKTmZVirHkGdvXbKf9yNwfRTNAAsDmRYbA7kgnxLdGJzmTkKfrJk+X1HAUlC/9qnwlu11oVMTscO7KVVZcGtUTzJW86awdasjf7HVqhlRWz+/NhUwvTpDBuLWPCOtYeHLtpac1qq3TaYjFvEZEZRoXon9BS8ONiesOMxBlgYjgQKBgQDqMixTZeXwYH5ncfM44XZtJP4rNyl300fFekdUDX71UfKusJvnDoA8z8DwTirzCXFFFATVd/jfzn776HD7+TfYUtChtBc/sQxOhdcGP6ISDYSFatlX6+fc4Izz2Ktp3wQIQParN8DjkAWMXERoeGT3zi26LOOUuW11h8Yum98XzQKBgQDRBCzR5KDK/cyN6BfyNg+5iTl+g8gzDORRRBqLyEVQ513Q8KS8yf8hna20r77Rn1AFI38UIC5zU2X4t5M23bz5vtt4BzQuNciRoRpEmY2QjDoAVh3pQLwWI4/xMALkCYGJBzLWShKyNwhVvTQTPoHHPZ53HvHUaom9raCJ3RFAoQKBgBG/4bokY+v29D2U1lE+TUJyZk0SLjNlsO/Xl6ZYK4IeRt1Uh0xYvgFd4YqU8g5fbdVFciRXpmYX+WnQMRf3yHK9vBA1XPm3ym39GNHhasAhhCS0d2qBd5426pfkmQE6JM0XV1qcrCLTHIiJyal9TnG1j6OnmUwBTbl1o+COcbcVAoGAUOCLs0ADU+i3ESYAthFjLkjB/YlimxZe9m8i0nnREIgmTiX/qKmE1m4b+/GRJa2+me5tSs1VC/z2VTI7fZx5di364EvxTfwzut4auvarx4XrH5wzAMGyxeJG3W3VgIWJIQuvCSoqZ9lRmVOX5eZm80CNo8xOiQIcgE/B8fafqWECgYAGZrwq09tbMBXls1/8de2jlade+lvjwIAM67HpD/X3dEuVQbRnBym+OAp71ftXVfunp5Hrwltry1JR5PQ3fBSCkrMeVhif+BH11MRX1srw4DIpBi0BBbd1U3gOGW7dILROP1Q2bkDuvWZbQYLOWWLUWUEdtKTXAxqGxeTTJeJBLQ==",
    "client_email":
        "firebase-adminsdk-fbsvc@project-management-app-7ace8.iam.gserviceaccount.com",
    "client_id": "103735408044667337722",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40project-management-app-7ace8.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  static const String calls = "calls";

  // Example from Firebase console
  static const FirebaseOptions firebaseConfig = FirebaseOptions(
    apiKey: "AIzaSyXXXXXXX...",
    authDomain: "project-id.firebaseapp.com",
    projectId: "project-id",
    storageBucket: "project-id.appspot.com",
    messagingSenderId: "1234567890",
    appId: "1:1234567890:web:abcdef123456",
  );
}
