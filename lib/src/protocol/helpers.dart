/* license: https://mit-license.org
 *
 *  Dao-Ke-Dao: Universal Message Module
 *
 *                                Written in 2024 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2024 Albert Moky
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

import 'content.dart';
import 'envelope.dart';
import 'instant.dart';
import 'reliable.dart';
import 'secure.dart';

// -----------------------------------------------------------------------------
//  Message Helpers
// -----------------------------------------------------------------------------

/// Helper interface for message content management.
///
/// Manages content factories (by message type) and provides core functionality for:
/// - Registering type-specific content factories (e.g., text, image, command)
/// - Parsing raw content data into strongly-typed [Content] instances
///
/// Content represents the payload of a message (text, file, command, etc.) and is
/// categorized by message type identifiers (e.g., "01" for text, "88" for command).
abstract interface class ContentHelper {

  void setContentFactory(String msgType, ContentFactory factory);
  ContentFactory? getContentFactory(String msgType);

  /// Parses raw content data into a strongly-typed [Content] instance.
  ///
  /// Converts arbitrary raw content data (e.g., map, JSON string) into a valid
  /// Content object based on the registered factories for the message type.
  ///
  /// @param content - Raw content data to parse
  ///
  /// @return Parsed Content instance (null if parsing fails or no factory exists)
  Content? parseContent(Object? content);

}

/// Helper interface for message envelope management.
///
/// Manages envelope factories and provides core functionality for:
/// - Creating message envelopes (header metadata)
/// - Parsing raw envelope data into strongly-typed [Envelope] instances
///
/// Envelopes contain the core routing metadata of a message: sender ID, receiver ID,
/// and timestamp (when the message was sent).
abstract interface class EnvelopeHelper {

  void setEnvelopeFactory(EnvelopeFactory factory);
  EnvelopeFactory? getEnvelopeFactory();

  /// Creates a custom message envelope with specified routing metadata.
  ///
  /// Builds an Envelope from explicit sender/receiver/timestamp parameters,
  /// forming the header of a message (routing information).
  ///
  /// @param sender - Mandatory ID of the message sender
  ///
  /// @param receiver - Mandatory ID of the message receiver (user/group)
  ///
  /// @param time - Optional timestamp (defaults to current time if null)
  ///
  /// @return Custom Envelope instance with routing metadata
  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time});

  /// Parses raw envelope data into a strongly-typed [Envelope] instance.
  ///
  /// Converts arbitrary raw envelope data (e.g., map, JSON string) into a valid
  /// Envelope object for consistent message routing.
  ///
  /// @param env - Raw envelope data to parse
  ///
  /// @return Parsed Envelope instance (null if parsing fails)
  Envelope? parseEnvelope(Object? env);

}

/// Helper interface for instant message management.
///
/// Manages instant message factories and provides core functionality for:
/// - Creating instant messages (envelope + content)
/// - Parsing raw instant message data into strongly-typed [InstantMessage] instances
/// - Generating unique serial numbers (SN) for message identification
///
/// InstantMessage represents the basic, unencrypted message structure (envelope + content)
/// before security processing (encryption/signing).
abstract interface class InstantMessageHelper {

  void setInstantMessageFactory(InstantMessageFactory factory);
  InstantMessageFactory? getInstantMessageFactory();

  /// Creates an instant message from envelope (header) and content (body).
  ///
  /// Combines routing metadata (envelope) with message payload (content) to form
  /// a complete, unencrypted instant message.
  ///
  /// @param head - Message envelope (routing metadata: sender/receiver/time)
  ///
  /// @param body - Message content (payload: text, file, command, etc.)
  ///
  /// @return Complete InstantMessage instance
  InstantMessage createInstantMessage(Envelope head, Content body);

  /// Parses raw instant message data into a strongly-typed [InstantMessage] instance.
  ///
  /// Converts arbitrary raw instant message data (e.g., map, JSON string) into a valid
  /// InstantMessage object for consistent message processing.
  ///
  /// @param msg - Raw instant message data to parse
  ///
  /// @return Parsed InstantMessage instance (null if parsing fails)
  InstantMessage? parseInstantMessage(Object? msg);

  /// Generates a unique serial number (SN) for message identification.
  ///
  /// Creates a cryptographically unique or time-based serial number to uniquely
  /// identify a message (used for tracking, deduplication, and receipts).
  ///
  /// @param msgType - Optional message type identifier (for type-specific SN generation)
  ///
  /// @param now - Optional timestamp (defaults to current time if null)
  ///
  /// @return Unique serial number for the message
  int generateSerialNumber(String? msgType, DateTime? now);

}

/// Helper interface for secure message management.
///
/// Manages secure message factories and provides core functionality for:
/// - Parsing raw secure message data into strongly-typed [SecureMessage] instances
///
/// SecureMessage represents an encrypted message (InstantMessage after encryption)
/// that protects the content from unauthorized access.
abstract interface class SecureMessageHelper {

  void setSecureMessageFactory(SecureMessageFactory factory);
  SecureMessageFactory? getSecureMessageFactory();

  /// Parses raw secure message data into a strongly-typed [SecureMessage] instance.
  ///
  /// Converts arbitrary raw secure message data (e.g., map, JSON string) into a valid
  /// SecureMessage object for decryption and processing.
  ///
  /// @param msg - Raw secure message data to parse
  ///
  /// @return Parsed SecureMessage instance (null if parsing fails)
  SecureMessage? parseSecureMessage(Object? msg);

}

/// Helper interface for reliable message management.
///
/// Manages reliable message factories and provides core functionality for:
/// - Parsing raw reliable message data into strongly-typed [ReliableMessage] instances
///
/// ReliableMessage represents a signed secure message (SecureMessage after signing)
/// that ensures message integrity and authenticity (non-repudiation).
abstract interface class ReliableMessageHelper {

  void setReliableMessageFactory(ReliableMessageFactory factory);
  ReliableMessageFactory? getReliableMessageFactory();

  /// Parses raw reliable message data into a strongly-typed [ReliableMessage] instance.
  ///
  /// Converts arbitrary raw reliable message data (e.g., map, JSON string) into a valid
  /// a valid ReliableMessage object for signature verification and decryption.
  ///
  /// @param msg - Raw reliable message data to parse
  ///
  /// @return Parsed ReliableMessage instance (null if parsing fails)
  ReliableMessage? parseReliableMessage(Object? msg);

}

// -----------------------------------------------------------------------------
//  Message Extension Manager
// -----------------------------------------------------------------------------

/// Core extension manager for message system operations.
///
/// Singleton class that centralizes access to message-related helpers (Content/Envelope/InstantMessage etc.)
/// using Dart extensions for clean, modular access across the application.
///
/// Acts as a factory manager for all message components, ensuring consistent
/// creation/parsing of message objects throughout the system.
final sharedMessageExtensions = MessageExtensions();

/// Singleton extension class for message system operations.
///
/// Provides a unified entry point for accessing all message-related helpers,
/// ensuring consistent management of message components (Content/Envelope/InstantMessage etc.).
class MessageExtensions {
  factory MessageExtensions() => _instance;
  static final MessageExtensions _instance = MessageExtensions._internal();
  MessageExtensions._internal();

  //...
}

/// Content extension
ContentHelper? _contentHelper;

extension ContentExtension on MessageExtensions {

  ContentHelper? get contentHelper => _contentHelper;
  set contentHelper(ContentHelper? ext) => _contentHelper = ext;

}

/// Envelope extension
EnvelopeHelper? _envelopeHelper;

extension EnvelopeExtension on MessageExtensions {

  EnvelopeHelper? get envelopeHelper => _envelopeHelper;
  set envelopeHelper(EnvelopeHelper? ext) => _envelopeHelper = ext;

}

/// InstantMessage extension
InstantMessageHelper? _instantHelper;

extension InstantMessageExtension on MessageExtensions {

  InstantMessageHelper? get instantHelper => _instantHelper;
  set instantHelper(InstantMessageHelper? ext) => _instantHelper = ext;

}

/// SecureMessage extension
SecureMessageHelper? _secureHelper;

extension SecureMessageExtension on MessageExtensions {

  SecureMessageHelper? get secureHelper => _secureHelper;
  set secureHelper(SecureMessageHelper? ext) => _secureHelper = ext;

}

/// ReliableMessage extension
ReliableMessageHelper? _reliableHelper;

extension ReliableMessageExtension on MessageExtensions {

  ReliableMessageHelper? get reliableHelper => _reliableHelper;
  set reliableHelper(ReliableMessageHelper? ext) => _reliableHelper = ext;

}
