// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:stories_editor/src/domain/models/editable_items.dart';
import 'package:stories_editor/src/domain/models/painting_model.dart';
import 'package:stories_editor/src/domain/providers/notifiers/control_provider.dart';
import 'package:stories_editor/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:stories_editor/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:stories_editor/src/presentation/bar_tools/bottom_tools.dart';
import 'package:stories_editor/src/presentation/bar_tools/top_tools.dart';
import 'package:stories_editor/src/presentation/draggable_items/delete_item.dart';
import 'package:stories_editor/src/presentation/draggable_items/draggable_widget.dart';
import 'package:stories_editor/src/presentation/painting_view/painting.dart';
import 'package:stories_editor/src/presentation/painting_view/widgets/sketcher.dart';
import 'package:stories_editor/src/presentation/text_editor_view/TextEditor.dart';
import 'package:stories_editor/src/presentation/utils/constants/app_enums.dart';
import 'package:stories_editor/src/presentation/utils/modal_sheets.dart';
import 'package:stories_editor/src/presentation/widgets/scrollable_pageView.dart';
import 'package:render/render.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class MainView extends StatefulWidget {
  /// editor custom font families
  final List<String>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// on share
  final Function(String)? onShareButtonClick;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor background color
  Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  /// editor custom color palette list
  List<Color>? colorList;

  /// editor init file
  File? starterFile;

  final bool? showSaveDraftOption;
  final Function(String draftPath)? saveDraftCallback;
  ImageProvider<Object>? backgroundImage;
  final Widget? postInStoryButtonText;

  final Widget? middleText;

  MainView({
    Key? key,
    required this.giphyKey,
    required this.onDone,
    this.middleBottomWidget,
    this.colorList,
    this.isCustomFontList,
    this.fontFamilyList,
    this.gradientColors,
    this.onBackPress,
    this.onDoneButtonStyle,
    this.editorBackgroundColor,
    this.galleryThumbnailQuality,
    this.starterFile,
    this.showSaveDraftOption,
    this.saveDraftCallback,
    this.backgroundImage,
    this.postInStoryButtonText,
    this.onShareButtonClick,
    this.middleText,
  }) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  final renderController = RenderController();
  VideoPlayerController? videoPlayerController;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var _control = Provider.of<ControlNotifier>(context, listen: false);
      var _itemProvider =
          Provider.of<DraggableWidgetNotifier>(context, listen: false);

      // sets the background Image bool to true in state
      // in order to not show the color filter in editor page
      if (widget.backgroundImage != null) {
        _control.backgroundImage = true;
      } else {
        _control.backgroundImage = false;
      }

      /// initialize control variable provider
      _control.giphyKey = widget.giphyKey;
      _control.middleBottomWidget = widget.middleBottomWidget;
      _control.isCustomFontList = widget.isCustomFontList ?? false;

      if (widget.gradientColors != null) {
        _control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        _control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        _control.colorList = widget.colorList;
      }
      if (widget.starterFile != null) {
        _addImageOrVideoAsEditableItem(_control, _itemProvider);

        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreenUtil screenUtil = ScreenUtil();
    return WillPopScope(
      onWillPop: _popScope,
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent
            ? Colors.black
            : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer6<
            ControlNotifier,
            DraggableWidgetNotifier,
            ScrollNotifier,
            GradientNotifier,
            PaintingNotifier,
            TextEditingNotifier>(
          builder: (context, controlNotifier, itemProvider, scrollProvider,
              colorProvider, paintingProvider, editingProvider, child) {
            return SafeArea(
              //top: false,
              child: ScrollablePageView(
                  scrollPhysics: controlNotifier.mediaPath.isEmpty &&
                      itemProvider.draggableWidget.isEmpty &&
                      !controlNotifier.isPainting &&
                      !controlNotifier.isTextEditing,
                  pageController: scrollProvider.pageController,
                  gridController: scrollProvider.gridController,
                  mainView: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ///gradient container
                            /// this container will contain all widgets(image/texts/draws/sticker)
                            /// wrap this widget with coloredFilter
                            GestureDetector(
                              onScaleStart: _onScaleStart,
                              onScaleUpdate: _onScaleUpdate,
                              onTap: () {
                                controlNotifier.isTextEditing =
                                    !controlNotifier.isTextEditing;
                              },
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: SizedBox(
                                    width: screenUtil.screenWidth,
                                    child: Render(
                                      controller: renderController,
                                      key: contentKey,
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey[300],
                                          image: widget.backgroundImage != null
                                              ? DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image:
                                                      widget.backgroundImage!,
                                                )
                                              : null,
                                          gradient: widget.backgroundImage ==
                                                  null
                                              ? controlNotifier
                                                      .mediaPath.isEmpty
                                                  ? LinearGradient(
                                                      colors: controlNotifier
                                                              .gradientColors![
                                                          controlNotifier
                                                              .gradientIndex],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    )
                                                  : LinearGradient(
                                                      colors: [
                                                        colorProvider.color1,
                                                        colorProvider.color2
                                                      ],
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                    )
                                              : null,
                                        ),
                                        child: GestureDetector(
                                          onScaleStart: _onScaleStart,
                                          onScaleUpdate: _onScaleUpdate,
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              /// in this case photo view works as a main background container to manage
                                              /// the gestures of all movable items.
                                              PhotoView.customChild(
                                                childSize: Size.zero,
                                                child: Container(),
                                                backgroundDecoration:
                                                    const BoxDecoration(
                                                  color: Colors.transparent,
                                                ),
                                              ),

                                              ///list items
                                              ...itemProvider.draggableWidget
                                                  .map((editableItem) {
                                                return DraggableWidget(
                                                  context: context,
                                                  draggableWidget: editableItem,
                                                  onPointerDown: (details) {
                                                    _updateItemPosition(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                  onPointerUp: (details) {
                                                    _deleteItemOnCoordinates(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                  onPointerMove: (details) {
                                                    _deletePosition(
                                                      editableItem,
                                                      details,
                                                    );
                                                  },
                                                );
                                              }),

                                              /// finger paint
                                              IgnorePointer(
                                                ignoring: true,
                                                child: Align(
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    // repaint
                                                    child: RepaintBoundary(
                                                      child: SizedBox(
                                                        width: screenUtil
                                                            .screenWidth,
                                                        child: StreamBuilder<
                                                            List<
                                                                PaintingModel>>(
                                                          stream: paintingProvider
                                                              .linesStreamController
                                                              .stream,
                                                          builder: (context,
                                                              snapshot) {
                                                            return CustomPaint(
                                                              painter: Sketcher(
                                                                lines:
                                                                    paintingProvider
                                                                        .lines,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            /// middle text
                            if (itemProvider.draggableWidget.isEmpty &&
                                !controlNotifier.isTextEditing &&
                                paintingProvider.lines.isEmpty)
                              IgnorePointer(
                                ignoring: true,
                                child: Align(
                                  alignment: const Alignment(0, -0.1),
                                  child: widget.middleText ??
                                      Text(
                                        'Tap to type',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 30,
                                          color: Colors.white.withOpacity(0.8),
                                          shadows: <Shadow>[
                                            Shadow(
                                                offset: const Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black45
                                                    .withOpacity(0.3))
                                          ],
                                        ),
                                      ),
                                ),
                              ),

                            /// top tools
                            Visibility(
                              visible: !controlNotifier.isTextEditing &&
                                  !controlNotifier.isPainting,
                              child: Align(
                                  alignment: Alignment.topCenter,
                                  child: TopTools(
                                      contentKey: contentKey,
                                      context: context,
                                      showSaveDraftOption:
                                          widget.showSaveDraftOption,
                                      saveDraftCallback:
                                          widget.saveDraftCallback)),
                            ),

                            /// delete item when the item is in position
                            DeleteItem(
                              activeItem: _activeItem,
                              animationsDuration:
                                  const Duration(milliseconds: 300),
                              isDeletePosition: _isDeletePosition,
                            ),

                            /// show text editor
                            Visibility(
                              visible: controlNotifier.isTextEditing,
                              child: TextEditor(
                                context: context,
                              ),
                            ),

                            /// show painting sketch
                            Visibility(
                              visible: controlNotifier.isPainting,
                              child: const Painting(),
                            ),
                          ],
                        ),
                      ),

                      /// bottom tools
                      if (!kIsWeb)
                        BottomTools(
                          renderController: renderController,
                          contentKey: contentKey,
                          onDone: (bytes) {
                            setState(() {
                              widget.onDone!(bytes);
                            });
                          },
                          onShareButtonClick: (imageUri) {
                            setState(() {
                              widget.onShareButtonClick!(imageUri);
                            });
                          },
                          postInStoryButtonWidget: widget.postInStoryButtonText,
                          onDoneButtonStyle: widget.onDoneButtonStyle,
                          editorBackgroundColor: widget.editorBackgroundColor,
                        ),
                    ],
                  ),
                  gallery: SizedBox
                      .shrink() /* GalleryMediaPicker(
                  pathList: (List<PickedAssetModel> paths) {
                    controlNotifier.mediaPath = paths.first.path.toString();
                    if (controlNotifier.mediaPath.isNotEmpty) {
                      itemProvider.draggableWidget.insert(
                          0,
                          EditableItem()
                            ..type = ItemType.image
                            ..position = const Offset(0.0, 0));
                    }
                    scrollProvider.pageController.animateToPage(0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  },
                  mediaPickerParams: MediaPickerParamsModel(
                    gridViewController: scrollProvider.gridController,
                    thumbnailQuality: widget.galleryThumbnailQuality ?? 200,
                    singlePick: true,
                    onlyImages: true,
                    appBarColor: widget.editorBackgroundColor ?? Colors.black,
                    gridViewPhysics: itemProvider.draggableWidget.isEmpty
                        ? const NeverScrollableScrollPhysics()
                        : const ScrollPhysics(),
                    appBarLeadingWidget: Padding(
                      padding: const EdgeInsets.only(bottom: 15, right: 15),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: AnimatedOnTapButton(
                          onTap: () {
                            scrollProvider.pageController.animateToPage(0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.2,
                                )),
                            child: const Text(
                              'Abbrechen',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ), */
                  ),
            );
          },
        ),
      ),
    );
  }

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier =
        Provider.of<ControlNotifier>(context, listen: false);

    /// change to false text editing
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change to false painting
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      return widget.onBackPress ??
          exitDialog(
              context: context,
              contentKey: contentKey,
              showSaveDraftOption: widget.showSaveDraftOption,
              saveDraftCallback: widget.saveDraftCallback);
    }
    return false;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    final ScreenUtil screenUtil = ScreenUtil();
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / screenUtil.screenWidth) + _currentPos.dx;
    final top = (delta.dy / screenUtil.screenHeight) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// active delete widget with offset position
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    if (item.type == ItemType.text &&
        item.position.dy >= 0.75.h &&
        item.position.dx >= -0.4.w &&
        item.position.dx <= 0.2.w) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else if (item.type == ItemType.gif &&
        item.position.dy >= 0.62.h &&
        item.position.dx >= -0.35.w &&
        item.position.dx <= 0.15) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var _itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    _inAction = false;
    if (item.type == ItemType.image) {
    } else if (item.type == ItemType.text &&
            item.position.dy >= 0.75.h &&
            item.position.dx >= -0.4.w &&
            item.position.dx <= 0.2.w ||
        item.type == ItemType.gif &&
            item.position.dy >= 0.62.h &&
            item.position.dx >= -0.35.w &&
            item.position.dx <= 0.15) {
      setState(() {
        _itemProvider.removeAt(_itemProvider.indexOf(item));
        HapticFeedback.heavyImpact();
      });
    } else {
      setState(() {
        _activeItem = null;
      });
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }

    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }

  Future<File> _getFileFromPath(String filePath) async {
    // Get the application's documents directory
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    // Create a File object using the directory and file path
    File file = File('${appDocumentsDirectory.path}/$filePath');

    return file;
  }

  ItemType _getItemType(ControlNotifier controlNotifier) {
    final fileExtension =
        path.extension(controlNotifier.mediaPath).toLowerCase();

    ItemType itemType;

    switch (fileExtension) {
      case ".mp4":
      case ".gif":
      case ".mov":
        itemType = ItemType.video;
        break;
      case ".png":
      case ".jpeg":
      case ".jpg":
        itemType = ItemType.image;
        break;
      default:
        throw Exception("unknown file type $fileExtension");
    }
    return itemType;
  }

  _addImageOrVideoAsEditableItem(
    ControlNotifier control,
    DraggableWidgetNotifier itemProvider,
  ) {
    /* final GalleryMediaPickerController provider =
        GalleryMediaPickerController(); */

    /* control.mediaPath = provider.pathList.isNotEmpty
        ? provider.pathList[0].name
        : widget.starterFile!.path; */

    final fileExtension = path.extension(control.mediaPath).toLowerCase();

    switch (fileExtension) {
      case ".mp4":
      case ".gif":
      case ".mov":
        File file = File(control.mediaPath);
        control.videoPlayerController = VideoPlayerController.file(file);
        videoPlayerController = control.videoPlayerController;

        control.videoPlayerController!.addListener(() {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            setState(() {});
          });
        });
        control.videoPlayerController!.initialize();
        control.videoPlayerController!.setLooping(true);
        control.videoPlayerController!.play();
        itemProvider.draggableWidget.insert(
          0,
          EditableItem()
            ..type = ItemType.video
            ..position = const Offset(0.0, 0)
            ..scale = 1,
        );
        break;
      case ".png":
      case ".jpeg":
      case ".jpg":
        itemProvider.draggableWidget.insert(
            0,
            EditableItem()
              ..type = ItemType.image
              ..position = const Offset(0.0, 0)
              ..scale = 1.2);
        break;
      default:
        throw Exception("unknown file type $fileExtension");
    }
  }
}
