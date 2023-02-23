import 'dart:convert';
import 'dart:io';
import 'package:dart_twitter_api/twitter_api.dart';

import '../keys.dart';

class ApiConstants {
  static String baseUrl = 'api.twitter.com';
  static String timelineEndPoint = '1.1/statuses/user_timeline.json';
}

class ApiTwitter {
  final twitterOauth = TwitterApi(
    client: TwitterClient(
      consumerKey: TwitterAPIKeys.consumerKey,
      consumerSecret: TwitterAPIKeys.consumerSecret,
      token: TwitterAPIKeys.token,
      secret: TwitterAPIKeys.secret,
    ),
  );

  Future<List> getTwitterTimeline() async {
    try {
      Future twitterRequest = twitterOauth.client.get(
        Uri.https(ApiConstants.baseUrl, ApiConstants.timelineEndPoint, {
          'count': '30',
          'user_id': '368753015',
          'exclude_replies': 'true',
          'tweet_mode': 'extended',
        }),
      );

      var res = await twitterRequest;

      var tweets = json.decode(res.body);
      return tweets;
    } on SocketException catch (e) {
      print('SocketException: $e');
    } on HttpException catch (e) {
      print('HttpException: $e');
    } on FormatException catch (e) {
      print('FormatException: $e');
    } catch (e) {
      print('Exception: $e');
    }
    return [];
  }
}

Future<List> getTitter() async {
  try {
    final api = ApiTwitter();
    final tweets = await api.getTwitterTimeline();
    return tweets;
  } on SocketException catch (e) {
    return Future.error(e);
  }
}
