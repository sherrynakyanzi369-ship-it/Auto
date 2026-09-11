import 'package:flutter/foundation.dart';

class AppEvents {
  AppEvents._();

  static final ValueNotifier<int> chatTick = ValueNotifier<int>(0);

  static void bumpChat() => chatTick.value++;
}