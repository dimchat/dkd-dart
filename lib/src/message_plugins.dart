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
import 'protocol/helpers.dart';

/// Message GeneralFactory
/// ~~~~~~~~~~~~~~~~~~~~~~
abstract interface class GeneralMessageHelper /*
    implements ContentHelper, EnvelopeHelper,
        InstantMessageHelper, SecureMessageHelper, ReliableMessageHelper */{

  //
  //  Message Type
  //

  int? getContentType(Map content, int? defaultValue);

}

/// Message FactoryManager
/// ~~~~~~~~~~~~~~~~~~~~~~
class SharedMessageHolder {
  factory SharedMessageHolder() => _instance;
  static final SharedMessageHolder _instance = SharedMessageHolder._internal();
  SharedMessageHolder._internal();

  /// Content
  ContentHelper? get contentHelper =>
      MessageHolder().contentHelper;

  set contentHelper(ContentHelper? helper) =>
      MessageHolder().contentHelper = helper;

  /// Envelope
  EnvelopeHelper? get envelopeHelper =>
      MessageHolder().envelopeHelper;

  set envelopeHelper(EnvelopeHelper? helper) =>
      MessageHolder().envelopeHelper = helper;

  /// InstantMessage
  InstantMessageHelper? get instantHelper =>
      MessageHolder().instantHelper;

  set instantHelper(InstantMessageHelper? helper) =>
      MessageHolder().instantHelper = helper;

  /// SecureMessage
  SecureMessageHelper? get secureHelper =>
      MessageHolder().secureHelper;

  set secureHelper(SecureMessageHelper? helper) =>
      MessageHolder().secureHelper = helper;

  /// ReliableMessage
  ReliableMessageHelper? get reliableHelper =>
      MessageHolder().reliableHelper;

  set reliableHelper(ReliableMessageHelper? helper) =>
      MessageHolder().reliableHelper = helper;

  /// General Helper
  GeneralMessageHelper? helper;

}
