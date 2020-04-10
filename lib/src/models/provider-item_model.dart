import 'dart:convert';
import 'dart:typed_data';

import 'package:yeah_passwords/src/helpers/crypto_helper.dart';

class ProviderItem {
  String name;
  String password;

  ProviderItem({this.name, this.password});

  ProviderItem.createEmptyItem() {
    name = "EMPTY";
    password = "EMPTY";
  }

  ProviderItem.fromUint8List(Uint8List payload) {
    this.fromString(CryptoHelper().decrypt(payload));
  }

  void fromString(String savedValue) {
    List<String> parts = savedValue.split('#VP#');
    if (parts.length < 2) {
      return;
    }
    this.name = parts[0];
    this.password = parts[1];
  }

  Uint8List toUint8List() {
    String savableValue = this.toString();
    List<int> bytes = utf8.encode(savableValue);
    return Uint8List.fromList(CryptoHelper().encrypt(bytes));
  }

  bool isEmptyItem() {
    return name == "EMPTY" && password == "EMPTY";
  }

  @override
  String toString() {
    return name + '#VP#' + password;
  }
}
