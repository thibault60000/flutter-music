class Song {
  String title;
  // String subtitle;
  // Map images;
  // Map artists;
  // String url;

  Song(
      {required this.title /* this.subtitle, this.images, this.artists, this.url */});

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      // subtitle: json['subtitle'],
      // images: json['images'],
      // images: json['artists'],
      // images: json['url'],
    );
  }
}
