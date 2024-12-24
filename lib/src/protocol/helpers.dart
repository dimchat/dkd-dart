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
import 'package:mkm/mkm.dart';

import 'content.dart';
import 'envelope.dart';
import 'instant.dart';
import 'reliable.dart';
import 'secure.dart';

///  General Helpers
///  ~~~~~~~~~~~~~~~

abstract interface class ContentHelper {

  void setContentFactory(int msgType, ContentFactory factory);
  ContentFactory? getContentFactory(int msgType);

  Content? parseContent(Object? content);

}

abstract interface class EnvelopeHelper {

  void setEnvelopeFactory(EnvelopeFactory factory);
  EnvelopeFactory? getEnvelopeFactory();

  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time});

  Envelope? parseEnvelope(Object? env);

}

abstract interface class InstantMessageHelper {

  void setInstantMessageFactory(InstantMessageFactory factory);
  InstantMessageFactory? getInstantMessageFactory();

  InstantMessage createInstantMessage(Envelope head, Content body);

  InstantMessage? parseInstantMessage(Object? msg);

  int generateSerialNumber(int? msgType, DateTime? now);

}

abstract interface class SecureMessageHelper {

  void setSecureMessageFactory(SecureMessageFactory factory);
  SecureMessageFactory? getSecureMessageFactory();

  SecureMessage? parseSecureMessage(Object? msg);

}

abstract interface class ReliableMessageHelper {

  void setReliableMessageFactory(ReliableMessageFactory factory);
  ReliableMessageFactory? getReliableMessageFactory();

  ReliableMessage? parseReliableMessage(Object? msg);

}

/// Message FactoryManager
/// ~~~~~~~~~~~~~~~~~~~~~~
// protected
class MessageHolder {
  factory MessageHolder() => _instance;
  static final MessageHolder _instance = MessageHolder._internal();
  MessageHolder._internal();

  ContentHelper? contentHelper;
  EnvelopeHelper? envelopeHelper;

  InstantMessageHelper? instantHelper;
  SecureMessageHelper? secureHelper;
  ReliableMessageHelper? reliableHelper;

}
