import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_api/full_photo.dart';
import 'dart:convert';
import 'package:photo_api/model/photo.dart';
import 'package:photo_api/search.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const GridListScreen(),
    );
  }
}

class GridListScreen extends StatefulWidget {
  const GridListScreen({Key? key});

  @override
  _GridListScreenState createState() => _GridListScreenState();
}

class _GridListScreenState extends State<GridListScreen> {
  List<Photo> photos = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse(
          'https://api.unsplash.com/photos/random?count=30&client_id=VMfDoNqySJPwEozfjksImRSnF8Tqho7JxPEDENiAlHc'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Photo> fetchedPhotos = [];
      for (var item in data) {
        final photo = Photo.fromJson(item);
        fetchedPhotos.add(photo);
      }

      setState(() {
        photos.addAll(fetchedPhotos);
        isLoading = false;
      });
    } else {
      print('API request failed with status code: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildGridItem(int index) {
    if (index < photos.length) {
      final photo = photos[index];
      return GestureDetector(
        child: Hero(
          tag: photo.imageUrl,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: GridTile(
              footer: GridTileBar(
                backgroundColor: Colors.black45,
                title: Text(
                  photo.photographerName,
                  textAlign: TextAlign.center,
                ),
              ),
              child: CachedNetworkImage(
                imageUrl: photo.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SpinKitHourGlass(
                    color: Colors.white,
                    size: 40.0,
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullPhoto(photo: photo),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Prototype'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 14, 13, 13),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                            ),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchView(
                              searchQuery: searchController.text,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    bottom: 00,
                    right: 15,
                    top: 0,
                  ),
                  child: Container(
                    color: const Color.fromARGB(255, 41, 36, 36),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!isLoading &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          fetchData();
                          return true;
                        }
                        return false;
                      },
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const BouncingScrollPhysics(), // Use BouncingScrollPhysics for bouncing effect
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.5,
                        ),
                        itemCount: photos.length + 1,
                        itemBuilder: (context, index) => _buildGridItem(index),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 50,
                color: Colors.transparent,
                child: const Center(
                  child: SpinKitFadingCircle(
                    color: Color.fromARGB(255, 57, 61, 112),
                    size: 40.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
