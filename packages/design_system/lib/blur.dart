import 'dart:ui';

class ScredexBlur {
  static ImageFilter get glass => ImageFilter.blur(sigmaX: 20, sigmaY: 20);
}
