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
import 'package:mkm/format.dart';
import 'package:mkm/protocol.dart';
import 'package:mkm/type.dart';

import 'bundle.dart';

EncryptedBundleHandler _bundleHandler = DefaultBundleHandler();

extension BundleExtension on AccountExtensions {

  EncryptedBundleHandler get bundleHandler => _bundleHandler;
  set bundleHandler(EncryptedBundleHandler handler) => _bundleHandler = handler;

}

abstract interface class EncryptedBundleHandler {

  /// Encode key data
  ///
  /// @param bundle   - encrypted key data with targets (ID terminals)
  /// @param receiver - user ID
  /// @return encoded key data with targets (ID + terminals)
  Map<String, Object> encodeBundle(EncryptedBundle bundle, ID receiver);

  /// Decode key data from 'message.keys'
  ///
  /// @param encodedKeys - encoded key data with targets (ID + terminals)
  /// @param receiver    - user ID
  /// @param terminals   - visa terminals (null to decode all terminals)
  /// @return encrypted key data with targets (ID terminals)
  EncryptedBundle decodeBundle(Mapping encodedKeys, ID receiver, Iterable<String>? terminals);

}

class DefaultBundleHandler implements EncryptedBundleHandler {

  @override
  Map<String, Object> encodeBundle(EncryptedBundle bundle, ID receiver) {
    //
    //  0. ID string without terminal
    //
    assert(receiver.terminal == null, 'ID should not contain terminal here: $receiver');
    final String identifier = receiver.withoutTerminal().toString();
    final Map<String, Object> encodedKeys = {};
    String target;
    final Map<String, Uint8List> map = bundle.toMap();
    map.forEach((key, value) {
      target = key;
      //
      //  1. check target
      //
      if (target.isEmpty || target == '/') {
        // Naked ID
        target = identifier;
      } else if (target.startsWith('/')) {
        assert(false, 'entry error: $key -> $value');
        target = identifier + target;
      } else {
        // Dressed ID
        target = '$identifier/$target';
      }
      //
      //  2. encode data (base64)
      //
      final ted = TransportableData.create(value);
      assert(ted.isNotEmpty, 'failed to encode data: $value');
      //
      //  3. insert to 'message.keys' with ID + terminal
      //
      encodedKeys[target] = ted.serialize();
    });
    // OK
    return encodedKeys;
  }

  /// Decode bundle for all terminals of the receiver
  EncryptedBundle _decodeBundle(Mapping encodedKeys, ID receiver) {
    final bundle = UserEncryptedBundle();
    //
    //  0. ID string without terminal
    //
    final String identifier = receiver.withoutTerminal().toString();
    final String prefix = '$identifier/';
    final int begin = prefix.length;
    String target;
    for (final entry in encodedKeys.entries) {
      target = entry.key;
      final Object? base64 = entry.value;
      //
      //  1. check target
      //
      if (target == identifier) {
        // Naked ID
        target = '/';
      } else if (target.startsWith(prefix)) {
        // Dressed ID
        target = target.substring(begin);
      } else {
        // ID not matched, skip this item
        continue;
      }
      //
      //  2. decode data
      //
      final ted = TransportableData.parse(base64);
      final data = ted?.bytes;
      if (data == null) {
        assert(false, 'entry error: $entry');
        continue;
      }
      //
      //  3. put data for target (ID terminal)
      //
      assert(bundle[target] == null, 'duplicated terminal: $target, $encodedKeys');
      bundle[target] = data;
    }
    // OK
    return bundle;
  }

  @override
  EncryptedBundle decodeBundle(Mapping encodedKeys, ID receiver, Iterable<String>? terminals) {
    if (terminals == null) {
      // decode full bundle
      return _decodeBundle(encodedKeys, receiver);
    }
    final bundle = UserEncryptedBundle();
    //
    //  0. ID string without terminal
    //
    assert(receiver.terminal == null, 'ID should not contain terminal here: $receiver');
    final String identifier = receiver.withoutTerminal().toString();
    String target;
    for (final item in terminals) {
      //
      //  1. get encoded data with target (ID + terminal)
      //
      Object? base64;
      if (item.isEmpty || item == '/') {
        // Naked ID
        base64 = encodedKeys[identifier];
        target = '/';
      } else if (item.startsWith('/')) {
        assert(false, 'terminal error: $item');
        base64 = encodedKeys[identifier + item];
        target = item.substring(1);
      } else {
        // Dressed ID
        base64 = encodedKeys['$identifier/$item'];
        target = item;
      }
      if (base64 == null) {
        // key data not found
        continue;
      }
      //
      //  2. decode data
      //
      final ted = TransportableData.parse(base64);
      final data = ted?.bytes;
      if (data == null || data.isEmpty) {
        assert(false, 'key data error: $item -> $base64');
        continue;
      }
      //
      //  3. put data for target (ID terminal)
      //
      assert(bundle[target] == null, 'duplicated terminal: $item, $encodedKeys');
      bundle[target] = data;
    }
    // OK
    return bundle;
  }

}
