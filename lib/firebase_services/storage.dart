import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

// Function to get img url

getImgURL({
  required String imgName,
  required String folderName,
  required Uint8List imgPath,
}) async {
  try {
    // Validate inputs
    if (imgName.isEmpty || folderName.isEmpty || imgPath.length == 0) {
      throw Exception("Invalid image data");
    }

    print("Uploading image: $imgName, size: ${imgPath.length} bytes");

    // Upload image to firebase storage
    final storageRef = FirebaseStorage.instance.ref("$folderName/$imgName");
    
    // Determine content type based on file extension
    String contentType = 'image/jpeg'; // default
    if (imgName.toLowerCase().endsWith('.png')) {
      contentType = 'image/png';
    } else if (imgName.toLowerCase().endsWith('.gif')) {
      contentType = 'image/gif';
    } else if (imgName.toLowerCase().endsWith('.webp')) {
      contentType = 'image/webp';
    }
    
    print("Uploading with content type: $contentType");
    
    // Create upload task with metadata
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'picked-file-path': imgName},
    );
    
    UploadTask uploadTask = storageRef.putData(imgPath, metadata);
    
    // Add progress listener for better user feedback
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      if (snapshot.totalBytes > 0) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        print("Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
      }
    });
    
    // Wait for upload to complete
    TaskSnapshot snap = await uploadTask;
    print("Upload completed, bytes transferred: ${snap.bytesTransferred}");

    // Get download URL
    String urll = await snap.ref.getDownloadURL();
    print("Upload successful, URL: $urll");

    return urll;
  } catch (e) {
    print("Error uploading image: $e");
    if (e.toString().contains('permission-denied')) {
      throw Exception("Permission denied. Please check your Firebase Storage rules.");
    } else if (e.toString().contains('unauthenticated')) {
      throw Exception("User not authenticated. Please sign in again.");
    } else {
      throw Exception("Failed to upload image: $e");
    }
  }
}