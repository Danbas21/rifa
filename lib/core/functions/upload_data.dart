import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key});

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final String imageUrl =
      "https://firebasestorage.googleapis.com/v0/b/rifafunfai.appspot.com/o/images%2F_5d5d3fa2-2d03-46a4-af2b-c43b442b8ae6.jpeg?alt=media&token=df9ebcfc-1e0f-47ba-9042-19457e646fab";

  Future<String> getImageUrl() async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/_5d5d3fa2-2d03-46a4-af2b-c43b442b8ae6.jpeg');
      final url = await storageRef.getDownloadURL();
      return url;
    } catch (e) {
      print('Error getting image URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Image'),
      ),
      body: FutureBuilder<String>(
        future: getImageUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(
              child: Image.network(imageUrl),
            );
          }
        },
      ),
    );
  }
}
