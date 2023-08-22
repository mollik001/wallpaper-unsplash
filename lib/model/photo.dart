class Photo {
  final String imageUrl;
  final String photographerName;

  Photo({
    required this.imageUrl,
    required this.photographerName,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      imageUrl: json['urls']['regular'],
      photographerName: json['user']['name'],
    );
  }
}

















// class Photo {
//   final String id;
//   final String description;
//   final String altDescription;
//   final String imageUrl;
//   final String photographerName;
//   final int likes;

//   Photo({
//     required this.id,
//     required this.description,
//     required this.altDescription,
//     required this.imageUrl,
//     required this.photographerName,
//     required this.likes,
//   });

//   factory Photo.fromJson(Map<String, dynamic> json) {
//     final urls = json['urls'];
//     return Photo(
//       id: json['id'],
//       description: json['description'] ?? '',
//       altDescription: json['alt_description'] ?? '',
//       imageUrl: urls['regular'],
//       photographerName: json['user']['name'],
//       likes: json['likes'],
//     );
//   }
// }
