import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageViewer extends StatefulWidget {
  final List<Map<String, String>> imgData; // List containing image URL & date

  const ImageViewer({Key? key, required this.imgData}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final uniqueImgData = widget.imgData.toSet().toList(); // Remove duplicates

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey[700],
        title: const Text(
          "Image Preview",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        shadowColor: Colors.black,
      ),
      body: Stack(
        children: [
          uniqueImgData.isEmpty
              ? const Center(child: Text('No images found'))
              : PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            pageController: _pageController,
            itemCount: uniqueImgData.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(uniqueImgData[index]['url']!),
                minScale: PhotoViewComputedScale.contained, // Normal Scale
                maxScale: PhotoViewComputedScale.covered * 2.5, // Zoom Level
                heroAttributes: PhotoViewHeroAttributes(tag: index), // Unique tag per image
              );
            },
            onPageChanged: (index) {
              setState(() {
                currentPage = index;
              });
            },
          ),

          // Date-Time on Top-Right
          if (uniqueImgData.isNotEmpty)
            Positioned(
              top: 10.0,
              right: 10.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  uniqueImgData[currentPage]['date']!,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),

          // Dots Indicator
          if (uniqueImgData.isNotEmpty)
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: DotsIndicator(
                dotsCount: uniqueImgData.length,
                position: currentPage.toDouble(),
                decorator: DotsDecorator(
                  size: const Size.square(8.0),
                  activeSize: const Size(20.0, 8.0),
                  activeShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
