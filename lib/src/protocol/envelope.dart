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
import 'package:mkm/mkm.dart';

import '../msg/factory.dart';

///  Envelope for message
///  ~~~~~~~~~~~~~~~~~~~~
///  This class is used to create a message envelope
///  which contains 'sender', 'receiver' and 'time'
///
///  data format: {
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123
///  }
abstract class Envelope implements Mapper {

  /// message from
  ID get sender;

  /// message to
  ID get receiver;

  /// message time
  DateTime? get time;

  ///  Group ID
  ///  ~~~~~~~~
  ///  when a group message was split/trimmed to a single message
  ///  the 'receiver' will be changed to a member ID, and
  ///  the group ID will be saved as 'group'.
  ID? get group;
  set group(ID? identifier);

  ///  Message Type
  ///  ~~~~~~~~~~~~
  ///  because the message content will be encrypted, so
  ///  the intermediate nodes(station) cannot recognize what kind of it.
  ///  we pick out the content type and set it in envelope
  ///  to let the station do its job.
  int? get type;
  set type(int? msgType);

  //
  //  Factory methods
  //

  static Envelope create({required ID sender, required ID receiver, DateTime? time}) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.createEnvelope(sender: sender, receiver: receiver, time: time);
  }

  static Envelope? parse(Object? env) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.parseEnvelope(env);
  }

  static EnvelopeFactory? getFactory() {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.getEnvelopeFactory();
  }
  static void setFactory(EnvelopeFactory factory) {
    MessageFactoryManager man = MessageFactoryManager();
    man.generalFactory.setEnvelopeFactory(factory);
  }
}

///  Envelope Factory
///  ~~~~~~~~~~~~~~~~
abstract class EnvelopeFactory {

  ///  Create envelope
  ///
  /// @param sender   - from where
  /// @param receiver - to where
  /// @param time     - when
  /// @return Envelope
  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time});

  ///  Parse map object to envelope
  ///
  /// @param env - envelope info
  /// @return Envelope
  Envelope? parseEnvelope(Map env);
}


/*
 *  Message Transforming
 *  ~~~~~~~~~~~~~~~~~~~~
 *
 *     Instant Message <-> Secure Message <-> Reliable Message
 *     +-------------+     +------------+     +--------------+
 *     |  sender     |     |  sender    |     |  sender      |
 *     |  receiver   |     |  receiver  |     |  receiver    |
 *     |  time       |     |  time      |     |  time        |
 *     |             |     |            |     |              |
 *     |  content    |     |  data      |     |  data        |
 *     +-------------+     |  key/keys  |     |  key/keys    |
 *                         +------------+     |  signature   |
 *                                            +--------------+
 *     Algorithm:
 *         data      = password.encrypt(content)
 *         key       = receiver.public_key.encrypt(password)
 *         signature = sender.private_key.sign(data)
 */


///  Message with Envelope
///  ~~~~~~~~~~~~~~~~~~~~~
///  Base classes for messages
///  This class is used to create a message
///  with the envelope fields, such as 'sender', 'receiver', and 'time'
///
///  data format: {
///      //-- envelope
///      sender   : "moki@xxx",
///      receiver : "hulk@yyy",
///      time     : 123,
///      //-- body
///      ...
///  }
abstract class Message implements Mapper {

  /// message envelope
  Envelope get envelope;

  ID get sender;       // envelope.sender
  ID get receiver;     // envelope.receiver
  DateTime? get time;  // content.time or envelope.time

  ID? get group;       // content.group or envelope.group
  int? get type;        // content.type or envelope.type
}
