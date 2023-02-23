class Tweet {
  final String text;
  final String user;
  final String createdAt;
  final String entitiesMedia;
  final String mediaUrl;
  final String profileImageUrl;
  final String userName;
  final String userScreenName;

  const Tweet({
    required this.text,
    required this.user,
    required this.createdAt,
    required this.entitiesMedia,
    required this.mediaUrl,
    required this.profileImageUrl,
    required this.userName,
    required this.userScreenName,
  });

  factory Tweet.fromJson(Map<String, dynamic> json) {
    return Tweet(
      text: json['full_text'],
      user: json['user'],
      createdAt: json['created_at'],
      entitiesMedia: json['entities']['media'],
      mediaUrl: json['media_url'],
      profileImageUrl: json['profile_image_url_https'],
      userName: json['user']['name'],
      userScreenName: json['user']['screen_name'],
    );
  }
}
