import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/notifiers/control_provider.dart';
import '../../domain/providers/notifiers/draggable_widget_notifier.dart';
import '../../domain/providers/notifiers/scroll_notifier.dart';
import '../../domain/sevices/save_as_image.dart';

class BottomTools extends StatelessWidget {
  final GlobalKey contentKey;
  final Function(String imageUri) onDone;
  final Function(String imageUri) onShareButtonClick;
  final Widget? onDoneButtonStyle;
  final Widget? postInStoryButtonWidget;

  /// editor background color
  final Color? editorBackgroundColor;
  const BottomTools({
    Key? key,
    required this.contentKey,
    required this.onDone,
    required this.onShareButtonClick,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.postInStoryButtonWidget,
  }) : super(key: key);

  final primaryColor = const Color(0xff8CBCCB);

  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier, __) {
        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 40.h),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _bottomToolButton(
                    removeWidth: true,
                    child: postInStoryButtonWidget ??
                        Text(
                          "In Story posten",
                          style: TextStyle(
                            color: primaryColor,
                          ),
                        ),
                    onTap: () async {
                      String pngUri;
                      await takePicture(
                              contentKey: contentKey,
                              context: context,
                              saveToGallery: false)
                          .then(
                        (bytes) {
                          if (bytes != null) {
                            pngUri = bytes;
                            onDone(pngUri);
                          } else {}
                        },
                      );
                    },
                  ),
                ),

                _bottomToolButton(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    Icons.share,
                    color: primaryColor,
                  ),
                  onTap: () async {
                    String pngUri;
                    await takePicture(
                            contentKey: contentKey,
                            context: context,
                            saveToGallery: false)
                        .then(
                      (bytes) {
                        if (bytes != null) {
                          pngUri = bytes;
                          onShareButtonClick(pngUri);
                        } else {}
                      },
                    );
                  },
                ),
                _bottomToolButton(
                  child: const Icon(Icons.download),
                  onTap: () async {
                    if (itemNotifier.draggableWidget.isNotEmpty) {
                      var response = await takePicture(
                        contentKey: contentKey,
                        context: context,
                        saveToGallery: true,
                      );
                      if (response) {
                        // TODO put it in a customizable variable
                        Fluttertoast.showToast(msg: 'Successfully saved');
                      } else {
                        // TODO put it in a customizable variable
                        Fluttertoast.showToast(msg: 'Error');
                      }
                    }
                  },
                ),

                /// preview gallery
                /* Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      child: _preViewContainer(
                        /// if [model.imagePath] is null/empty return preview image
                        child: controlNotifier.mediaPath.isEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: GestureDetector(
                                  onTap: () {
                                    /// scroll to gridView page
                                    if (controlNotifier.mediaPath.isEmpty) {
                                      scrollNotifier.pageController
                                          .animateToPage(1,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.ease);
                                    }
                                  },
                                  child: const CoverThumbnail(
                                    thumbnailQuality: 150,
                                  ),
                                ))

                            /// return clear [imagePath] provider
                            : GestureDetector(
                                onTap: () {
                                  /// clear image url variable
                                  controlNotifier.mediaPath = '';
                                  if (itemNotifier.draggableWidget.isNotEmpty) {
                                    itemNotifier.draggableWidget.removeAt(0);
                                  }
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  color: Colors.transparent,
                                  child: Transform.scale(
                                    scale: 0.7,
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ), */

                /// center logo
                /* if (controlNotifier.middleBottomWidget != null)
                  Expanded(
                    child: Center(
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: controlNotifier.middleBottomWidget),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/instagram_logo.png',
                            package: 'stories_editor',
                            color: Colors.white,
                            height: 42,
                          ),
                          const Text(
                            'Stories Creator',
                            style: TextStyle(
                                color: Colors.white38,
                                letterSpacing: 1.5,
                                fontSize: 9.2,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ), */

                /// save final image to gallery
                /* Expanded(
                  child: Container(
                    alignment: Alignment.centerRight,
                    child: Transform.scale(
                      scale: 0.9,
                      child: AnimatedOnTapButton(
                        onTap: () async {
                          String pngUri;
                          await takePicture(
                                  contentKey: contentKey,
                                  context: context,
                                  saveToGallery: false)
                              .then((bytes) {
                            if (bytes != null) {
                              pngUri = bytes;
                              onDone(pngUri);
                            } else {}
                          });
                        },
                        child: onDoneButtonStyle ??
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 5, top: 4, bottom: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5)),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Share',
                                    style: TextStyle(
                                        color: Colors.white,
                                        letterSpacing: 1.5,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 5),
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ),
                    ),
                  ),
                ), */
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _preViewContainer({child}) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.4, color: Colors.white)),
      child: child,
    );
  }

  Widget _bottomToolButton({
    required Widget child,
    required void Function() onTap,
    bool removeWidth = false,
    EdgeInsets padding = const EdgeInsets.all(0),
  }) {
    return Padding(
      padding: padding,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          height: 50,
          width: removeWidth ? null : 50,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
