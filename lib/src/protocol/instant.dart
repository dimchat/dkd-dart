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
import 'content.dart';
import 'envelope.dart';
import 'helpers.dart';

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
abstract interface class InstantMessage implements Message {

  /// message content
  Content get content;
  // // only for rebuild content
  // set content(Content body);

  //
  //  Factory methods
  //

  static InstantMessage create(Envelope head, Content body) {
    var holder = MessageHolder();
    return holder.instantHelper!.createInstantMessage(head, body);
  }

  static InstantMessage? parse(Object? msg) {
    var holder = MessageHolder();
    return holder.instantHelper!.parseInstantMessage(msg);
  }

  static int generateSerialNumber(int? msgType, DateTime? now) {
    var holder = MessageHolder();
    return holder.instantHelper!.generateSerialNumber(msgType, now);
  }

  static InstantMessageFactory? getFactory() {
    var holder = MessageHolder();
    return holder.instantHelper!.getInstantMessageFactory();
  }
  static void setFactory(InstantMessageFactory factory) {
    var holder = MessageHolder();
    holder.instantHelper!.setInstantMessageFactory(factory);
  }
}


///  Message Factory
///  ~~~~~~~~~~~~~~~
abstract interface class InstantMessageFactory {

  ///  Generate SN for message content
  ///
  /// @param msgType - content type
  /// @param now     - message time
  /// @return SN (uint64, serial number as msg id)
  int generateSerialNumber(int? msgType, DateTime? now);

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
