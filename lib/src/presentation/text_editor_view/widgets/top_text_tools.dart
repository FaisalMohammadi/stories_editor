import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/widgets/tool_button.dart';

class TopTextTools extends StatelessWidget {
  final void Function() onDone;
  const TopTextTools({Key? key, required this.onDone}) : super(key: key);

  final Color primaryColor = const Color(0xff8CBCCB);

  @override
  Widget build(BuildContext context) {
    return Consumer<TextEditingNotifier>(
      builder: (context, editorNotifier, child) {
        return Container(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// font family / font color
                  ToolButton(
                    padding: const EdgeInsets.only(right: 10),
                    onTap: () {
                      editorNotifier.isFontFamily =
                          !editorNotifier.isFontFamily;
                      editorNotifier.isTextAnimation = false;
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) {
                          if (editorNotifier.fontFamilyController.hasClients) {
                            editorNotifier.fontFamilyController.animateToPage(
                                editorNotifier.fontFamilyIndex,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          }
                        },
                      );
                    },
                    icon: !editorNotifier.isFontFamily
                        ? ImageIcon(
                            const AssetImage('assets/icons/text.png',
                                package: 'stories_editor'),
                            color: primaryColor,
                          )
                        : Image.asset(
                            'assets/icons/circular_gradient.png',
                            package: 'stories_editor',
                          ),
                  ),

                  /// text align
                  ToolButton(
                    padding: const EdgeInsets.only(right: 10),
                    onTap: editorNotifier.onAlignmentChange,
                    icon: Icon(
                      editorNotifier.textAlign == TextAlign.center
                          ? Icons.format_align_center
                          : editorNotifier.textAlign == TextAlign.right
                              ? Icons.format_align_right
                              : Icons.format_align_left,
                      color: primaryColor,
                    ),
                  ),

                  /// background color
                  ToolButton(
                    padding: const EdgeInsets.only(right: 10),
                    onTap: editorNotifier.onBackGroundChange,
                    icon: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, bottom: 3),
                        child: ImageIcon(
                          const AssetImage('assets/icons/font_backGround.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  ToolButton(
                    padding: const EdgeInsets.only(right: 10),
                    onTap: () {
                      editorNotifier.isTextAnimation =
                          !editorNotifier.isTextAnimation;

                      /// animate to selected animation page
                      if (editorNotifier.isTextAnimation) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (editorNotifier
                              .textAnimationController.hasClients) {
                            editorNotifier.textAnimationController
                                .animateToPage(
                                    editorNotifier.fontAnimationIndex,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn);
                          }
                        });
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) {
                            if (editorNotifier
                                .fontFamilyController.hasClients) {
                              editorNotifier.fontFamilyController.animateToPage(
                                  editorNotifier.fontFamilyIndex,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn);
                            }
                          },
                        );
                      }
                    },
                    icon: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(0),
                        child: ImageIcon(
                          const AssetImage('assets/icons/video_trim.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  /// done button
                  ToolButton(
                    onTap: onDone,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    backGroundColor: Colors.black12,
                    icon: Transform.scale(
                      scale: 0.7,
                      child: ImageIcon(
                        const AssetImage('assets/icons/check.png',
                            package: 'stories_editor'),
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
