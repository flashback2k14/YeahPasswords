import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class CryptoHelper {
  factory CryptoHelper() => _instance;
  static final CryptoHelper _instance = CryptoHelper._internal();

  Encrypter _encrypter;
  final _iv = IV.fromLength(8);

  CryptoHelper._internal() {
    final key = Key.fromUtf8(
        "kdfjdfahgdfje4rkewfmdfnj!?egn434g4389g7dndkfjhg4r389rgerg");
    this._encrypter = Encrypter(Salsa20(key));
  }

  Uint8List encrypt(List<int> plainTextBytes) {
    return this._encrypter.encryptBytes(plainTextBytes, iv: this._iv).bytes;
  }

  String decrypt(Uint8List encryptedText) {
    Encrypted encrypted = Encrypted(encryptedText);
    return this._encrypter.decrypt(encrypted, iv: this._iv);
  }
}
