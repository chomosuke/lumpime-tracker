import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tuple/tuple.dart';

double useHeaderHeight(
  ScrollController mainController,
  double maxHeight, [
  key,
]) {
  final previousOffset = useRef(0.0);
  final headerHeight = useState(maxHeight);
  useValueChanged<Tuple2<double, dynamic>, void>(
    Tuple2(maxHeight, key),
    (_, __) {
      headerHeight.value = maxHeight;
    },
  );
  useEffect(() {
    void listener() {
      headerHeight.value = min(
        maxHeight,
        max(
          0,
          headerHeight.value + previousOffset.value - mainController.offset,
        ),
      );
      previousOffset.value = mainController.offset;
    }

    mainController.addListener(listener);
    return () {
      mainController.removeListener(listener);
    };
  });
  return headerHeight.value;
}
