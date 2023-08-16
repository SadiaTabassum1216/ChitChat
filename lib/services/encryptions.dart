import 'package:encrypt/encrypt.dart' as encrypt;
class encryption{
  static final key=encrypt.Key.fromLength(32);
  static final iv=encrypt.IV.fromLength(32);
  static final encrypter= encrypt.Encrypter(encrypt.AES(key));

  static encryptAES(text) {
    if (text != null && text.isNotEmpty) {
      final encrypted = encrypter.encrypt(text, iv: iv);
      return encrypted;
    } else {
      return ''; // Return an empty string or handle the case as appropriate.
    }
  }

  static decryptAES(text) {
    if (text != null && text.isNotEmpty) {
      final decrypted = encrypter.decrypt(text, iv: iv);
      return decrypted;
    } else {
      return ''; // Return an empty string or handle the case as appropriate.
    }
  }

}