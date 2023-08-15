import 'package:flutter/material.dart';

import '../widgets/animated_onTap_button.dart';

class ToolBarItemWidget extends StatelessWidget {
  const ToolBarItemWidget({
    super.key,
    required this.icon,
    required this.onTap,
    this.shrinkPadding = false,
  });

  final Widget icon;
  final dynamic Function() onTap;
  final bool shrinkPadding;

  @override
  Widget build(BuildContext context) {
    return AnimatedOnTapButton(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        padding:
            shrinkPadding ? const EdgeInsets.all(4) : const EdgeInsets.all(8),
        margin: const EdgeInsets.only(top: 10, left: 5, right: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: icon,
      ),
    );
  }
}
