import 'dart:io';
import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

Future<MySQLConnection> createConnection() async {
  // Get the local IP address
  final interfaces = await NetworkInterface.list();
  final localIP = interfaces
      .expand((interface) => interface.addresses)
      .firstWhere(
          (addr) => addr.type == InternetAddressType.IPv4 && !addr.isLoopback);

  final conn = await MySQLConnection.createConnection(
    host: dotenv.env['DB_ADDRESS'] ?? localIP.address,
    port: int.parse(dotenv.env['DB_PORT'] ?? '3306'),
    userName: dotenv.env['DB_USER'] ?? 'root',
    password: dotenv.env['DB_PASSWORD'] ?? 'root',
    databaseName: dotenv.env['DB_NAME'] ?? 'reseta_plus',
  );

  await conn.connect(); // Ensure you await the connection
  return conn; // Return the connection object
}

Future<int> getUserID(String userType) async {
  // Construct the table name and ID field based on the user type
  String tableName = '${userType}_accounts';
  String idName = '${userType}_id';
  try {
    // Create a database connection
    final conn = await createConnection();

    // SQL query to fetch the user ID based on the username
    var userIdData = await conn.execute('''
    SELECT $idName 
    FROM $tableName 
    WHERE username = :username
    LIMIT 1;
    ''', {'username': await getUsernameSession()});

    int userID = 0; // Initialize userID to 0

    // Check if the query returned any rows
    if (userIdData.rows.isNotEmpty) {
      // Retrieve the first row's associated data
      var assoc = userIdData.rows.first.assoc();

      // Get the patient ID as a string
      String? patientIdString = assoc[idName];

      // Convert the string to an int, defaulting to 0 if parsing fails
      userID = patientIdString != null
          ? int.tryParse(patientIdString) ?? 0 // Default to 0 if parsing fails
          : 0; // Default to 0 if patientIdString is null;
    }

    // Return the retrieved user ID
    return userID;
  } catch (e) {
    // Handle errors during data fetching
    debugPrint("Error: $e");
  }

  // Return 0 if an error occurs or no user ID was found
  return 0;
}

// Function for getting the username session. Currently used upon initialization
Future<String> getUsernameSession() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('username') ?? "admin";
}

String hashPassword(String password, String salt) {
  // Combine password and salt
  final bytes = utf8.encode(password + salt);

  // Hash the combined bytes using SHA-256
  final digest = sha256.convert(bytes);

  return digest.toString(); // Return the hashed password as a string
}

String decryptPassword(String storedPasswordHash, String storedSalt,
    encrypt.Key storedKey, encrypt.IV storedIv) {
  // Create an encrypter using the AES algorithm and the stored encryption key
  final encrypter = encrypt.Encrypter(encrypt.AES(storedKey));

  // Decode the stored password hash from a base64 string to bytes
  final encryptedPasswordHash =
      encrypt.Encrypted.fromBase64(storedPasswordHash);

  // Return the decrypted password hash using the encrypter and the stored initialization vector
  return encrypter.decrypt(encryptedPasswordHash, iv: storedIv);
}

bool verifyPassword(String enteredPassword, String storedPasswordHash,
    String storedSalt, encrypt.Key storedKey, encrypt.IV storedIv) {
  final decryptedPasswordHash =
      decryptPassword(storedPasswordHash, storedSalt, storedKey, storedIv);

  // Hash the entered password using the stored salt to compare with the decrypted hash
  String hashedEnteredPassword = hashPassword(enteredPassword, storedSalt);

  // Compare the hashed entered password with the decrypted password hash
  return hashedEnteredPassword == decryptedPasswordHash;
}
