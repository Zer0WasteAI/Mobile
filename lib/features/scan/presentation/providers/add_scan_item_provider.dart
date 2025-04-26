import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  Future<void> pickImages(ImageSource source) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      if (source == ImageSource.gallery) {
        // Pick multiple images from gallery
        final List<XFile> pickedFiles = await _picker.pickMultipleMedia();
        if (pickedFiles.isNotEmpty) {
          final newFiles = pickedFiles.map((file) => File(file.path)).toList();
          // Replace the list with the new selection from gallery
          state = state.copyWith(selectedImages: newFiles, isLoading: false);
          print('Picked ${newFiles.length} images from gallery.');
        } else {
          state = state.copyWith(isLoading: false);
          print('Gallery image picking cancelled or no images selected.');
        }
      } else if (source == ImageSource.camera) {
        // Pick single image from camera
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          final newFile = File(pickedFile.path);
          // Add the new camera image to the existing list
          state = state.copyWith(
            selectedImages: [...state.selectedImages, newFile],
            isLoading: false,
          );
          print('Added image from camera: ${pickedFile.path}');
        } else {
          state = state.copyWith(isLoading: false);
          print('Camera image picking cancelled.');
        }
      }
    } catch (e) {
      print('Error picking images: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to pick images: $e',
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

// Provider definition (no change needed here)
final addScanItemControllerProvider =
    StateNotifierProvider<AddScanItemController, AddScanItemState>((ref) {
      return AddScanItemController();
    });
