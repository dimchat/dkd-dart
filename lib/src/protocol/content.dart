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

import '../factory.dart';

///  @enum DKDContentType
///
///  @abstract A flag to indicate what kind of message content this is.
///
///  @discussion A message is something send from one place to another one,
///      it can be an instant message, a system command, or something else.
///
///      DKDContentType_Text indicates this is a normal message with plaintext.
///
///      DKDContentType_File indicates this is a file, it may include filename
///      and file data, but usually the file data will encrypted and upload to
///      somewhere and here is just a URL to retrieve it.
///
///      DKDContentType_Image indicates this is an image, it may send the image
///      data directly(encrypt the image data with Base64), but we suggest to
///      include a URL for this image just like the 'File' message, of course
///      you can get a thumbnail of this image here.
///
///      DKDContentType_Audio indicates this is a voice message, you can get
///      a URL to retrieve the voice data just like the 'File' message.
///
///      DKDContentType_Video indicates this is a video file.
///
///      DKDContentType_Page indicates this is a web page.
///
///      DKDContentType_Quote indicates this message has quoted another message
///      and the message content should be a plaintext.
///
///      DKDContentType_Command indicates this is a command message.
///
///      DKDContentType_Forward indicates here contains a TOP-SECRET message
///      which needs your help to redirect it to the true receiver.
///
///  Bits:
///      0000 0001 - this message contains plaintext you can read.
///      0000 0010 - this is a message you can see.
///      0000 0100 - this is a message you can hear.
///      0000 1000 - this is a message for the bot, not for human.
///
///      0001 0000 - this message's main part is in somewhere else.
///      0010 0000 - this message contains the 3rd party content.
///      0100 0000 - this message contains digital assets
///      1000 0000 - this is a message send by the system, not human.
///
///      (All above are just some advices to help choosing numbers :P)
class ContentType {

  static const int kText    = (0x01); // 0000 0001

  static const int kFile    = (0x10); // 0001 0000
  static const int kImage   = (0x12); // 0001 0010
  static const int kAudio   = (0x14); // 0001 0100
  static const int kVideo   = (0x16); // 0001 0110

  /// Web Page
  static const int kPage    = (0x20); // 0010 0000

  /// Quote a message before and reply it with text
  static const int kQuote   = (0x37); // 0011 0111

  static const int kMoney         = (0x40); // 0100 0000
  static const int kTransfer      = (0x41); // 0100 0001
  static const int kLuckyMoney    = (0x42); // 0100 0010
  static const int kClaimPayment  = (0x48); // 0100 1000 (Claim for Payment)
  static const int kSplitBill     = (0x49); // 0100 1001 (Split the Bill)

  static const int kCommand = (0x88); // 1000 1000
  static const int kHistory = (0x89); // 1000 1001 (Entity History Command)

  /// Application Customized
  static const int kApplication      = (0xA0); // 1010 0000 (Application 0nly, Reserved)
  // static const int kApplication1  = (0xA1); // 1010 0001 (Reserved)
  // 1010 ???? (Reserved)
  // static const int kApplication15 = (0xAF); // 1010 1111 (Reserved)

  // static const int kCustomized0   = (0xC0); // 1100 0000 (Reserved)
  // static const int kCustomized1   = (0xC1); // 1100 0001 (Reserved)
  // 1100 ???? (Reserved)
  static const int kArray            = (0xCA); // 1100 1010 (Content Array)
  // 1100 ???? (Reserved)
  static const int kCustomized       = (0xCC); // 1100 1100 (Customized Content)
  // 1100 ???? (Reserved)
  // static const int kCustomized15  = (0xCF); // 1100 1111 (Reserved)

  /// Top-Secret message forward by proxy (MTA)
  static const int kForward = (0xFF); // 1111 1111

}


///  Message Content
///  ~~~~~~~~~~~~~~~
///  This class is for creating message content
///
///  data format: {
///      'type'    : 0x00,            // message type
///      'sn'      : 0,               // serial number
///
///      'group'   : 'Group ID',      // for group message
///
///      //-- message info
///      'text'    : 'text',          // for text message
///      'command' : 'Command Name',  // for system command
///      //...
///  }
abstract class Content implements Mapper {

  /// message type
  int get type;

  /// serial number as message id
  int get sn;

  /// message time
  DateTime? get time;

  /// Group ID/string for group message
  ///    if field 'group' exists, it means this is a group message
  ID? get group;
  set group(ID? identifier);

  //
  //  Factory method
  //

  static Content? parse(Object? content) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.parseContent(content);
  }

  static ContentFactory? getFactory(int msgType) {
    MessageFactoryManager man = MessageFactoryManager();
    return man.generalFactory.getContentFactory(msgType);
  }
  static void setFactory(int msgType, ContentFactory? factory) {
    MessageFactoryManager man = MessageFactoryManager();
    man.generalFactory.setContentFactory(msgType, factory);
  }
}

///  Content Factory
///  ~~~~~~~~~~~~~~~
abstract class ContentFactory {

  ///  Parse map object to content
  ///
  /// @param content - content info
  /// @return Content
  Content? parseContent(Map content);
}
