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
import 'secure.dart';

///  Instant Message
///  ~~~~~~~~~~~~~~~
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- content
///      content  : {...}
///  }
abstract class InstantMessage implements Message {

  /// message content
  Content get content;
  // only for rebuild content
  set content(Content body);

  /*
   *  Encrypt the Instant Message to Secure Message
   *
   *    +----------+      +----------+
   *    | sender   |      | sender   |
   *    | receiver |      | receiver |
   *    | time     |  ->  | time     |
   *    |          |      |          |
   *    | content  |      | data     |  1. data = encrypt(content, PW)
   *    +----------+      | key/keys |  2. key  = encrypt(PW, receiver.PK)
   *                      +----------+
   */

  /// 1. Encrypt message, replace 'content' field with encrypted 'data'
  /// 2. Encrypt group message, replace 'content' field with encrypted 'data'
  ///
  /// @param password - symmetric key
  /// @param members - group members for group message
  /// @return SecureMessage object, null on visa not found
  Future<SecureMessage?> encrypt(SymmetricKey password, {List<ID>? members});

  //
  //  Factory methods
  //

  static InstantMessage create(Envelope head, Content body) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.createInstantMessage(head, body);
  }

  static InstantMessage? parse(Object? msg) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.parseInstantMessage(msg);
  }

  static int generateSerialNumber(int msgType, DateTime now) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.generateSerialNumber(msgType, now);
  }

  static InstantMessageFactory? getFactory() {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.getInstantMessageFactory();
  }
  static void setFactory(InstantMessageFactory factory) {
    MessageFactoryManager man = MessageFactoryManager();
    man.generalFactory.setInstantMessageFactory(factory);
  }
}


///  Instant Message Delegate
///  ~~~~~~~~~~~~~~~~~~~~~~~~
abstract class InstantMessageDelegate implements MessageDelegate {

  //
  //  Encrypt Content
  //

  ///  1. Serialize 'message.content' to data (JsON / ProtoBuf / ...)
  ///
  /// @param iMsg - instant message object
  /// @param content - message.content
  /// @param password - symmetric key
  /// @return serialized content data
  Future<Uint8List> serializeContent(Content content, SymmetricKey password, InstantMessage iMsg);

  ///  2. Encrypt content data to 'message.data' with symmetric key
  ///
  /// @param iMsg - instant message object
  /// @param data - serialized data of message.content
  /// @param password - symmetric key
  /// @return encrypted message content data
  Future<Uint8List> encryptContent(Uint8List data, SymmetricKey password, InstantMessage iMsg);

  ///  3. Encode 'message.data' to String (Base64)
  ///
  /// @param iMsg - instant message object
  /// @param data - encrypted content data
  /// @return String object
  Future<Object> encodeData(Uint8List data, InstantMessage iMsg);

  //
  //  Encrypt Key
  //

  ///  4. Serialize message key to data (JsON / ProtoBuf / ...)
  ///
  /// @param iMsg - instant message object
  /// @param password - symmetric key
  /// @return serialized key data, null for broadcast message
  Future<Uint8List?> serializeKey(SymmetricKey password, InstantMessage iMsg);

  ///  5. Encrypt key data to 'message.key' with receiver's public key
  ///
  /// @param iMsg - instant message object
  /// @param key - serialized data of symmetric key
  /// @param receiver - receiver ID string
  /// @return encrypted symmetric key data, null on visa not found
  Future<Uint8List?> encryptKey(Uint8List key, ID receiver, InstantMessage iMsg);

  ///  6. Encode 'message.key' to String (Base64)
  ///
  /// @param iMsg - instant message object
  /// @param key - encrypted symmetric key data
  /// @return String object
  Future<Object> encodeKey(Uint8List key, InstantMessage iMsg);
}


///  Message Factory
///  ~~~~~~~~~~~~~~~
abstract class InstantMessageFactory {

  ///  Generate SN for message content
  ///
  /// @param msgType - content type
  /// @param now     - message time
  /// @return SN (serial number as msg id)
  int generateSerialNumber(int msgType, DateTime now);

  ///  Create instant message with envelope & content
  ///
  /// @param head - message envelope
  /// @param body - message content
  /// @return InstantMessage
  InstantMessage createInstantMessage(Envelope head, Content body);

  ///  Parse map object to message
  ///
  /// @param msg - message info
  /// @return InstantMessage
  InstantMessage? parseInstantMessage(Map msg);
}
