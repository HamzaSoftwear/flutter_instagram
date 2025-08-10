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
    
    // Add metadata for better compatibility
    final metadata = SettableMetadata(
      contentType: contentType,
      customMetadata: {'picked-file-path': imgName},
    );
    
    print("Uploading with content type: $contentType");
    
    // Try without metadata first (simpler approach)
    UploadTask uploadTask;
    try {
      uploadTask = storageRef.putData(imgPath, metadata);
    } catch (e) {
      print("Failed with metadata, trying without: $e");
      uploadTask = storageRef.putData(imgPath);
    }
    
    // Add progress listener for better user feedback
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      print("Upload progress: ${(progress * 100).toStringAsFixed(1)}%");
    });
    
    TaskSnapshot snap = await uploadTask;

    // Get img url
    String urll = await snap.ref.getDownloadURL();
    print("Upload successful, URL: $urll");

    return urll;
  } catch (e) {
    print("Error uploading image: $e");
    throw Exception("Failed to upload image: $e");
  }
}