import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';

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
    print("ASFASFASF:${widget.imgData}");

    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page!.round();
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
        title: Text(
          "Image Preview",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 2,
        shadowColor: Colors.black,
        shape: OutlineInputBorder(
          borderSide: BorderSide(style: BorderStyle.solid, color: Colors.white60),
        ),
      ),
      body: Stack(
        children: [
          uniqueImgData.isEmpty
              ? Center(child: Text('No images found'))
              : PageView.builder(
            controller: _pageController,
            itemCount: uniqueImgData.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  // Full-Screen Image
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20), // Add padding here
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Optional: rounded corners
                        child: Image.network(
                          uniqueImgData[index]['url']!,
                          fit: BoxFit.contain, // Ensure the image stays within the padded area
                        ),
                      ),
                    ),
                  ),

                  // Date-Time on Top-Right
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        uniqueImgData[index]['date']!,
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (uniqueImgData.isNotEmpty) // Conditionally render DotsIndicator
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
