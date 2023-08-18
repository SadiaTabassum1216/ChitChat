import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:webcrypto/webcrypto.dart';

//
// final keyPairFactory = E2eKeyPairFactory();
//
// final serverKeyPair = keyPairFactory.create();
// final clientKeyPair = keyPairFactory.create();
// final sharedKeyFactory = E2eSharedKeyFactory();
//
// final clientSharedKeyPair = sharedKeyFactory.create(KeyPair(
//   pk: serverKeyPair.pk,
//   sk: clientKeyPair.sk,
// ));
//
// final serverSharedKeyPair = sharedKeyFactory.create(KeyPair(
//   pk: clientKeyPair.pk,
//   sk: serverKeyPair.sk,
// ));
//
// // Implement E2E Shared key & Store shared key
// Uint8List _serverSharedKey = Uint8List(0);
// Uint8List _clientSharedKey = Uint8List(0);
//
// class ServerE2eSharedKey implements E2eSharedKey {
//   @override
//   Uint8List sharedKey() => _serverSharedKey;
// }
//
// class ClientE2eSharedKey implements E2eSharedKey {
//   @override
//   Uint8List sharedKey() => _clientSharedKey;
// }
//
// // Save shared key to data store
// _serverSharedKey = serverSharedKeyPair;
// _clientSharedKey = clientSharedKeyPair;

class encryption{
  static final key=encrypt.Key.fromLength(32);
  static final iv=encrypt.IV.fromLength(32);
  static final encrypter= encrypt.Encrypter(encrypt.AES(key));


  static encryptAES(text) {
    final encrypted=encrypter.encrypt(text,iv: iv);
    return encrypted.base64;
  }

  static decryptAES(text) {
    return encrypter.decrypt(text,iv:iv);
  }
  //
  // Future<void> _generateKeys() async {
  //
  //   KeyPair<EcdhPrivateKey, EcdhPublicKey> keyPair =
  //   await EcdhPrivateKey.(EllipticCurve.p256);
  //   Map<String, dynamic> publicKeyJwk =
  //   await keyPair.publicKey.exportJsonWebKey();
  //   Map<String, dynamic> privateKeyJwk =
  //   await keyPair.privateKey.exportJsonWebKey();
  // }

}