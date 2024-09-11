import 'package:flutter/material.dart';

import 'package:firebase_storage/firebase_storage.dart';

class ImageListScreen extends StatefulWidget {
  const ImageListScreen({super.key});

  @override
  ImageListScreenState createState() => ImageListScreenState();
}

class ImageListScreenState extends State<ImageListScreen> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  List<String> imageUrls = [];
  bool isLoading = true;
  bool useListAll = true; // Set to false for large directories

  @override
  void initState() {
    super.initState();
    loadImages();
  }

  Future<void> loadImages() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (useListAll) {
        await loadImagesWithListAll();
      } else {
        await loadImagesWithPagination();
      }
    } catch (e) {
      print('Error loading images: $e');
      print(loadImagesWithListAll().toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadImagesWithListAll() async {
    final storageRef = storage.ref().child("images2");
    final listResult = await storageRef.listAll();

    List<String> urls = [];
    for (var item in listResult.items) {
      String url = await item.getDownloadURL();

      urls.add(url);
    }

    setState(() {
      imageUrls = urls;
    });
  }

  Future<void> loadImagesWithPagination() async {
    final storageRef = storage.ref().child("images2");
    String? pageToken;
    List<String> urls = [];

    do {
      final listResult = await storageRef.list(ListOptions(
        maxResults: 5,
        pageToken: pageToken,
      ));

      for (var item in listResult.items) {
        String url = await item.getDownloadURL();
        urls.add(url);
      }

      setState(() {
        imageUrls = urls;
      });

      pageToken = listResult.nextPageToken;
    } while (pageToken != null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Storage Images'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : imageUrls.isEmpty
              ? const Center(child: Text('No images found'))
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error);
                      },
                    );
                  },
                ),
    );
  }
}
