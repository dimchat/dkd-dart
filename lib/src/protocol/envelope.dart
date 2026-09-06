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


/// Interface for message envelopes (headers) that contain routing/metadata for messages.
///
/// Envelopes wrap core message content with essential delivery information, including
/// sender/receiver identifiers, timestamp, and metadata for message routing.
/// Implements [Mapper] for serialization to/from structured formats (Map/JSON).
///
/// Serialized format (Map/JSON):
/// ```json
/// {
///   "sender"   : "moki@xxx",   // Sender's unique ID
///   "receiver" : "hulk@yyy",   // Receiver's unique ID
///   "time"     : 123.45,       // Message timestamp (Unix timestamp in seconds)
///
///   "group"    : "group@zzz",  // Optional group ID (marks this as a group message)
///   "type"     : "text"        // Optional message type
/// }
/// ```
abstract interface class Envelope implements Mapper<String, dynamic> {

  /// Unique identifier of the message sender.
  ///
  /// This ID identifies the origin of the message (user) and cannot be null.
  ID get sender;

  /// Unique identifier of the message receiver.
  ///
  /// This ID identifies the target of the message (user/group) and cannot be null.
  ID get receiver;

  /// Timestamp when the message was created/sent.
  ///
  /// Represented as a [DateTime] object (parsed from Unix timestamp in serialized format).
  /// Returns the message timestamp, or null if not specified.
  DateTime? get time;

  /// Optional group identifier for group messages.
  ///
  /// **Special Behavior**: When a group message is split into individual messages for
  /// group members, the `receiver` field is updated to the member's ID, and the original
  /// group ID is stored in this `group` field to preserve context.
  ///
  /// Returns the original group ID for split group messages, null for direct messages.
  ID? get group;

  /// Set the group ID for a split group message.
  ///
  /// [gid] is the original group ID (null for direct messages).
  set group(ID? gid);

  /// Message content type identifier (for routing encrypted content).
  ///
  /// **Purpose**: Since message content may be encrypted, intermediate nodes (e.g., stations)
  /// cannot parse the content to determine its type. This field exposes the content type
  /// in plaintext to enable proper routing/processing by network nodes.
  ///
  /// Examples: "text", "file", "command", ...
  String? get type;

  /// Set the message content type.
  ///
  /// [msgType] is the content type identifier (e.g., "text", "file").
  set type(String? msgType);

  //
  //  Factory methods
  //

  /// Create a new [Envelope] with the given routing metadata.
  ///
  /// [sender] is the ID of the message sender.
  /// [receiver] is the ID of the message receiver (user/group).
  /// [time] is the message timestamp (defaults to current time if null).
  ///
  /// Returns a new [Envelope] instance.
  static Envelope create({required ID sender, required ID receiver, DateTime? time}) {
    final helper = sharedMessageExtensions.envelopeHelper;
    return helper!.createEnvelope(sender: sender, receiver: receiver, time: time);
  }

  /// Parse a raw object into an [Envelope] instance.
  ///
  /// [env] is the raw envelope data (map, JSON string, etc.).
  ///
  /// Returns a parsed [Envelope] instance, or null if parsing fails.
  static Envelope? parse(Object? env) {
    final helper = sharedMessageExtensions.envelopeHelper;
    return helper!.parseEnvelope(env);
  }

  /// Get the envelope factory.
  ///
  /// Returns the registered [EnvelopeFactory], or null if not registered.
  static EnvelopeFactory? getFactory() {
    final helper = sharedMessageExtensions.envelopeHelper;
    return helper!.getEnvelopeFactory();
  }

  /// Register the envelope factory.
  ///
  /// [factory] is the factory to be registered.
  static void setFactory(EnvelopeFactory factory) {
    final helper = sharedMessageExtensions.envelopeHelper;
    helper!.setEnvelopeFactory(factory);
  }
}

/// Factory interface for creating and parsing [Envelope] instances.
///
/// Provides methods to construct new envelopes from raw components and reconstruct
/// envelopes from their serialized Map/JSON representation.
abstract interface class EnvelopeFactory {

  /// Creates a new [Envelope] instance with required sender/receiver and optional timestamp.
  ///
  /// [sender] is the required sender ID (cannot be null).
  /// [receiver] is the required receiver ID (cannot be null).
  /// [time] is the optional message timestamp (defaults to current time if null).
  ///
  /// Returns a new [Envelope] instance with the specified parameters.
  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time});

  /// Parses a serialized Map into an [Envelope] instance.
  ///
  /// Validates the structure and converts raw values (e.g., Unix timestamp → DateTime)
  /// to the proper types defined in the [Envelope] interface.
  ///
  /// [env] is the serialized envelope data in the Map format defined in [Envelope].
  ///
  /// Returns an [Envelope] instance if parsing/validation succeeds, null otherwise.
  Envelope? parseEnvelope(Mapping env);
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
 *     +-------------+     |  keys      |     |  keys        |
 *                         +------------+     |  signature   |
 *                                            +--------------+
 *     Algorithm:
 *         data      = password.encrypt(content)
 *         key       = receiver.public_key.encrypt(password)
 *         signature = sender.private_key.sign(data)
 */

/// Message transformation workflow and cryptographic operations.
///
/// This framework defines three stages of message processing with increasing
/// security guarantees, enabling secure communication between entities:
///
/// ```
/// Instant Message → Secure Message → Reliable Message
/// (Plaintext)      (Encrypted)      (Encrypted + Signed)
/// ```
///
/// ### Data Structure Evolution
/// | Field          | Instant Message | Secure Message | Reliable Message |
/// |----------------|-----------------|----------------|------------------|
/// | sender         | ✅              | ✅             | ✅               |
/// | receiver       | ✅              | ✅             | ✅               |
/// | time           | ✅              | ✅             | ✅               |
/// | content        | ✅ (plaintext)  | ❌             | ❌               |
/// | data           | ❌              | ✅ (encrypted) | ✅ (encrypted)   |
/// | keys           | ❌              | ✅ (encrypted) | ✅ (encrypted)   |
/// | signature      | ❌              | ❌             | ✅ (signed)      |
///
/// ### Core Cryptographic Algorithms
/// 1. Content encryption: `data = symmetric_key.encrypt(content)`
/// 2. Key encryption: `key = receiver.public_key.encrypt(symmetric_key)`
/// 3. Signature generation: `signature = sender.private_key.sign(data)`
///
/// ### Reverse Transformation
/// Reliable Message → Secure Message → Instant Message (with decryption/verification)
/// - Verify signature → Extract secure message
/// - Decrypt keys to get symmetric key → Decrypt data to get content
/// -----------------------------------------------------------------------------
///

/// Base interface for all message types (Instant/Secure/Reliable).
///
/// All messages share a common envelope (routing metadata) and implement [Mapper]
/// for serialization to/from structured formats (Map/JSON). This interface provides
/// unified access to core message metadata (sender, receiver, time, etc.) across
/// all message stages.
///
/// Base serialized format (Map/JSON):
/// ```json
/// {
///   // Envelope (routing metadata)
///   "sender"   : "moki@xxx",  // Sender's unique ID
///   "receiver" : "hulk@yyy",  // Receiver's unique ID
///   "time"     : 123.45,      // Message timestamp (Unix timestamp in seconds)
///   // Message body (varies by message type)
///   ...
/// }
/// ```
abstract interface class Message implements Mapper<String, dynamic> {

  /// Complete message envelope containing routing metadata.
  ///
  /// Serves as the single source of truth for sender, receiver, and base timestamp.
  Envelope get envelope;

  /// Returns the message sender ID (envelope.sender).
  ID get sender;

  /// Returns the message receiver ID (envelope.receiver).
  ID get receiver;

  /// Returns the message timestamp (content.time or envelope.time).
  DateTime? get time;

  /// Returns the group ID for group messages (content.group or envelope.group).
  ID? get group;

  /// Returns the message type (content.type or envelope.type).
  String? get type;

}
