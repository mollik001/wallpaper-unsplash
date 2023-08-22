import 'package:flutter/material.dart';
import 'package:photo_api/model/photo.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class FullPhoto extends StatefulWidget {
  final Photo photo;

  const FullPhoto({Key? key, required this.photo}) : super(key: key);

  @override
  _FullPhotoState createState() => _FullPhotoState();
}

class _FullPhotoState extends State<FullPhoto> {
  late Future<bool> _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = _simulateLoading();
  }

  Future<bool> _simulateLoading() async {
    // Simulate a delay to show the loading animation
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _loadingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorMessage();
          } else {
            return _buildPhotoContent();
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _setWallpaper();
        },
        label: const Text(
          'Set Wallpaper',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 5,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SpinKitCircle(
        color: Colors.blue, // Customize the loading indicator color
        size: 50.0, // Customize the loading indicator size
      ),
    );
  }

  Widget _buildErrorMessage() {
    return const Center(
      child: Text('Error occurred while loading the photo.'),
    );
  }

  Widget _buildPhotoContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(widget.photo.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<void> _setWallpaper() async {
    try {
      final int location = WallpaperManager.HOME_SCREEN;
      final String url = widget.photo.imageUrl;

      // Download the image file
      final file = await DefaultCacheManager().getSingleFile(url);

      // Set the wallpaper
      await WallpaperManager.setWallpaperFromFile(
        file.path,
        location,
      );

      // Show a success message or perform any additional actions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wallpaper set successfully!')),
      );
    } catch (e) {
      // Handle any errors that occur during wallpaper setting
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to set wallpaper.')),
      );
    }
  }
}
