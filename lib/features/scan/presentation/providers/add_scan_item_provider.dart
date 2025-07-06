import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart'; // Import Material for BuildContext
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter
import 'package:image_picker/image_picker.dart';
import 'package:zer0_waste_ai/features/scan/presentation/screens/add_scan_item_screen.dart'; // Import for ScanItemType

// State for the controller (updated)
class AddScanItemState {
  // Changed to a list of files
  final List<File> selectedImages;
  final bool isLoading;
  final String? errorMessage;

  AddScanItemState({
    // Initialize with an empty list
    this.selectedImages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AddScanItemState copyWith({
    // Accept a list of files
    List<File>? selectedImages,
    bool? isLoading,
    String? errorMessage,
    bool clearImages = false, // Flag to explicitly clear the image list
    bool clearError = false,
  }) {
    return AddScanItemState(
      // Use the provided list or the existing one; clear if flag is set
      selectedImages: clearImages ? [] : selectedImages ?? this.selectedImages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Controller (StateNotifier) (updated)
class AddScanItemController extends StateNotifier<AddScanItemState> {
  final ImagePicker _picker = ImagePicker();

  AddScanItemController() : super(AddScanItemState());

  // Updated to handle single (camera) or multiple (gallery) picks
  // Added BuildContext for navigation and ScanItemType for context
  Future<void> pickImages(
    ImageSource source,
    BuildContext context,
    ScanItemType originType, // Added originType
  ) async {
    // Check if context is still mounted before starting async operations
    if (!context.mounted) return;

    state = state.copyWith(isLoading: true, clearError: true);
    List<File> finalImageList = []; // Initialize empty
    bool imagesPickedSuccessfully = false;

    try {
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultipleMedia();
        if (pickedFiles.isNotEmpty && context.mounted) {
          final newFiles = pickedFiles.map((file) => File(file.path)).toList();
          // Gallery selection replaces the current list for confirmation
          finalImageList = newFiles;
          state = state.copyWith(
            selectedImages: finalImageList,
            isLoading: false,
          );
          imagesPickedSuccessfully = true;
          log('Picked ${newFiles.length} images from gallery.');
        } else {
          // No images picked or context became unmounted
          state = state.copyWith(isLoading: false);
          log('Gallery picking cancelled or no images selected.');
        }
      } else if (source == ImageSource.camera) {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null && context.mounted) {
          final newFile = File(pickedFile.path);
          // Camera adds to the list for confirmation
          finalImageList = [
            ...state.selectedImages,
            newFile,
          ]; // This line was modified in previous step, ensure state reflects update
          state = state.copyWith(
            selectedImages: finalImageList,
            isLoading: false,
          );
          imagesPickedSuccessfully = true;
          log('Added image from camera: ${pickedFile.path}');
        } else {
          // No image picked or context became unmounted
          state = state.copyWith(isLoading: false);
          log('Camera image picking cancelled.');
        }
      }
    } catch (e) {
      log('Error picking images: $e');
      if (context.mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to pick images: $e',
        );
      }
    } finally {
      // Ensure loading is stopped even if navigation fails or context is lost
      if (!imagesPickedSuccessfully && context.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }

    // Navigate only if images were successfully picked and context is still valid
    if (imagesPickedSuccessfully &&
        finalImageList.isNotEmpty &&
        context.mounted) {
      log(
        "Attempting navigation to /scan/confirm from $originType with ${finalImageList.length} images.",
      );
      // Pass both images and origin type in a Map
      context.go(
        '/scan/confirm',
        extra: {'images': finalImageList, 'originType': originType},
      );
    }
  }

  // Updated method to clear the list
  void clearSelection() {
    // Use the clearImages flag
    state = state.copyWith(clearImages: true, clearError: true);
  }

  // Add a method to remove a single image from the list
  void removeImage(File imageToRemove) {
    final updatedList =
        state.selectedImages
            .where((image) => image.path != imageToRemove.path)
            .toList();
    state = state.copyWith(selectedImages: updatedList);
  }
}

// Provider definition (updated with .autoDispose)
final addScanItemControllerProvider =
    StateNotifierProvider.autoDispose<AddScanItemController, AddScanItemState>((
      ref,
    ) {
      // Optional: Add cleanup logic if needed when the provider is disposed
      // ref.onDispose(() {
      //   print("Disposing AddScanItemController");
      // });
      return AddScanItemController();
    });
