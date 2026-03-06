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

// -----------------------------------------------------------------------------
//  General Message Helper
// -----------------------------------------------------------------------------

/// General message helper interface for common message system utilities.
///
/// Combines utility methods for message component parsing (e.g., content type extraction)
/// and acts as a unified interface for core message helpers.
abstract interface class GeneralMessageHelper /*
    implements ContentHelper, EnvelopeHelper,
        InstantMessageHelper, SecureMessageHelper, ReliableMessageHelper */{

  //
  //  Message Type
  //

  /// Extracts the content type from a raw content map.
  ///
  /// Retrieves the message type identifier (e.g., "01" for text, "88" for command)
  /// from a raw content map with a fallback default value if the type field is missing.
  ///
  /// @param content - Raw content map containing type metadata
  ///
  /// @param defaultValue - Fallback value if type is not found
  ///
  /// @return Extracted content type (or defaultValue if not present)
  String? getContentType(Map content, [String? defaultValue]);

}

/// General Extensions
/// ~~~~~~~~~~~~~~~~~~

GeneralMessageHelper? _msgHelper;

extension GeneralMessageExtension on MessageExtensions {

  GeneralMessageHelper? get helper => _msgHelper;
  set helper(GeneralMessageHelper? ext) => _msgHelper = ext;

}
