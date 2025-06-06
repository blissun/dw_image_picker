library dw_image_picker_android;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:dw_image_picker_platform_interface/dw_image_picker_platform_interface.dart';

export 'package:dw_image_picker_platform_interface/dw_image_picker_platform_interface.dart'
    show
        MediaType,
        DWPickerOptions,
        CameraType,
        DWCameraOptions,
        DWPickerItem,
        DWCropOptions,
        CropAspectRatio,
        CropAspectRatioPreset,
        CompressFormat,
        LocalizedImagePicker,
        LocalizedImageCropper,
        CroppingStyle,
        MaxSizeOutput;

/// An implementation of [DWImagePickerPlatform] that uses method channels.
class DWImagePickerAndroid extends DWImagePickerPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('dw_image_picker');

  static void registerWith() {
    DWImagePickerPlatform.instance = DWImagePickerAndroid();
  }

  /// Select images or videos from a library
  ///
  /// `selectedIds`: A list of string IDs representing the initially selected images or videos from the library. This allows users to pre-select items before opening the picker.
  ///
  /// `pickerOptions`: Additional options for the picker: `mediaType`, `maxSelectedAssets`, `maxFileSize`,...
  ///
  /// `cropping`: Indicating whether or not cropping is enabled. Just work when `mediaType = MediaType.image`
  ///
  /// `cropOptions`: Configuration options for the cropping functionality: `aspectRatio`, `aspectRatioPresets`, `compressQuality`, `compressFormat`
  ///
  /// `localized`: Custom text displayed for the plugin
  ///
  /// Returns a list of [DWPickerItem]
  @override
  Future<List<DWPickerItem>> openPicker({
    List<String>? selectedIds,
    DWPickerOptions? pickerOptions,
    bool? cropping,
    DWCropOptions? cropOptions,
    LocalizedImagePicker? localized,
  }) async {
    double? cropCompressQuality = cropOptions?.compressQuality;
    assert(cropCompressQuality == null ||
        (cropCompressQuality > 0 && cropCompressQuality <= 1));

    double? thumbnailCompressQuality = pickerOptions?.thumbnailCompressQuality;
    assert(thumbnailCompressQuality == null ||
        (thumbnailCompressQuality > 0 && thumbnailCompressQuality <= 1));

    int? pickerWidth = pickerOptions?.maxSizeOutput?.maxWidth;
    assert(pickerWidth == null || pickerWidth >= 10);

    int? pickerHeight = pickerOptions?.maxSizeOutput?.maxHeight;
    assert(pickerHeight == null || pickerHeight >= 10);

    int? cropWidth = cropOptions?.maxSizeOutput?.maxWidth;
    assert(cropWidth == null || cropWidth >= 10);

    int? cropHeight = cropOptions?.maxSizeOutput?.maxHeight;
    assert(cropHeight == null || cropHeight >= 10);

    const defaultPresets = [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ];

    final data = await methodChannel.invokeMethod('openPicker', {
      'mediaType': pickerOptions?.mediaType?.name,
      'maxSelectedAssets': pickerOptions?.maxSelectedAssets,
      'selectedIds': selectedIds,
      'maxFileSize': pickerOptions?.maxFileSize,
      'cropping': cropping,
      'isExportThumbnail': pickerOptions?.isExportThumbnail,
      'enablePreview': pickerOptions?.enablePreview,
      'ratioX': cropOptions?.aspectRatio?.ratioX,
      'ratioY': cropOptions?.aspectRatio?.ratioY,
      'aspectRatioPresets': (cropOptions?.aspectRatioPresets ?? defaultPresets)
          .map((e) => e.value)
          .toList(),
      'cropCompressQuality': cropOptions?.compressQuality,
      'cropCompressFormat': cropOptions?.compressFormat?.name,
      'croppingStyle': cropOptions?.croppingStyle?.name,
      'thumbnailCompressQuality': pickerOptions?.thumbnailCompressQuality,
      'thumbnailCompressFormat': pickerOptions?.thumbnailCompressFormat?.name,
      'maxDuration':
          pickerOptions?.maxDuration ?? pickerOptions?.recordVideoMaxSecond,
      'convertLivePhotosToJPG': pickerOptions?.convertLivePhotosToJPG,
      'convertHeicToJPG': pickerOptions?.convertHeicToJPG,
      'minSelectedAssets': pickerOptions?.minSelectedAssets,
      'minDuration': pickerOptions?.minDuration,
      'minFileSize': pickerOptions?.minFileSize,
      'numberOfColumn': pickerOptions?.numberOfColumn,
      'usedCameraButton': pickerOptions?.usedCameraButton,
      'cropMaxWidth': cropWidth,
      'cropMaxHeight': cropHeight,
      'isGif': pickerOptions?.isGif,
      'localized': localized?.toMap(),
      'maxWidth': pickerWidth,
      'maxHeight': pickerHeight,
      'compressQuality': pickerOptions?.compressQuality,
      'compressFormat': pickerOptions?.compressFormat?.name,
    });
    List<DWPickerItem> selectedItems = [];
    if (data != null) {
      selectedItems =
          (data as List).map((item) => DWPickerItem.fromMap(item)).toList();
    }
    return selectedItems;
  }

  /// Take a photo or record a video
  ///
  /// `cameraOptions`: Additional options for the camera functionality: `cameraType`, `recordVideoMaxSecond`, `isExportThumbnail`...
  ///
  /// `cropping`: Indicating whether or not cropping is enabled
  ///
  /// `cropOptions`: Configuration options for the cropping functionality: `aspectRatio`, `aspectRatioPresets`, `compressQuality`, `compressFormat`
  ///
  /// `localized`: Custom text displayed for the plugin
  ///
  /// Returns a [DWPickerItem] object
  @override
  Future<DWPickerItem> openCamera({
    DWCameraOptions? cameraOptions,
    bool? cropping,
    DWCropOptions? cropOptions,
    LocalizedImageCropper? localized,
  }) async {
    double? cropCompressQuality = cropOptions?.compressQuality;
    assert(cropCompressQuality == null ||
        (cropCompressQuality > 0 && cropCompressQuality <= 1));

    int? cameraWidth = cameraOptions?.maxSizeOutput?.maxWidth;
    assert(cameraWidth == null || cameraWidth >= 10);

    int? cameraHeight = cameraOptions?.maxSizeOutput?.maxHeight;
    assert(cameraHeight == null || cameraHeight >= 10);

    int? cropWidth = cropOptions?.maxSizeOutput?.maxWidth;
    assert(cropWidth == null || cropWidth >= 10);

    int? cropHeight = cropOptions?.maxSizeOutput?.maxHeight;
    assert(cropHeight == null || cropHeight >= 10);

    const defaultPresets = [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ];

    final data = await methodChannel.invokeMethod('openCamera', {
      'cameraType': cameraOptions?.cameraType?.name,
      'cropping': cropping,
      'ratioX': cropOptions?.aspectRatio?.ratioX,
      'ratioY': cropOptions?.aspectRatio?.ratioY,
      'aspectRatioPresets': (cropOptions?.aspectRatioPresets ?? defaultPresets)
          .map((e) => e.value)
          .toList(),
      'cropCompressQuality': cropOptions?.compressQuality,
      'cropCompressFormat': cropOptions?.compressFormat?.name,
      'recordVideoMaxSecond': cameraOptions?.recordVideoMaxSecond,
      'isExportThumbnail': cameraOptions?.isExportThumbnail,
      'thumbnailCompressQuality': cameraOptions?.thumbnailCompressQuality,
      'thumbnailCompressFormat': cameraOptions?.thumbnailCompressFormat?.name,
      'croppingStyle': cropOptions?.croppingStyle?.name,
      'cropMaxWidth': cropWidth,
      'cropMaxHeight': cropHeight,
      'localized': localized?.toMap(),
      'cameraCompressQuality': cameraOptions?.compressQuality,
      'cameraCompressFormat': cameraOptions?.compressFormat?.name,
      'cameraMaxWidth': cameraWidth,
      'cameraMaxHeight': cameraHeight,
    });
    return DWPickerItem.fromMap(data);
  }

  /// Open image cropper
  ///
  /// `imagePath`: Path of the image that needs to be cropped
  ///
  /// `cropOptions`: Configuration options for the cropping functionality: `aspectRatio`, `aspectRatioPresets`, `compressQuality`, `compressFormat`
  ///
  /// `localized`: Custom text displayed for the plugin
  ///
  /// Returns a [DWPickerItem] object
  @override
  Future<DWPickerItem> openCropper(
    String imagePath, {
    DWCropOptions? cropOptions,
    LocalizedImageCropper? localized,
  }) async {
    double? cropCompressQuality = cropOptions?.compressQuality;
    assert(cropCompressQuality == null ||
        (cropCompressQuality > 0 && cropCompressQuality <= 1));

    int? cropWidth = cropOptions?.maxSizeOutput?.maxWidth;
    assert(cropWidth == null || cropWidth >= 10);

    int? cropHeight = cropOptions?.maxSizeOutput?.maxHeight;
    assert(cropHeight == null || cropHeight >= 10);

    const defaultPresets = [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9
    ];
    final data = await methodChannel.invokeMethod('openCropper', {
      'imagePath': Uri.encodeFull(imagePath),
      'ratioX': cropOptions?.aspectRatio?.ratioX,
      'ratioY': cropOptions?.aspectRatio?.ratioY,
      'aspectRatioPresets': (cropOptions?.aspectRatioPresets ?? defaultPresets)
          .map((e) => e.value)
          .toList(),
      'cropCompressQuality': cropOptions?.compressQuality,
      'cropCompressFormat': cropOptions?.compressFormat?.name,
      'croppingStyle': cropOptions?.croppingStyle?.name,
      'cropMaxWidth': cropWidth,
      'cropMaxHeight': cropHeight,
      'localized': localized?.toMap(),
    });
    return DWPickerItem.fromMap(data);
  }
}
