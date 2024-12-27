# Dao Ke Dao (道可道) -- Message Module (Dart)

[![License](https://img.shields.io/github/license/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/blob/master/LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/dimchat/dkd-dart/pulls)
[![Platform](https://img.shields.io/badge/Platform-Dart%203-brightgreen.svg)](https://github.com/dimchat/dkd-dart/wiki)
[![Issues](https://img.shields.io/github/issues/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/issues)
[![Version](https://img.shields.io/github/tag/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/tags)
[![Repo Size](https://img.shields.io/github/repo-size/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/archive/refs/heads/main.zip)

[![Watchers](https://img.shields.io/github/watchers/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/watchers)
[![Forks](https://img.shields.io/github/forks/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/forks)
[![Stars](https://img.shields.io/github/stars/dimchat/dkd-dart)](https://github.com/dimchat/dkd-dart/stargazers)
[![Followers](https://img.shields.io/github/followers/dimchat)](https://github.com/orgs/dimchat/followers)

This [document](https://github.com/dimchat/DIMP/blob/master/DaoKeDao-Message.md) introduces a common **Message Module** for decentralized instant messaging.

Copyright &copy; 2023 Albert Moky

## Features

- [Envelope](#envelope)
    - Sender
    - Receiver
    - Time (same value from content.time)
- [Content](#content)
    - [Type](#content-type)
    - Serial Number
    - Time
    - Group _(Optional)_
- [Message](#message)
    - [Instant Message](#instant-message)
    - [Secure Message](#secure-message)
    - [Reliable Message](#reliable-message)

## Envelope

### Message Envelope

```javascript
/* example */
{
    "sender"   : "moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk",
    "receiver" : "hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj",
    "time"     : 1545405083
}
```

## Content

```javascript
/* example */
{
    "type"     : 0x01,      // message type
    "sn"       : 412968873, // serial number (message ID in conversation)
    
    "text"     : "Hey guy!"
}
```

### Content Type

```dart
class ContentType {

  static const int ANY     = (0x00); // 0000 0000 (Undefined)

  static const int TEXT    = (0x01); // 0000 0001

  static const int FILE    = (0x10); // 0001 0000
  static const int IMAGE   = (0x12); // 0001 0010
  static const int AUDIO   = (0x14); // 0001 0100
  static const int VIDEO   = (0x16); // 0001 0110

  /// Web Page
  static const int PAGE    = (0x20); // 0010 0000

  /// Name Card
  static const int NAME_CARD = (0x33); // 0011 0011

  /// Quote a message before and reply it with text
  static const int QUOTE     = (0x37); // 0011 0111

  /// Money
  static const int MONEY         = (0x40); // 0100 0000
  static const int TRANSFER      = (0x41); // 0100 0001
  static const int LUCKY_MONEY   = (0x42); // 0100 0010
  static const int CLAIM_PAYMENT = (0x48); // 0100 1000 (Claim for Payment)
  static const int SPLIT_BILL    = (0x49); // 0100 1001 (Split the Bill)

  /// Command
  static const int COMMAND = (0x88); // 1000 1000
  static const int HISTORY = (0x89); // 1000 1001 (Entity History Command)

  /// Application Customized
  static const int APPLICATION       = (0xA0); // 1010 0000 (Application 0nly, Reserved)
  // static const int APPLICATION_1  = (0xA1); // 1010 0001 (Reserved)
  // ...                                       // 1010 ???? (Reserved)
  // static const int APPLICATION_15 = (0xAF); // 1010 1111 (Reserved)

  // static const int CUSTOMIZED_0   = (0xC0); // 1100 0000 (Reserved)
  // static const int CUSTOMIZED_1   = (0xC1); // 1100 0001 (Reserved)
  // ...                                       // 1100 ???? (Reserved)
  static const int ARRAY             = (0xCA); // 1100 1010 (Content Array)
  // ...                                       // 1100 ???? (Reserved)
  static const int CUSTOMIZED        = (0xCC); // 1100 1100 (Customized Content)
  // ...                                       // 1100 ???? (Reserved)
  static const int COMBINE_FORWARD   = (0xCF); // 1100 1111 (Combine and Forward)

  /// Top-Secret message forward by proxy (MTA)
  static const int FORWARD = (0xFF); // 1111 1111

}
```

## Message

When the user want to send out a message, the client needs TWO steps before sending it:

1. Encrypt the ```Instant Message``` to ```Secure Message```;
2. Sign the ```Secure Message``` to ```Reliable Message```.

Accordingly, when the client received a message, it needs TWO steps to extract the content:

1. Verify the ```Reliable Message``` to ```Secure Message```;
2. Decrypt the ```Secure Message``` to ```Instant Message```.

```javascript
    Message Transforming
    ~~~~~~~~~~~~~~~~~~~~

    Instant Message  <-->  Secure Message  <-->  Reliable Message
    +-------------+        +------------+        +--------------+
    |  sender     |        |  sender    |        |  sender      |
    |  receiver   |        |  receiver  |        |  receiver    |
    |  time       |        |  time      |        |  time        |
    |             |        |            |        |              |
    |  content    |        |  data      |        |  data        |
    +-------------+        |  key/keys  |        |  key/keys    |
                           +------------+        |  signature   |
                                                 +--------------+
    Algorithm:
        data      = password.encrypt(content)
        key       = receiver.public_key.encrypt(password)
        signature = sender.private_key.sign(data)

```

### Instant Message

```javascript
/* example */
{
    //-------- head (envelope) --------
    "sender"   : "moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk",
    "receiver" : "hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj",
    "time"     : 1545405083,
    
    //-------- body (content) ---------
    "content"  : {
        "type" : 0x01,      // message type
        "sn"   : 412968873, // serial number (ID)
        "text" : "Hey guy!"
    }
}
```

content -> JsON string: ```{"sn":412968873,"text":"Hey guy!","type":1}```

### Secure Message

```javascript
/**
 *  Algorithm:
 *      string = json(content);
 *      PW     = random();
 *      data   = encrpyt(string, PW);      // Symmetric
 *      key    = encrypt(PW, receiver.PK); // Asymmetric
 */
{
    //-------- head (envelope) --------
    "sender"   : "moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk",
    "receiver" : "hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj",
    "time"     : 1545405083,
    
    //-------- body (content) ---------
    "data"     : "9cjCKG99ULCCxbL2mkc/MgF1saeRqJaCc+S12+HCqmsuF7TWK61EwTQWZSKskUeF",
    "key"      : "WH/wAcu+HfpaLq+vRblNnYufkyjTm4FgYyzW3wBDeRtXs1TeDmRxKVu7nQI/sdIALGLXrY+O5mlRfhU8f8TuIBilZUlX/eIUpL4uSDYKVLaRG9pOcrCHKevjUpId9x/8KBEiMIL5LB0Vo7sKrvrqosCnIgNfHbXMKvMzwcqZEU8="
}
```

### Reliable Message

```javascript
/**
 *  Algorithm:
 *      signature = sign(data, sender.SK);
 */
{
    //-------- head (envelope) --------
    "sender"   : "moki@4WDfe3zZ4T7opFSi3iDAKiuTnUHjxmXekk",
    "receiver" : "hulk@4YeVEN3aUnvC1DNUufCq1bs9zoBSJTzVEj",
    "time"     : 1545405083,
    
    //-------- body (content) ---------
    "data"      : "9cjCKG99ULCCxbL2mkc/MgF1saeRqJaCc+S12+HCqmsuF7TWK61EwTQWZSKskUeF",
    "key"       : "WH/wAcu+HfpaLq+vRblNnYufkyjTm4FgYyzW3wBDeRtXs1TeDmRxKVu7nQI/sdIALGLXrY+O5mlRfhU8f8TuIBilZUlX/eIUpL4uSDYKVLaRG9pOcrCHKevjUpId9x/8KBEiMIL5LB0Vo7sKrvrqosCnIgNfHbXMKvMzwcqZEU8=",
    "signature" : "Yo+hchWsQlWHtc8iMGS7jpn/i9pOLNq0E3dTNsx80QdBboTLeKoJYAg/lI+kZL+g7oWJYpD4qKemOwzI+9pxdMuZmPycG+0/VM3HVSMcguEOqOH9SElp/fYVnm4aSjAJk2vBpARzMT0aRNp/jTFLawmMDuIlgWhBfXvH7bT7rDI="
}
```

(All data encode with **BASE64** algorithm as default)
