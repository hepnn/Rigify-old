import 'dart:convert';

class Tweet {
  final String id;
  final String fullText;
  final String createdAt;
  final String userName;
  final String userScreenName;
  final String userImageUrl;
  final String userEntitiesMedia;

  Tweet({
    required this.fullText,
    required this.createdAt,
    required this.userName,
    required this.id,
    required this.userScreenName,
    required this.userImageUrl,
    required this.userEntitiesMedia,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullText': fullText,
      'createdAt': createdAt,
      'userName': userName,
      'userScreenName': userScreenName,
      'userImageUrl': userImageUrl,
      'userEntitiesMedia': userEntitiesMedia,
    };
  }

  factory Tweet.fromMap(Map<String, dynamic> map) {
    return Tweet(
      id: map['id_str'],
      fullText: map['full_text'],
      createdAt: map['created_at'],
      userName: map['user']['name'],
      userScreenName: map['user']['screen_name'],
      userImageUrl: map['user']['profile_image_url_https'],
      userEntitiesMedia: map['entities']['media'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Tweet.fromJson(String source) => Tweet.fromMap(json.decode(source));
}
