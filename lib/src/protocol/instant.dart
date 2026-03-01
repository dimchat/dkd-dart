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


/// Interface for plaintext instant messages (unencrypted, first stage).
///
/// Represents the original, unencrypted message with plaintext content. This is
/// the starting point of the message transformation workflow before encryption
/// and signing.
///
/// Serialized format (Map/JSON):
/// ```json
/// {
///   // Envelope metadata
///   "sender": "moki@xxx",    // Sender's unique ID
///   "receiver": "hulk@yyy",  // Receiver's unique ID
///   "time": 123.45,          // Message timestamp (Unix timestamp in seconds)
///
///   // Plaintext content (complete Content object)
///   "content": {             // Unencrypted message body
///     "type": "0",           // Content type
///     "sn": 12345,           // Serial number (message ID)
///     "text": "Hello World"  // Message-specific fields
///   }
/// }
/// ```
abstract interface class InstantMessage implements Message {

  /// Plaintext message content (unencrypted body).
  ///
  /// This contains the actual message payload (text, commands, etc.) in its original
  /// unencrypted form. Cannot be null (core payload of the instant message).
  Content get content;
  // // only for rebuild content
  // set content(Content body);

  //
  //  Conveniences
  //

  static List<InstantMessage> convert(Iterable array) {
    List<InstantMessage> messages = [];
    InstantMessage? msg;
    for (var item in array) {
      msg = parse(item);
      if (msg == null) {
        continue;
      }
      messages.add(msg);
    }
    return messages;
  }

  static List<Map> revert(Iterable<InstantMessage> messages) {
    List<Map> array = [];
    for (InstantMessage msg in messages) {
      array.add(msg.toMap());
    }
    return array;
  }

  //
  //  Factory methods
  //

  static InstantMessage create(Envelope head, Content body) {
    var ext = MessageExtensions();
    return ext.instantHelper!.createInstantMessage(head, body);
  }

  static InstantMessage? parse(Object? msg) {
    var ext = MessageExtensions();
    return ext.instantHelper!.parseInstantMessage(msg);
  }

  static int generateSerialNumber([String? msgType, DateTime? now]) {
    var ext = MessageExtensions();
    return ext.instantHelper!.generateSerialNumber(msgType, now);
  }

  static InstantMessageFactory? getFactory() {
    var ext = MessageExtensions();
    return ext.instantHelper!.getInstantMessageFactory();
  }
  static void setFactory(InstantMessageFactory factory) {
    var ext = MessageExtensions();
    ext.instantHelper!.setInstantMessageFactory(factory);
  }
}


/// Factory interface for creating and parsing [InstantMessage] instances.
///
/// Provides methods to generate unique serial numbers, create new instant messages
/// from envelope/content pairs, and parse serialized instant messages.
abstract interface class InstantMessageFactory {

  /// Generates a unique serial number (SN) for message content.
  ///
  /// The SN serves as a unique message ID (uint64) to track and deduplicate messages.
  ///
  /// [msgType]: Type of the message content (used for algorithm-specific generation)
  ///
  /// [now]: Timestamp to incorporate into the SN (or current time if null)
  ///
  /// Returns: 64-bit unsigned integer (uint64) as unique serial number
  int generateSerialNumber(String? msgType, DateTime? now);

  /// Creates a new [InstantMessage] from envelope and plaintext content.
  ///
  /// Combines routing metadata (envelope) with unencrypted content to form a complete
  /// instant message (plaintext stage).
  ///
  /// [head]: Message envelope (routing metadata, cannot be null)
  ///
  /// [body]: Plaintext content (message payload, cannot be null)
  ///
  /// Returns: New [InstantMessage] instance
  InstantMessage createInstantMessage(Envelope head, Content body);

  /// Parses a serialized Map into an [InstantMessage] instance.
  ///
  /// Validates the structure and converts raw values (e.g., timestamp → DateTime,
  /// content map → Content object) to proper types.
  ///
  /// [msg]: Serialized instant message data (matches format in [InstantMessage])
  ///
  /// Returns: [InstantMessage] instance if parsing succeeds, null otherwise
  InstantMessage? parseInstantMessage(Map msg);
}
