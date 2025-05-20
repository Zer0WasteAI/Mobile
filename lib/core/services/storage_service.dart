import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the storage service
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(FirebaseStorage.instance);
});

/// Service for handling Firebase Storage operations
class StorageService {
  final FirebaseStorage _storage;

  /// Constructor
  StorageService(this._storage);

  /// Upload a profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Create a unique filename using the user ID and timestamp
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Create reference to the file location in Firebase Storage
      final storageRef = _storage.ref().child('profile_images').child(fileName);

      // Upload the file
      final uploadTask = storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType:
              'image/${path.extension(imageFile.path).replaceFirst('.', '')}',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  /// Delete a file from Firebase Storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      // Create a reference from the download URL
      final ref = _storage.refFromURL(downloadUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      throw Exception('Failed to delete file: ${e.toString()}');
    }
  }
}
