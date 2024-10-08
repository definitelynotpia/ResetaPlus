import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:mysql_client/mysql_client.dart';

// import './pages/login_page.dart';
import './pages/home_page.dart';

void main() {
  runApp(const MainApp());
}

String hashPassword(String password, String salt) {
  // Combine password and salt
  final bytes = utf8.encode(password + salt);

  // Hash the combined bytes using SHA-256
  final digest = sha256.convert(bytes);

  return digest.toString(); // Return the hashed password as a string
}

bool verifyPassword(String enteredPassword, String storedPasswordHash,
    String storedSalt, encrypt.Key storedKey, encrypt.IV storedIv) {
  // Create an encrypter using the AES algorithm and the stored encryption key
  final encrypter = encrypt.Encrypter(encrypt.AES(storedKey));

  // Decode the stored password hash from a base64 string to bytes
  final encryptedPasswordHash =
      encrypt.Encrypted.fromBase64(storedPasswordHash);

  // Decrypt the password hash using the encrypter and the stored initialization vector
  final decryptedPasswordHash =
      encrypter.decrypt(encryptedPasswordHash, iv: storedIv);

  // Hash the entered password using the stored salt to compare with the decrypted hash
  String hashedEnteredPassword = hashPassword(enteredPassword, storedSalt);

  // Compare the hashed entered password with the decrypted password hash
  return hashedEnteredPassword == decryptedPasswordHash;
}

Future<MySQLConnection> createConnection() async {
  final conn = await MySQLConnection.createConnection(
    host:
        "192.168.1.3", // !!NOTICE!! Please change this to your local MySQL server IP address
    port: 3306,
    userName: "root",
    password: "root",
    databaseName: "reseta_plus",
  );

  await conn.connect(); // Ensure you await the connection
  return conn; // Return the connection object
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Reseta+", // app title
      theme: ThemeData(
        fontFamily: "Montserrat", // set custom font as default
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // load Login page on startup
      // home: const LoginPage(title: "Login"),
      home: const HomePage(),
    );
  }
}
