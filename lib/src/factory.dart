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

import 'protocol/content.dart';
import 'protocol/envelope.dart';
import 'protocol/instant.dart';
import 'protocol/reliable.dart';
import 'protocol/secure.dart';

class MessageFactoryManager {
  factory MessageFactoryManager() => _instance;
  static final MessageFactoryManager _instance = MessageFactoryManager._internal();
  MessageFactoryManager._internal();

  MessageGeneralFactory generalFactory = MessageGeneralFactory();
}

class MessageGeneralFactory {

  final Map<int, ContentFactory> _contentFactories = {};

  EnvelopeFactory?        _envelopeFactory;
  InstantMessageFactory?  _instantMessageFactory;
  SecureMessageFactory?   _secureMessageFactory;
  ReliableMessageFactory? _reliableMessageFactory;

  //
  //  Content
  //

  void setContentFactory(int msgType, ContentFactory? factory) {
    if (factory == null) {
      _contentFactories.remove(msgType);
    } else {
      _contentFactories[msgType] = factory;
    }
  }
  ContentFactory? getContentFactory(int msgType) {
    return _contentFactories[msgType];
  }

  int getContentType(Map content) {
    return content['type'] ?? 0;
  }

  Content? parseContent(Object? content) {
    if (content == null) {
      return null;
    } else if (content is Content) {
      return content;
    }
    Map? info = Wrapper.getMap(content);
    if (info == null) {
      assert(false, 'content error: $content');
      return null;
    }
    // get factory by message type
    int msgType = getContentType(info);
    ContentFactory? factory = getContentFactory(msgType);
    if (factory == null) {
      factory = getContentFactory(0);  // unknown
      assert(factory != null, 'cannot parse content: $content');
    }
    return factory?.parseContent(info);
  }

  //
  //  Envelope
  //

  void setEnvelopeFactory(EnvelopeFactory? factory) {
    _envelopeFactory = factory;
  }
  EnvelopeFactory? getEnvelopeFactory() {
    return _envelopeFactory;
  }

  Envelope createEnvelope({required ID sender, required ID receiver, DateTime? time}) {
    EnvelopeFactory? factory = getEnvelopeFactory();
    assert(factory != null, 'envelope factory not ready');
    return factory!.createEnvelope(sender: sender, receiver: receiver, time: time);
  }

  Envelope? parseEnvelope(Object? env) {
    if (env == null) {
      return null;
    } else if (env is Envelope) {
      return env;
    }
    Map? info = Wrapper.getMap(env);
    if (info == null) {
      assert(false, 'envelope error: $env');
      return null;
    }
    EnvelopeFactory? factory = getEnvelopeFactory();
    assert(factory != null, 'envelope factory not ready');
    return factory?.parseEnvelope(info);
  }

  //
  //  InstantMessage
  //

  void setInstantMessageFactory(InstantMessageFactory? factory) {
    _instantMessageFactory = factory;
  }
  InstantMessageFactory? getInstantMessageFactory() {
    return _instantMessageFactory;
  }

  InstantMessage createInstantMessage(Envelope head, Content body) {
    InstantMessageFactory? factory = getInstantMessageFactory();
    assert(factory != null, 'instant message factory not ready');
    return factory!.createInstantMessage(head, body);
  }

  InstantMessage? parseInstantMessage(Object? msg) {
    if (msg == null) {
      return null;
    } else if (msg is InstantMessage) {
      return msg;
    }
    Map? info = Wrapper.getMap(msg);
    if (info == null) {
      assert(false, 'instant message error: $msg');
      return null;
    }
    InstantMessageFactory? factory = getInstantMessageFactory();
    assert(factory != null, 'instant message factory not ready');
    return factory?.parseInstantMessage(info);
  }

  int generateSerialNumber(int msgType, DateTime now) {
    InstantMessageFactory? factory = getInstantMessageFactory();
    assert(factory != null, 'instant message factory not ready');
    return factory == null ? 0 : factory.generateSerialNumber(msgType, now);
  }

  //
  //  SecureMessage
  //

  void setSecureMessageFactory(SecureMessageFactory? factory) {
    _secureMessageFactory = factory;
  }
  SecureMessageFactory? getSecureMessageFactory() {
    return _secureMessageFactory;
  }

  SecureMessage? parseSecureMessage(Object? msg) {
    if (msg == null) {
      return null;
    } else if (msg is SecureMessage) {
      return msg;
    }
    Map? info = Wrapper.getMap(msg);
    if (info == null) {
      assert(false, 'secure message error: $msg');
      return null;
    }
    SecureMessageFactory? factory = getSecureMessageFactory();
    assert(factory != null, 'instant message factory not ready');
    return factory?.parseSecureMessage(info);
  }

  //
  //  ReliableMessage
  //

  void setReliableMessageFactory(ReliableMessageFactory? factory) {
    _reliableMessageFactory = factory;
  }
  ReliableMessageFactory? getReliableMessageFactory() {
    return _reliableMessageFactory;
  }

  ReliableMessage? parseReliableMessage(Object? msg) {
    if (msg == null) {
      return null;
    } else if (msg is ReliableMessage) {
      return msg;
    }
    Map? info = Wrapper.getMap(msg);
    if (info == null) {
      assert(false, 'reliable message error: $msg');
      return null;
    }
    ReliableMessageFactory? factory = getReliableMessageFactory();
    assert(factory != null, 'instant message factory not ready');
    return factory?.parseReliableMessage(info);
  }
}
