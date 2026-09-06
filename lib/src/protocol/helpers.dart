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
import 'dart:typed_data';

import 'package:mkm/protocol.dart';

import '../dkd/bundle.dart';

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

  /// Set the content factory for a message type.
  ///
  /// [msgType] is the message type identifier.
  /// [factory] is the factory to be registered.
  void setContentFactory(String msgType, ContentFactory factory);

  /// Get the content factory for a message type.
  ///
  /// [msgType] is the message type identifier.
  ///
  /// Returns the registered factory for the type, or null if not registered.
  ContentFactory? getContentFactory(String msgType);

  /// Parses raw content data into a strongly-typed [Content] instance.
  ///
  /// Converts arbitrary raw content data (e.g., map, JSON string) into a valid
  /// Content object based on the registered factories for the message type.
  ///
  /// [content] is the raw content data to parse.
  ///
  /// Returns a parsed [Content] instance (null if parsing fails or no factory exists).
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

  /// Set the envelope factory.
  ///
  /// [factory] is the factory to be registered.
  void setEnvelopeFactory(EnvelopeFactory factory);

  /// Get the envelope factory.
  ///
  /// Returns the registered [EnvelopeFactory], or null if not registered.
  EnvelopeFactory? getEnvelopeFactory();

  /// Creates a custom message envelope with specified routing metadata.
  ///
  /// Builds an Envelope from explicit sender/receiver/timestamp parameters,
  /// forming the header of a message (routing information).
  ///
  /// [sender] is the ID of the message sender.
  /// [receiver] is the ID of the message receiver (user/group).
  /// [time] is the message timestamp (defaults to current time if null).
  ///
  /// Returns a custom [Envelope] instance with routing metadata.
  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time});

  /// Parses raw envelope data into a strongly-typed [Envelope] instance.
  ///
  /// Converts arbitrary raw envelope data (e.g., map, JSON string) into a valid
  /// Envelope object for consistent message routing.
  ///
  /// [env] is the raw envelope data to parse.
  ///
  /// Returns a parsed [Envelope] instance (null if parsing fails).
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

  /// Set the instant message factory.
  ///
  /// [factory] is the factory to be registered.
  void setInstantMessageFactory(InstantMessageFactory factory);

  /// Get the instant message factory.
  ///
  /// Returns the registered [InstantMessageFactory], or null if not registered.
  InstantMessageFactory? getInstantMessageFactory();

  /// Creates an instant message from envelope (header) and content (body).
  ///
  /// Combines routing metadata (envelope) with message payload (content) to form
  /// a complete, unencrypted instant message.
  ///
  /// [head] is the message envelope (routing metadata: sender/receiver/time).
  /// [body] is the message content (payload: text, file, command, etc.).
  ///
  /// Returns a complete [InstantMessage] instance.
  InstantMessage createInstantMessage(Envelope head, Content body);

  /// Parses raw instant message data into a strongly-typed [InstantMessage] instance.
  ///
  /// Converts arbitrary raw instant message data (e.g., map, JSON string) into a valid
  /// InstantMessage object for consistent message processing.
  ///
  /// [msg] is the raw instant message data to parse.
  ///
  /// Returns a parsed [InstantMessage] instance (null if parsing fails).
  InstantMessage? parseInstantMessage(Object? msg);

  /// Generates a unique serial number (SN) for message identification.
  ///
  /// Creates a cryptographically unique or time-based serial number to uniquely
  /// identify a message (used for tracking, deduplication, and receipts).
  ///
  /// [msgType] is the message type identifier (for type-specific SN generation).
  /// [now] is the timestamp (defaults to current time if null).
  ///
  /// Returns a unique serial number (uint64) for the message.
  int generateSerialNumber(String? msgType, DateTime? now);

}

/// Helper interface for secure message management.
///
/// Manages secure message factories and provides core functionality for:
/// - Creating secure messages (instant message + encrypted data + key bundles)
/// - Parsing raw secure message data into strongly-typed [SecureMessage] instances
///
/// SecureMessage represents an encrypted message (InstantMessage after encryption)
/// that protects the content from unauthorized access.
abstract interface class SecureMessageHelper {

  /// Set the secure message factory.
  ///
  /// [factory] is the factory to be registered.
  void setSecureMessageFactory(SecureMessageFactory factory);

  /// Get the secure message factory.
  ///
  /// Returns the registered [SecureMessageFactory], or null if not registered.
  SecureMessageFactory? getSecureMessageFactory();

  /// Creates a secure message from instant message, adding 'data' and 'keys'.
  ///
  /// Encrypts the plaintext content with a symmetric key, then encrypts the key
  /// for each receiver terminal, forming the encrypted data and key bundles.
  ///
  /// [iMsg] is the plain instant message.
  /// [ciphertext] is the encrypted data of the content.
  /// [keyBundles] is the encrypted key bundles for the receiver terminals.
  ///
  /// Returns a new [SecureMessage] instance.
  SecureMessage createSecureMessage(InstantMessage iMsg, Uint8List ciphertext, Map<ID, EncryptedBundle>? keyBundles);

  /// Parses raw secure message data into a strongly-typed [SecureMessage] instance.
  ///
  /// Converts arbitrary raw secure message data (e.g., map, JSON string) into a valid
  /// SecureMessage object for decryption and processing.
  ///
  /// [msg] is the raw secure message data to parse.
  ///
  /// Returns a parsed [SecureMessage] instance (null if parsing fails).
  SecureMessage? parseSecureMessage(Object? msg);

}

/// Helper interface for reliable message management.
///
/// Manages reliable message factories and provides core functionality for:
/// - Creating reliable messages (secure message + signature)
/// - Parsing raw reliable message data into strongly-typed [ReliableMessage] instances
///
/// ReliableMessage represents a signed secure message (SecureMessage after signing)
/// that ensures message integrity and authenticity (non-repudiation).
abstract interface class ReliableMessageHelper {

  /// Set the reliable message factory.
  ///
  /// [factory] is the factory to be registered.
  void setReliableMessageFactory(ReliableMessageFactory factory);

  /// Get the reliable message factory.
  ///
  /// Returns the registered [ReliableMessageFactory], or null if not registered.
  ReliableMessageFactory? getReliableMessageFactory();

  /// Creates a reliable message from secure message, adding 'signature'.
  ///
  /// Signs the encrypted content data with the sender's private key, forming
  /// the digital signature for authenticity and integrity verification.
  ///
  /// [sMsg] is the encrypted secure message.
  /// [signature] is the signature of the encrypted content data.
  ///
  /// Returns a new [ReliableMessage] instance.
  ReliableMessage createReliableMessage(SecureMessage sMsg, Uint8List signature);

  /// Parses raw reliable message data into a strongly-typed [ReliableMessage] instance.
  ///
  /// Converts arbitrary raw reliable message data (e.g., map, JSON string) into a valid
  /// ReliableMessage object for signature verification and decryption.
  ///
  /// [msg] is the raw reliable message data to parse.
  ///
  /// Returns a parsed [ReliableMessage] instance (null if parsing fails).
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
final class MessageExtensions {
  factory MessageExtensions() => _instance;
  static final MessageExtensions _instance = MessageExtensions._internal();
  MessageExtensions._internal();

  //...
}

/// Content extension
ContentHelper? _contentHelper;

extension ContentExtension on MessageExtensions {

  /// Get the content helper
  ContentHelper? get contentHelper => _contentHelper;

  /// Set the content helper
  set contentHelper(ContentHelper? ext) => _contentHelper = ext;

}

/// Envelope extension
EnvelopeHelper? _envelopeHelper;

extension EnvelopeExtension on MessageExtensions {

  /// Get the envelope helper
  EnvelopeHelper? get envelopeHelper => _envelopeHelper;

  /// Set the envelope helper
  set envelopeHelper(EnvelopeHelper? ext) => _envelopeHelper = ext;

}

/// InstantMessage extension
InstantMessageHelper? _instantHelper;

extension InstantMessageExtension on MessageExtensions {

  /// Get the instant message helper
  InstantMessageHelper? get instantHelper => _instantHelper;

  /// Set the instant message helper
  set instantHelper(InstantMessageHelper? ext) => _instantHelper = ext;

}

/// SecureMessage extension
SecureMessageHelper? _secureHelper;

extension SecureMessageExtension on MessageExtensions {

  /// Get the secure message helper
  SecureMessageHelper? get secureHelper => _secureHelper;

  /// Set the secure message helper
  set secureHelper(SecureMessageHelper? ext) => _secureHelper = ext;

}

/// ReliableMessage extension
ReliableMessageHelper? _reliableHelper;

extension ReliableMessageExtension on MessageExtensions {

  /// Get the reliable message helper
  ReliableMessageHelper? get reliableHelper => _reliableHelper;

  /// Set the reliable message helper
  set reliableHelper(ReliableMessageHelper? ext) => _reliableHelper = ext;

}
