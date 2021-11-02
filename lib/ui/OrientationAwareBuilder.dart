/// Based on [OrientationBuilder].

import 'package:flutter/widgets.dart';

typedef OrientationAwareWidgetBuilder = Widget Function(
    BuildContext context, Orientation orientation);

class OrientationAwareBuilder extends StatelessWidget {
  const OrientationAwareBuilder({
    Key? key,
    required this.builder,
  })  : assert(builder != null),
        super(key: key);

  final OrientationAwareWidgetBuilder builder;

  Widget _buildWithConstraints(
      BuildContext context, BoxConstraints constraints) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return builder(context, orientation);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: _buildWithConstraints);
  }
}
