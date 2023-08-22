import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_api/full_photo.dart';
import 'package:photo_api/model/photo.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchView extends StatefulWidget {
  final String searchQuery;

  const SearchView({required this.searchQuery});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  List<Photo> photos = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoadingMore = false;
  bool _disposed = false;
  int currentPage = 1;
  String appTitle = '';
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController(text: widget.searchQuery);
    _updateAppTitle(widget.searchQuery);
    searchData(widget.searchQuery, currentPage);
  }

  @override
  void dispose() {
    _disposed = true;
    searchFocusNode.dispose();
    super.dispose();
  }

  void _updateAppTitle(String searchQuery) {
    setState(() {
      appTitle = 'Search: $searchQuery';
    });
  }

  Future<void> searchData(String searchQuery, int page) async {
    if (isSearching) return;

    setState(() {
      isSearching = true;
    });

    final response = await http.get(
      Uri.parse(
        'https://api.unsplash.com/search/photos?query=$searchQuery&page=$page&per_page=20&client_id=VMfDoNqySJPwEozfjksImRSnF8Tqho7JxPEDENiAlHc',
      ),
    );

    if (_disposed) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Photo> fetchedPhotos = [];
      for (var item in data['results']) {
        final photo = Photo.fromJson(item);
        fetchedPhotos.add(photo);
      }

      if (_disposed) return;

      setState(() {
        photos = fetchedPhotos;
        isSearching = false;
      });
    } else {
      print('API request failed with status code: ${response.statusCode}');
      if (_disposed) return;

      setState(() {
        isSearching = false;
      });
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore) return;

    setState(() {
      isLoadingMore = true;
    });

    currentPage++;

    final response = await http.get(
      Uri.parse(
        'https://api.unsplash.com/search/photos?query=${searchController.text}&page=$currentPage&per_page=20&client_id=VMfDoNqySJPwEozfjksImRSnF8Tqho7JxPEDENiAlHc',
      ),
    );

    if (_disposed) return;

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<Photo> fetchedPhotos = [];
      for (var item in data['results']) {
        final photo = Photo.fromJson(item);
        fetchedPhotos.add(photo);
      }

      if (_disposed) return;

      setState(() {
        photos.addAll(fetchedPhotos);
        isLoadingMore = false;
      });
    } else {
      print('API request failed with status code: ${response.statusCode}');
      if (_disposed) return;

      setState(() {
        isLoadingMore = false;
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
              builder: (context) =>
                  FullPhoto(photo: photo), // from here wallpaper should be set
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
        title: Text(appTitle),
      ),
      body: Column(
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
                            focusNode: searchFocusNode,
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
                SizedBox(width: 2.0),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    final query = searchController.text;
                    if (query.isNotEmpty) {
                      currentPage = 1;
                      searchData(query, currentPage);
                      _updateAppTitle(query);
                      searchFocusNode.unfocus(); // Hide the keyboard
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                if (!isSearching && photos.isEmpty)
                  Center(
                    child: Text('No results found.'),
                  ),
                if (!isSearching && photos.isNotEmpty)
                  NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (!isLoadingMore &&
                          scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent) {
                        loadMoreData();
                        return true;
                      }
                      return false;
                    },
                    child: GestureDetector(
                      onTap: () {
                        searchFocusNode.unfocus(); // Hide the keyboard
                      },
                      child: GridView.builder(
                        padding: const EdgeInsets.all(15.0),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 0.5,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) => _buildGridItem(index),
                      ),
                    ),
                  ),
                if (isLoadingMore)
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
          ),
        ],
      ),
    );
  }
}
