import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:render/render.dart';

import '../../presentation/utils/constants/app_enums.dart';
import '../providers/notifiers/control_provider.dart';
import '../providers/notifiers/draggable_widget_notifier.dart';

Future<String> exportTheResultPath({
  required DraggableWidgetNotifier itemNotifier,
  required ControlNotifier controlNotifier,
  RenderController? renderController,
}) async {
  String filePath = "";

  /// it means their is just video so it can be exported directly
  if (itemNotifier.draggableWidget.length == 1) {
    filePath = controlNotifier.mediaPath;
  } else {
    final RenderResult result = await _exportRenderResult(
        controlNotifier, renderController, itemNotifier);
    filePath = result.output.path;
  }
  return filePath;
}

Future<RenderResult> _exportRenderResult(
  ControlNotifier controlNotifier,
  RenderController? renderController,
  DraggableWidgetNotifier itemNotifier,
) async {
  RenderResult result;
  Duration? videoDuration =
      controlNotifier.videoPlayerController?.value.duration;

  final fileExtension = path.extension(controlNotifier.mediaPath).toLowerCase();

  switch (fileExtension) {
    case ".mp4":
    case ".gif":
    case ".mov":
      if (controlNotifier.videoPlayerController != null) {
        controlNotifier.videoPlayerController!.seekTo(Duration.zero);
      }
      result = await renderController!.captureMotion(
        videoDuration ?? const Duration(seconds: 5),

        /// 5 seconds is for gifs
        logLevel: LogLevel.none,
        format: MovFormat(
          audio: [
            RenderAudio.file(
              File(controlNotifier.mediaPath),
            ),
          ],
        ),
      );
      break;
    case ".png":
    case ".jpeg":
    case ".jpg":
      final bool containesGif = itemNotifier.draggableWidget
          .any((editableItem) => editableItem.type == ItemType.gif);
      if (containesGif) {
        result = await renderController!.captureMotion(
          const Duration(seconds: 5),
          logLevel: LogLevel.none,
          format: MotionFormat.mp4,
        );
      } else {
        result = await renderController!.captureImage(
          logLevel: LogLevel.none,
          format: ImageFormat.jpg,
        );
      }

      break;
    default:
      throw Exception("unknown file type $fileExtension");
  }
  return result;
}
