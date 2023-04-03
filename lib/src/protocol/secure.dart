/* license: https://mit-license.org
 *
 *  Dao-Ke-Dao: Universal Message Module
 *
 *                                Written in 2023 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2023 Albert Moky
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * ==============================================================================
 */
import 'dart:typed_data';

import 'package:mkm/mkm.dart';

import '../factory.dart';
import 'content.dart';
import 'envelope.dart';
import 'instant.dart';
import 'reliable.dart';

///  Secure Message
///  ~~~~~~~~~~~~~~
///  Instant Message encrypted by a symmetric key
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- content data and key/keys
///      data     : "...",  // base64_encode(symmetric)
///      key      : "...",  // base64_encode(asymmetric)
///      keys     : {
///          "ID1": "key1", // base64_encode(asymmetric)
///      }
///  }
abstract class SecureMessage implements Message {

  Uint8List get data;

  Uint8List? get encryptedKey;

  Map? get encryptedKeys;

  /*
   *  Decrypt the Secure Message to Instant Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |  1. PW      = decrypt(key, receiver.SK)
   *    | data     |      | content  |  2. content = decrypt(data, PW)
   *    | key/keys |      +----------+
   *    +----------+
   */

  ///  Decrypt message, replace encrypted 'data' with 'content' field
  ///
  /// @return InstantMessage object
  InstantMessage? decrypt();

  /*
   *  Sign the Secure Message to Reliable Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |
   *    | data     |      | data     |
   *    | key/keys |      | key/keys |
   *    +----------+      | signature|  1. signature = sign(data, sender.SK)
   *                      +----------+
   */

  ///  Sign message.data, add 'signature' field
  ///
  /// @return ReliableMessage object
  ReliableMessage sign();

  /*
   *  Split/Trim group message
   *
   *  for each members, get key from 'keys' and replace 'receiver' to member ID
   */

  ///  Split the group message to single person messages
  ///
  ///  @param members - group members
  ///  @return secure/reliable message(s)
  List<SecureMessage> split(List<ID> members);

  ///  Trim the group message for a member
  ///
  /// @param member - group member ID/string
  /// @return SecureMessage
  SecureMessage? trim(ID member);

  //
  //  Factory method
  //

  static SecureMessage? parse(Object? msg) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.parseSecureMessage(msg);
  }

  static SecureMessageFactory? getFactory() {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.getSecureMessageFactory();
  }
  static void setFactory(SecureMessageFactory? factory) {
    MessageFactoryManager man = MessageFactoryManager();
    man.generalFactory.setSecureMessageFactory(factory);
  }
}


///  Secure Message Delegate
///  ~~~~~~~~~~~~~~~~~~~~~~~
abstract class SecureMessageDelegate implements MessageDelegate {

  //
  //  Decrypt Key
  //

  ///  1. Decode 'message.key' to encrypted symmetric key data
  ///
  /// @param key - base64 string object
  /// @param sMsg - secure message object
  /// @return encrypted symmetric key data
  Uint8List? decodeKey(Object key, SecureMessage sMsg);

  ///  2. Decrypt 'message.key' with receiver's private key
  ///
  ///  @param key - encrypted symmetric key data
  ///  @param sender - sender/member ID string
  ///  @param receiver - receiver/group ID string
  ///  @param sMsg - secure message object
  ///  @return serialized symmetric key
  Uint8List? decryptKey(Uint8List key, ID sender, ID receiver, SecureMessage sMsg);

  ///  3. Deserialize message key from data (JsON / ProtoBuf / ...)
  ///
  /// @param key - serialized key data
  /// @param sender - sender/member ID string
  /// @param receiver - receiver/group ID string
  /// @param sMsg - secure message object
  /// @return symmetric key
  SymmetricKey? deserializeKey(Uint8List key, ID sender, ID receiver, SecureMessage sMsg);

  //
  //  Decrypt Content
  //

  ///  4. Decode 'message.data' to encrypted content data
  ///
  /// @param data - base64 string object
  /// @param sMsg - secure message object
  /// @return encrypted content data
  Uint8List? decodeData(Object data, SecureMessage sMsg);

  ///  5. Decrypt 'message.data' with symmetric key
  ///
  ///  @param data - encrypt content data
  ///  @param password - symmetric key
  ///  @param sMsg - secure message object
  ///  @return serialized message content
  Uint8List? decryptContent(Uint8List data, SymmetricKey password, SecureMessage sMsg);

  ///  6. Deserialize message content from data (JsON / ProtoBuf / ...)
  ///
  /// @param data - serialized content data
  /// @param password - symmetric key
  /// @param sMsg - secure message object
  /// @return message content
  Content? deserializeContent(Uint8List data, SymmetricKey password, SecureMessage sMsg);

  //
  //  Signature
  //

  ///  1. Sign 'message.data' with sender's private key
  ///
  ///  @param data - encrypted message data
  ///  @param sender - sender ID string
  ///  @param sMsg - secure message object
  ///  @return signature of encrypted message data
  Uint8List signData(Uint8List data, ID sender, SecureMessage sMsg);

  ///  2. Encode 'message.signature' to String (Base64)
  ///
  /// @param signature - signature of message.data
  /// @param sMsg - secure message object
  /// @return String object
  Object encodeSignature(Uint8List signature, SecureMessage sMsg);
}


///  Message Factory
///  ~~~~~~~~~~~~~~~
abstract class SecureMessageFactory {

  ///  Parse map object to message
  ///
  /// @param msg - message info
  /// @return SecureMessage
  SecureMessage? parseSecureMessage(Map msg);
}
