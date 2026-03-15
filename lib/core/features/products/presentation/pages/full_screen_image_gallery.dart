import 'package:flutter/material.dart';

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  // --- NEW: Controller to track the exact zoom level ---
  final TransformationController _transformationController = TransformationController();
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // --- NEW: Listen to zoom changes ---
    _transformationController.addListener(() {
      // Get the current zoom scale
      final scale = _transformationController.value.getMaxScaleOnAxis();

      // If zoomed in past 1.0, lock the PageView. If back to 1.0, unlock it!
      if (scale > 1.0 && !_isZoomedIn) {
        setState(() => _isZoomedIn = true);
      } else if (scale <= 1.0 && _isZoomedIn) {
        setState(() => _isZoomedIn = false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            // --- NEW: Lock the swiping if the user is zoomed in! ---
            physics: _isZoomedIn ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              // Reset zoom back to normal if they swipe to a new image
              _transformationController.value = Matrix4.identity();
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                // Only attach the controller to the image currently on screen
                transformationController: _currentIndex == index ? _transformationController : null,
                minScale: 1.0,
                maxScale: 4.0,
                // We removed the 'Center' widget here because it can sometimes block the zoom boundaries!
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
                ),
              );
            },
          ),

          // --- CLOSE BUTTON ---
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // --- IMAGE COUNTER ---
          if (widget.imageUrls.length > 1)
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}