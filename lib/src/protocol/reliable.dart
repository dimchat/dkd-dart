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

import 'helpers.dart';
import 'secure.dart';

///  Reliable Message signed by an asymmetric key
///  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
///  This class is used to sign the SecureMessage
///  It contains a 'signature' field which signed with sender's private key
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- content data and key/keys
///      data     : "...",  // base64_encode( symmetric_encrypt(content))
///      key      : "...",  // base64_encode(asymmetric_encrypt(password))
///      keys     : {
///          "ID1": "key1", // base64_encode(asymmetric_encrypt(password))
///      },
///      //-- signature
///      signature: "..."   // base64_encode(asymmetric_sign(data))
///  }
abstract interface class ReliableMessage implements SecureMessage {

  Uint8List get signature;

  //
  //  Conveniences
  //

  static List<ReliableMessage> convert(Iterable array) {
    List<ReliableMessage> messages = [];
    ReliableMessage? msg;
    for (var item in array) {
      msg = parse(item);
      if (msg == null) {
        continue;
      }
      messages.add(msg);
    }
    return messages;
  }

  static List<Map> revert(Iterable<ReliableMessage> messages) {
    List<Map> array = [];
    for (ReliableMessage msg in messages) {
      array.add(msg.toMap());
    }
    return array;
  }

  //
  //  Factory methods
  //

  static ReliableMessage? parse(Object? msg) {
    var ext = MessageExtensions();
    return ext.reliableHelper!.parseReliableMessage(msg);
  }

  static ReliableMessageFactory? getFactory() {
    var ext = MessageExtensions();
    return ext.reliableHelper!.getReliableMessageFactory();
  }
  static void setFactory(ReliableMessageFactory factory) {
    var ext = MessageExtensions();
    ext.reliableHelper!.setReliableMessageFactory(factory);
  }
}


///  Message Factory
///  ~~~~~~~~~~~~~~~
abstract interface class ReliableMessageFactory {

  ///  Parse map object to message
  ///
  /// @param msg - message info
  /// @return ReliableMessage
  ReliableMessage? parseReliableMessage(Map msg);
}
