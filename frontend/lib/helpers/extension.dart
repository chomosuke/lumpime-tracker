import 'package:flutter/widgets.dart';

extension WidgetExtension on Widget {
  Widget noScrollBar(BuildContext context) => ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: this,
      );

  Widget sizedOverflow({
    Key? key,
    required Size size,
    AlignmentGeometry alignment = Alignment.center,
  }) =>
      SizedOverflowBox(size: size, key: key, alignment: alignment, child: this);
}
