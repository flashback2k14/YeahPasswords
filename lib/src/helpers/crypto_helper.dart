import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class CryptoHelper {
  factory CryptoHelper() => _instance;
  static final CryptoHelper _instance = CryptoHelper._internal();

  final _iv = IV.fromLength(8);

  CryptoHelper._internal();

  Uint8List encrypt(List<int> plainTextBytes, String seckey) {
    final key = Key.fromUtf8(seckey);
    final encrypter = Encrypter(Salsa20(key));
    return encrypter.encryptBytes(plainTextBytes, iv: this._iv).bytes;
  }

  String decrypt(Uint8List encryptedText, String seckey) {
    final key = Key.fromUtf8(seckey);
    final encrypter = Encrypter(Salsa20(key));
    final encrypted = Encrypted(encryptedText);
    return encrypter.decrypt(encrypted, iv: this._iv);
  }
}
