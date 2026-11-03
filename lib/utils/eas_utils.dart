
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import "package:pointycastle/export.dart";

class EasUtils {
  static const int _aesKeyLength = 32; // 256 bits = 32 bytes
  static const int _gcmIvLength = 12; // 96 bits
  static const int _cbcIvLength = 16; // 128 bits
  static const int _saltLength = 16; // 128 bits
  static const int _pbkdf2Iterations = 10000;

  /// 生成AES256密钥
  /// 返回Base64编码的密钥字符串
  static String generateKey() {
    final random = Random.secure();
    final keyBytes = Uint8List(_aesKeyLength);
    for (int i = 0; i < _aesKeyLength; i++) {
      keyBytes[i] = random.nextInt(256);
    }
    return base64Encode(keyBytes);
  }

  /// 从字符串生成AES256密钥
  /// 使用标准SHA-256哈希将任意长度的字符串转换为32字节的AES256密钥
  /// [keyString] 输入的字符串
  /// 返回32字节的密钥字节数组
  static Uint8List generateKeyFromString(String keyString) {
    try {
      final keyBytes = utf8.encode(keyString);
      final digest = sha256.convert(keyBytes);
      return Uint8List.fromList(digest.bytes);
    } catch (e) {
      throw Exception('Failed to generate key from string: $e');
    }
  }

  /// 从字符串生成AES256密钥（返回Base64编码）
  /// [keyString] 输入的字符串
  /// 返回Base64编码的密钥字符串
  static String generateKeyFromStringBase64(String keyString) {
    return base64Encode(generateKeyFromString(keyString));
  }

  /// 生成随机IV
  /// [length] IV长度
  /// 返回IV字节数组
  static Uint8List generateIV(int length) {
    final random = Random.secure();
    final iv = Uint8List(length);
    for (int i = 0; i < length; i++) {
      iv[i] = random.nextInt(256);
    }
    return iv;
  }

  /// 生成随机盐值
  /// 返回Base64编码的盐值
  static String generateSalt() {
    final random = Random.secure();
    final salt = Uint8List(_saltLength);
    for (int i = 0; i < _saltLength; i++) {
      salt[i] = random.nextInt(256);
    }
    return base64Encode(salt);
  }

  /// 使用PBKDF2从密码派生密钥
  /// [password] 密码
  /// [salt] 盐值（Base64编码）
  /// [iterations] 迭代次数
  /// 返回Base64编码的派生密钥
  static String deriveKeyFromPassword(String password, String salt, int iterations) {
    try {
      final saltBytes = base64Decode(salt);
      final passwordBytes = utf8.encode(password);
      
      // 使用PointyCastle实现PBKDF2
      final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
      pbkdf2.init(Pbkdf2Parameters(saltBytes, iterations, _aesKeyLength));
      
      final derivedKey = pbkdf2.process(passwordBytes);
      return base64Encode(derivedKey);
    } catch (e) {
      throw Exception('Failed to derive key from password: $e');
    }
  }

  /// AES-GCM加密（完整实现）
  /// [plaintext] 明文
  /// [key] 密钥字符串（会自动转换为AES256密钥）
  /// 返回Base64编码的加密结果（包含IV和加密数据）
  static String encryptGCM(String plaintext, String key) {
    try {
      final keyBytes = generateKeyFromString(key);
      final iv = generateIV(_gcmIvLength);
      
      // 使用encrypt包进行AES-GCM加密
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(plaintext, iv: IV(iv));
      
      // 将IV和加密数据合并
      final result = Uint8List(iv.length + encrypted.bytes.length);
      result.setRange(0, iv.length, iv);
      result.setRange(iv.length, result.length, encrypted.bytes);
      
      return base64Encode(result);
    } catch (e) {
      throw Exception('AES-GCM encryption failed: $e');
    }
  }

  /// AES-GCM解密（完整实现）
  /// [encryptedData] Base64编码的加密数据（包含IV）
  /// [key] 密钥字符串（会自动转换为AES256密钥）
  /// 返回解密后的明文
  static String decryptGCM(String encryptedData, String key) {
    try {
      final keyBytes = generateKeyFromString(key);
      final data = base64Decode(encryptedData);
      
      if (data.length < _gcmIvLength) {
        throw Exception('Invalid encrypted data format');
      }
      
      // 分离IV和加密数据
      final iv = data.sublist(0, _gcmIvLength);
      final encrypted = data.sublist(_gcmIvLength);
      
      // 使用encrypt包进行AES-GCM解密
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.gcm));
      final decrypted = encrypter.decrypt(Encrypted(encrypted), iv: IV(iv));
      
      return decrypted;
    } catch (e) {
      throw Exception('AES-GCM decryption failed: $e');
    }
  }

  /// AES-CBC加密（完整实现）
  /// [plaintext] 明文
  /// [key] 密钥字符串（会自动转换为AES256密钥）
  /// 返回Base64编码的加密结果（包含IV和加密数据）
  static String encryptCBC(String plaintext, String key) {
    try {
      final keyBytes = generateKeyFromString(key);
      final iv = generateIV(_cbcIvLength);
      
      // 使用encrypt包进行AES-CBC加密
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
      final encrypted = encrypter.encrypt(plaintext, iv: IV(iv));
      
      // 将IV和加密数据合并
      final result = Uint8List(iv.length + encrypted.bytes.length);
      result.setRange(0, iv.length, iv);
      result.setRange(iv.length, result.length, encrypted.bytes);
      
      return base64Encode(result);
    } catch (e) {
      throw Exception('AES-CBC encryption failed: $e');
    }
  }

  /// AES-CBC解密（完整实现）
  /// [encryptedData] Base64编码的加密数据（包含IV）
  /// [key] 密钥字符串（会自动转换为AES256密钥）
  /// 返回解密后的明文
  static String decryptCBC(String encryptedData, String key) {
    try {
      final keyBytes = generateKeyFromString(key);
      final data = base64Decode(encryptedData);
      
      if (data.length < _cbcIvLength) {
        throw Exception('Invalid encrypted data format');
      }
      
      // 分离IV和加密数据
      final iv = data.sublist(0, _cbcIvLength);
      final encrypted = data.sublist(_cbcIvLength);
      
      // 使用encrypt包进行AES-CBC解密
      final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
      final decrypted = encrypter.decrypt(Encrypted(encrypted), iv: IV(iv));
      
      return decrypted;
    } catch (e) {
      throw Exception('AES-CBC decryption failed: $e');
    }
  }

  /// 简化的加密方法（使用GCM模式）
  /// [plaintext] 明文
  /// [password] 密码
  /// 返回加密结果对象，包含盐值和加密数据
  static EncryptionResult encrypt(String plaintext, String password) {
    final salt = generateSalt();
    final key = deriveKeyFromPassword(password, salt, _pbkdf2Iterations);
    final encryptedData = encryptGCM(plaintext, key);
    return EncryptionResult(salt, encryptedData);
  }

  /// 简化的解密方法（使用GCM模式）
  /// [encryptionResult] 加密结果对象
  /// [password] 密码
  /// 返回解密后的明文
  static String decrypt(EncryptionResult encryptionResult, String password) {
    final key = deriveKeyFromPassword(password, encryptionResult.salt, _pbkdf2Iterations);
    return decryptGCM(encryptionResult.encryptedData, key);
  }
}

/// 加密结果类
class EncryptionResult {
  final String salt;
  final String encryptedData;

  const EncryptionResult(this.salt, this.encryptedData);

  /// 转换为JSON字符串格式
  String toJson() {
    return jsonEncode({
      'salt': salt,
      'data': encryptedData,
    });
  }

  /// 从JSON字符串创建对象
  static EncryptionResult fromJson(String json) {
    final Map<String, dynamic> data = jsonDecode(json);
    return EncryptionResult(data['salt'], data['data']);
  }

  @override
  String toString() {
    return toJson();
  }
}