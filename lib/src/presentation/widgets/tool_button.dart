import 'package:flutter/material.dart';
import 'package:stories_editor/src/presentation/widgets/animated_onTap_button.dart';

class ToolButton extends StatelessWidget {
  final Function() onTap;
  final Widget icon;
  final Color? backGroundColor;
  final EdgeInsets? padding;
  final Function()? onLongPress;
  final Color colorBorder;
  const ToolButton(
      {Key? key,
      required this.onTap,
      required this.icon,
      this.backGroundColor,
      this.padding,
      this.onLongPress,
      this.colorBorder = Colors.transparent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOnTapButton(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(0),
        child: Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colorBorder, width: 2)
          ),
          child: icon,
        ), /* Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
              color: backGroundColor ?? Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: colorBorder, width: 2)),
          child: Transform.scale(
            scale: 0.8,
            child: child,
          ),
        ), */
      ),
    );
  }
}
