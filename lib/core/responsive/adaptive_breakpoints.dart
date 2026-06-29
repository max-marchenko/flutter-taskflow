import 'package:flutter/widgets.dart';

enum LayoutClass { compact, medium, expanded }

class AdaptiveBreakpoints {
  const AdaptiveBreakpoints._();

  static LayoutClass of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 700) return LayoutClass.compact;
    if (width < 1100) return LayoutClass.medium;
    return LayoutClass.expanded;
  }
}
