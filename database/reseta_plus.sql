CREATE DATABASE  IF NOT EXISTS `reseta_plus` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `reseta_plus`;
-- MySQL dump 10.13  Distrib 8.0.40, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: reseta_plus
-- ------------------------------------------------------
-- Server version	8.0.40

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `doctor_account_keys`
--

DROP TABLE IF EXISTS `doctor_account_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_account_keys` (
  `doctor_key_id` int NOT NULL AUTO_INCREMENT,
  `encryption_key` varchar(255) DEFAULT NULL,
  `initialization_vector` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`doctor_key_id`),
  UNIQUE KEY `doctor_key_id_UNIQUE` (`doctor_key_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doctor_accounts`
--

DROP TABLE IF EXISTS `doctor_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_accounts` (
  `doctor_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `license_number` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`doctor_id`),
  UNIQUE KEY `user_id_UNIQUE` (`doctor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `medications`
--

DROP TABLE IF EXISTS `medications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medications` (
  `medication_id` int NOT NULL AUTO_INCREMENT,
  `medication_name` varchar(255) NOT NULL,
  `medication_form` varchar(255) NOT NULL,
  `manufacturer` varchar(255) NOT NULL,
  `medication_info` varchar(255) NOT NULL,
  `medication_description` varchar(255) NOT NULL,
  PRIMARY KEY (`medication_id`),
  UNIQUE KEY `medication_id_UNIQUE` (`medication_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `medications_dosage`
--

DROP TABLE IF EXISTS `medications_dosage`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medications_dosage` (
  `dosage_id` int NOT NULL AUTO_INCREMENT,
  `medication_id` varchar(255) NOT NULL,
  `dosage` varchar(255) NOT NULL,
  PRIMARY KEY (`dosage_id`),
  UNIQUE KEY `dosage_id_UNIQUE` (`dosage_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_account_keys`
--

DROP TABLE IF EXISTS `patient_account_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_account_keys` (
  `patient_key_id` int NOT NULL AUTO_INCREMENT,
  `encryption_key` varchar(255) DEFAULT NULL,
  `initialization_vector` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`patient_key_id`),
  UNIQUE KEY `patient_key_id_UNIQUE` (`patient_key_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_accounts`
--

DROP TABLE IF EXISTS `patient_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_accounts` (
  `patient_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`patient_id`),
  UNIQUE KEY `user_id_UNIQUE` (`patient_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_prescription_intakes`
--

DROP TABLE IF EXISTS `patient_prescription_intakes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_prescription_intakes` (
  `prescription_intake_id` int NOT NULL AUTO_INCREMENT,
  `prescription_id` int NOT NULL,
  `patient_id` int NOT NULL,
  `intake_date` date NOT NULL,
  `intake_time` time NOT NULL,
  `status` varchar(255) NOT NULL,
  PRIMARY KEY (`prescription_intake_id`),
  UNIQUE KEY `prescription_intake_jd_UNIQUE` (`prescription_intake_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `patient_prescriptions`
--

DROP TABLE IF EXISTS `patient_prescriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `patient_prescriptions` (
  `prescription_id` int NOT NULL AUTO_INCREMENT,
  `patient_id` int NOT NULL,
  `medication_id` int NOT NULL,
  `prescription_date` date NOT NULL,
  `prescription_end_date` date NOT NULL,
  `frequency` varchar(255) NOT NULL,
  `dosage` varchar(255) NOT NULL,
  `duration` varchar(255) NOT NULL,
  `refills` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL,
  `intake_instructions` varchar(255) NOT NULL,
  `doctor_id` int NOT NULL,
  `qr_code_filepath` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`prescription_id`),
  UNIQUE KEY `prescription_id_UNIQUE` (`prescription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pharmacy_account_keys`
--

DROP TABLE IF EXISTS `pharmacy_account_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_account_keys` (
  `pharmacy_key_id` int NOT NULL AUTO_INCREMENT,
  `encryption_key` varchar(255) DEFAULT NULL,
  `initialization_vector` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`pharmacy_key_id`),
  UNIQUE KEY `pharmacy_key_id_UNIQUE` (`pharmacy_key_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pharmacy_accounts`
--

DROP TABLE IF EXISTS `pharmacy_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pharmacy_accounts` (
  `pharmacy_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `salt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`pharmacy_id`),
  UNIQUE KEY `pharmacy_id_UNIQUE` (`pharmacy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `verified_license`
--

DROP TABLE IF EXISTS `verified_license`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `verified_license` (
  `license_id` int NOT NULL AUTO_INCREMENT,
  `license_number` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`license_id`),
  UNIQUE KEY `user_id_UNIQUE` (`license_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

INSERT INTO medications (medication_name, medication_form, manufacturer, medication_info, medication_description) VALUES
('Amoxicillin', 'Capsule', 'PharmaCorp', 'Antibiotic', 'Used to treat bacterial infections.'),
('Ibuprofen', 'Tablet', 'HealthCo', 'Nonsteroidal anti-inflammatory drug (NSAID)', 'Reduces fever and relieves pain or inflammation.'),
('Lisinopril', 'Tablet', 'MediPharm', 'ACE inhibitor', 'Used to treat high blood pressure and heart failure.'),
('Metformin', 'Tablet', 'DiabetesCare', 'Antidiabetic medication', 'Helps control blood sugar levels in type 2 diabetes.'),
('Cetirizine', 'Tablet', 'AllergyRelief', 'Antihistamine', 'Used to relieve allergy symptoms such as runny nose and sneezing.'),
('Amlodipine', 'Tablet', 'CardioMed', 'Calcium channel blocker', 'Used to treat high blood pressure and chest pain.'),
('Simvastatin', 'Tablet', 'CholesterolCare', 'Statin', 'Used to lower cholesterol levels in the blood.'),
('Omeprazole', 'Capsule', 'StomachHealth', 'Proton pump inhibitor', 'Reduces stomach acid and treats GERD.'),
('Sertraline', 'Tablet', 'MoodStabilizers', 'SSRI', 'Used to treat depression and anxiety disorders.'),
('Levothyroxine', 'Tablet', 'ThyroidMed', 'Thyroid hormone', 'Used to treat hypothyroidism.');

INSERT INTO medications_dosage (medication_id, dosage) VALUES
('1', '250mg'),
('1', '500mg'),
('2', '200mg'),
('2', '400mg'),
('3', '5mg'),
('3', '10mg'),
('4', '500mg'),
('4', '1000mg'),
('5', '10mg'),
('5', '20mg'),
('6', '5mg'),
('6', '10mg'),
('7', '20mg'),
('7', '40mg'),
('8', '20mg'),
('8', '40mg'),
('9', '50mg'),
('9', '100mg'),
('10', '25mg'),
('10', '50mg');

INSERT INTO verified_license (license_number) VALUES('1234');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-05  0:33:43
