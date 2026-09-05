/* license: https://mit-license.org
 *
 *  Dao-Ke-Dao: Universal Message Module
 *
 *                                Written in 2026 by Moky <albert.moky@gmail.com>
 *
 * ==============================================================================
 * The MIT License (MIT)
 *
 * Copyright (c) 2026 Albert Moky
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

import 'package:mkm/ext.dart';
import 'package:mkm/protocol.dart';
import 'package:mkm/type.dart';

import 'helpers.dart';


/// User Encrypted Key Data with Terminals
///
/// Represents a collection of encrypted symmetric keys (or other sensitive data)
/// mapped to user terminals (devices/sessions). Enables device-specific encryption
/// so that only the target user's specific terminals can decrypt the data.
abstract interface class EncryptedBundle {

  // terminal -> encrypted key.data
  Map<String, Uint8List> toMap();

  bool get isEmpty;
  bool get isNotEmpty;

  /// Get encrypted key data for terminal (index operator)
  ///
  /// @param terminal - ID terminal
  /// @return encrypted key data
  Uint8List? operator [](String terminal);

  /// Put encrypted key data for terminal (index assignment operator)
  ///
  /// @param terminal - ID terminal
  /// @param value    - encrypted key data (null removes the entry)
  void operator []=(String terminal, Uint8List? value);

  /// Remove encrypted key data for terminal
  ///
  /// @param terminal - ID terminal
  /// @return removed data
  Uint8List? remove(String terminal);

  /// Encode key data
  ///
  /// @param receiver - user ID
  /// @return encoded key data with targets (ID + terminals)
  Map<String, Object> encode(ID receiver);

  /// Decode key data from 'message.keys'
  ///
  /// @param encodedKeys - encoded key data with targets (ID + terminals)
  /// @param receiver    - user ID
  /// @param terminals   - visa terminals
  /// @return encrypted key data with targets (ID terminals)
  static EncryptedBundle decode(Mapping encodedKeys, ID receiver, [Iterable<String>? terminals]) {
    final helper = sharedAccountExtensions.bundleHandler;
    return helper.decodeBundle(encodedKeys, receiver, terminals);
  }

}


class UserEncryptedBundle implements EncryptedBundle {

  // terminal -> encrypted key.data
  final Map<String, Uint8List> _map = {};

  String get className {
    String name = 'UserEncryptedBundle';
    assert(() {
      name = runtimeType.toString();
      return true;
    }());
    return name;
  }

  @override
  String toString() {
    String clazz = className;
    String text = '';
    _map.forEach((key, value) {
      text += '\t"$key": ${value.length} byte(s)\n';
    });
    return '<$clazz count=${_map.length}>\n$text</$clazz>';
  }

  @override
  Map<String, Uint8List> toMap() => _map;

  @override
  bool get isEmpty => _map.isEmpty;

  @override
  bool get isNotEmpty => _map.isNotEmpty;

  @override
  Uint8List? operator [](String terminal) => _map[terminal];

  @override
  void operator []=(String terminal, Uint8List? value) {
    if (value == null) {
      _map.remove(terminal);
    } else {
      _map[terminal] = value;
    }
  }

  @override
  Uint8List? remove(String terminal) => _map.remove(terminal);

  @override
  Map<String, Object> encode(ID receiver) {
    final helper = sharedAccountExtensions.bundleHandler;
    return helper.encodeBundle(this, receiver);
  }

}
