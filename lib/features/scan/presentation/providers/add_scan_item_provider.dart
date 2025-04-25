import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// State for the controller
class AddScanItemState {
  final File? selectedImage;
  final bool isLoading;
  final String? errorMessage;

  AddScanItemState({
    this.selectedImage,
    this.isLoading = false,
    this.errorMessage,
  });

  AddScanItemState copyWith({
    File? selectedImage,
    bool? isLoading,
    String? errorMessage,
    bool clearImage = false, // Flag to explicitly clear the image
    bool clearError = false, // Flag to explicitly clear the error
  }) {
    return AddScanItemState(
      selectedImage: clearImage ? null : selectedImage ?? this.selectedImage,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

// Controller (StateNotifier)
class AddScanItemController extends StateNotifier<AddScanItemState> {
  final ImagePicker _picker = ImagePicker();

  AddScanItemController() : super(AddScanItemState());

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile != null) {
        state = state.copyWith(
          selectedImage: File(pickedFile.path),
          isLoading: false,
        );
        // TODO: Handle the picked image (e.g., upload, process)
        print('Picked image path: ${pickedFile.path}');
      } else {
        // User cancelled the picker
        state = state.copyWith(isLoading: false);
        print('Image picking cancelled.');
      }
    } catch (e) {
      print('Error picking image: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to pick image: $e',
      );
      // Consider showing a user-friendly message
    }
  }

  // Optionally add a method to clear the selection
  void clearSelection() {
    state = state.copyWith(clearImage: true, clearError: true);
  }
}

// Provider definition
final addScanItemControllerProvider =
    StateNotifierProvider<AddScanItemController, AddScanItemState>((ref) {
      return AddScanItemController();
    });
