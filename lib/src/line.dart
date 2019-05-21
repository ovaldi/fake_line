import 'dart:async';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

class Line {
  static const String _METHOD_ISLINEINSTALLED = 'isLineInstalled';
  static const String _METHOD_SHARETEXT = 'shareText';
  static const String _METHOD_SHAREIMAGE = 'shareImage';

  static const String _ARGUMENT_KEY_TEXT = 'text';
  static const String _ARGUMENT_KEY_IMAGEURI = 'imageUri';

  static const String _SCHEME_FILE = 'file';

  final MethodChannel _channel =
      const MethodChannel('v7lin.github.io/fake_line');

  /// 检测Line是否已安装
  Future<bool> isLineInstalled() async {
    return (await _channel.invokeMethod(_METHOD_ISLINEINSTALLED)) as bool;
  }

  /// 分享 - 文本
  Future<void> shareText({
    @required String text,
  }) {
    return _channel.invokeMethod(
      _METHOD_SHARETEXT,
      <String, dynamic>{
        _ARGUMENT_KEY_TEXT: text,
      },
    );
  }

  /// 分享 - 图片
  Future<void> shareImage({
    @required Uri imageUri,
  }) {
    assert(imageUri != null && imageUri.isScheme(_SCHEME_FILE));
    return _channel.invokeMethod(
      _METHOD_SHAREIMAGE,
      <String, dynamic>{
        _ARGUMENT_KEY_IMAGEURI: imageUri.toString(),
      },
    );
  }
}
