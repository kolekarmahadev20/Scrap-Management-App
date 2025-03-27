import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

class ImageViewer extends StatefulWidget {
  final List<String> imgUrls;

  const ImageViewer({Key? key, required this.imgUrls}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    print("ASFASFASF:${widget.imgUrls}");

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final uniqueImgUrls = widget.imgUrls.toSet().toList(); // Remove duplicates

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blueGrey[700],
        title: Text(
          "Image Preview",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        shadowColor: Colors.black,
        shape: OutlineInputBorder(
            borderSide:
                BorderSide(style: BorderStyle.solid, color: Colors.white60)),
      ),
      body: Stack(
        children: [
          uniqueImgUrls.isEmpty
              ? Center(child: Text('No images found'))
              : PageView.builder(
                  controller: _pageController,
                  itemCount: uniqueImgUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        uniqueImgUrls[index],
                        fit: BoxFit.contain, // You can adjust this value
                        height: 200.0, // Set a maximum height if needed
                      ),
                    );
                  },
                ),
          if (uniqueImgUrls.isNotEmpty) // Conditionally render DotsIndicator
            Positioned(
              bottom: 16.0,
              left: 0,
              right: 0,
              child: DotsIndicator(
                dotsCount: uniqueImgUrls.length,
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
