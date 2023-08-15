import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/notifiers/control_provider.dart';
import '../../domain/providers/notifiers/draggable_widget_notifier.dart';
import '../../domain/providers/notifiers/painting_notifier.dart';
import '../utils/modal_sheets.dart';
import '../widgets/tool_button.dart';
import 'tool_bar_item_widget.dart';

class TopTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  final bool? showSaveDraftOption;
  final Function(String draftPath)? saveDraftCallback;

  const TopTools({
    Key? key,
    required this.contentKey,
    required this.context,
    this.showSaveDraftOption,
    this.saveDraftCallback,
  }) : super(key: key);

  @override
  _TopToolsState createState() => _TopToolsState();
}

class _TopToolsState extends State<TopTools> {
  final Color primaryColor = const Color(0xff8CBCCB);
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, PaintingNotifier,
        DraggableWidgetNotifier>(
      builder: (_, controlNotifier, paintingNotifier, itemNotifier, __) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// close button
                ToolButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: primaryColor,
                  ),
                  backGroundColor: Colors.black12,
                  onTap: () async {
                    var res = await exitDialog(
                        context: widget.context,
                        contentKey: widget.contentKey,
                        showSaveDraftOption: widget.showSaveDraftOption,
                        saveDraftCallback: widget.saveDraftCallback);
                    if (res) {
                      Navigator.pop(context);
                    }
                  },
                ),

                Container(
                  width: 50,
                  padding: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ToolBarItemWidget(
                        icon: ImageIcon(
                          const AssetImage('assets/icons/text.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                          size: 20,
                        ),
                        onTap: () => controlNotifier.isTextEditing =
                            !controlNotifier.isTextEditing,
                      ),
                      /* _sideToolBarItem(
                        icon: ImageIcon(
                          const AssetImage('assets/icons/download.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                          size: 20,
                        ),
                        onTap: () async {
                          if (paintingNotifier.lines.isNotEmpty ||
                              itemNotifier.draggableWidget.isNotEmpty) {
                            var response = await takePicture(
                                contentKey: widget.contentKey,
                                context: context,
                                saveToGallery: true);
                            if (response) {
                              Fluttertoast.showToast(msg: 'Successfully saved');
                            } else {
                              Fluttertoast.showToast(msg: 'Error');
                            }
                          }
                        },
                      ), */
                      ToolBarItemWidget(
                        icon: ImageIcon(
                          const AssetImage('assets/icons/draw.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                          size: 20,
                        ),
                        onTap: () {
                          controlNotifier.isPainting = true;
                          //createLinePainting(context: context);
                        },
                      ),
                      ToolBarItemWidget(
                        icon: ImageIcon(
                          const AssetImage('assets/icons/stickers.png',
                              package: 'stories_editor'),
                          color: primaryColor,
                          size: 20,
                        ),
                        onTap: () => createGiphyItem(
                            context: context,
                            giphyKey: controlNotifier.giphyKey),
                      ),

                      // gradient color selector
                      if (controlNotifier.mediaPath.isEmpty)
                        controlNotifier.backgroundImage == false && controlNotifier.mediaPath.isEmpty
                            ? _selectColor(
                                controlProvider: controlNotifier,
                                onTap: () {
                                  if (controlNotifier.gradientIndex >=
                                      controlNotifier.gradientColors!.length -
                                          1) {
                                    setState(() {
                                      controlNotifier.gradientIndex = 0;
                                    });
                                  } else {
                                    setState(() {
                                      controlNotifier.gradientIndex += 1;
                                    });
                                  }
                                },
                              )
                            : const SizedBox.shrink(),
                      // ToolButton(
                      //   child: ImageIcon(
                      //     const AssetImage('assets/icons/photo_filter.png',
                      //         package: 'stories_editor'),
                      //     color: controlNotifier.isPhotoFilter ? Colors.black : Colors.white,
                      //     size: 20,
                      //   ),
                      //   backGroundColor:  controlNotifier.isPhotoFilter ? Colors.white70 : Colors.black12,
                      //   onTap: () => controlNotifier.isPhotoFilter =
                      //   !controlNotifier.isPhotoFilter,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// gradient color selector
  Widget _selectColor({onTap, controlProvider}) {
    return ToolBarItemWidget(
      shrinkPadding: true,
      onTap: onTap,
      icon: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: controlProvider
                  .gradientColors![controlProvider.gradientIndex]),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
