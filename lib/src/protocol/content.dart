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
import 'package:mkm/protocol.dart';
import 'package:mkm/type.dart';

import 'helpers.dart';

/// Interface for message content (body) that contains the actual message data.
///
/// Represents the core payload of a message, including type identifier, metadata,
/// and message-specific data (text, commands, etc.). Implements [Mapper] for
/// serialization to/from structured formats (Map/JSON).
///
/// Serialized format (Map/JSON):
/// ```json
/// {
///   "type": "0",             // Message type (e.g., i2s(0) = "0" = "text")
///   "sn": 0,                 // Unique serial number (serves as message ID)
///
///   "time": 123.45,          // Message timestamp (Unix timestamp in seconds)
///   "group": "group@zzz",    // Optional group ID (marks this as a group message)
///
///   //-- message info
///   "text": "Hello World!",  // Text content (for text messages)
///   "command": "handshake"   // Command name (for system command messages)
///   //...
/// }
/// ```
abstract interface class Content implements Mapper {

  /// Message type identifier.
  ///
  /// This type categorizes the content payload (e.g., text, image, command) and
  /// is used to determine how to parse the message-specific fields (text, command, etc.).
  /// Generated via `i2s()` (integer to string) function (e.g., 0 → "0").
  String get type;

  /// Serial number (unique message identifier).
  ///
  /// This integer serves as a unique ID for the message, used for deduplication,
  /// tracking, and acknowledgment of message delivery.
  int get sn;

  /// Timestamp when the content was created.
  ///
  /// Represented as a [DateTime] object (parsed from Unix timestamp in serialized format).
  /// Returns: Content creation timestamp, or null if not specified.
  DateTime? get time;

  /// Group identifier for group messages.
  ///
  /// **Key Indicator**: The presence of this field (non-null value) signifies that
  /// this is a group message (as opposed to a direct message between two entities).
  ///
  /// Returns: Group ID for group messages, null for direct messages.
  ID? get group;
  set group(ID? identifier);

  //
  //  Conveniences
  //

  static List<Content> convert(Iterable array) {
    List<Content> contents = [];
    Content? msg;
    for (var item in array) {
      msg = parse(item);
      if (msg == null) {
        continue;
      }
      contents.add(msg);
    }
    return contents;
  }

  static List<Map> revert(Iterable<Content> contents) {
    List<Map> array = [];
    for (Content msg in contents) {
      array.add(msg.toMap());
    }
    return array;
  }

  //
  //  Factory methods
  //

  static Content? parse(Object? content) {
    var helper = sharedMessageExtensions.contentHelper;
    return helper!.parseContent(content);
  }

  static ContentFactory? getFactory(String msgType) {
    var helper = sharedMessageExtensions.contentHelper;
    return helper!.getContentFactory(msgType);
  }
  static void setFactory(String msgType, ContentFactory factory) {
    var helper = sharedMessageExtensions.contentHelper;
    helper!.setContentFactory(msgType, factory);
  }
}

/// Factory interface for parsing [Content] instances from serialized data.
///
/// Provides a method to reconstruct message content from its serialized Map/JSON
/// representation, with proper type validation and conversion.
abstract interface class ContentFactory {

  /// Parses a serialized Map into a [Content] instance.
  ///
  /// Validates the structure (required fields: type, sn) and converts raw values
  /// (e.g., Unix timestamp → DateTime, group string → ID) to proper types.
  ///
  /// [content]: Serialized content data in the Map format defined in [Content]
  /// Returns: [Content] instance if parsing/validation succeeds, null otherwise
  Content? parseContent(Map content);
}
