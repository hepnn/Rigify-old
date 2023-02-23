import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/jiffy.dart';
import 'package:rigassat/main.dart';
import 'package:rigassat/services/api_twitter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../ads/banner_ad_widget.dart';
import '../utils/styles.dart';

class TwitterEmbed extends ConsumerWidget {
  const TwitterEmbed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsControllerAvailable = (adsControllerProvider) != null;

    final adsRemoved = inAppPurchaseControllerProvider != null
        ? ref.watch(inAppPurchaseControllerProvider!).maybeMap(
              active: (value) => true,
              orElse: () => false,
            )
        : false;

    final lang = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        shape: customShapeBorder,
        title: Text(lang.newsTitle),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: ApiTwitter().getTwitterTimeline(),
            initialData: 0,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Center(child: Text(lang.newsErr));
                case ConnectionState.waiting:
                //return Center(child:Container());
                case ConnectionState.active:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Center(child: Text(lang.newsErr));
                  }
                  var met = snapshot.data;

                  return RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(Duration(seconds: 1));
                      await ApiTwitter().getTwitterTimeline();
                    },
                    child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: met.length,
                        separatorBuilder: (context, index) {
                          if ((index % met.length ==
                                  0) && // README: To abide by family program policy, there can only be 1 ad per page.
                              adsControllerAvailable &&
                              !adsRemoved) {
                            return const SizedBox(
                              height: 50,
                              child: BannerAdWidget(),
                            );
                          } else {
                            return const SizedBox(
                              height: 5,
                            );
                          }
                        },
                        itemBuilder: (context, index) {
                          late String url;
                          var currentDate = Jiffy(
                              met[index]['created_at']
                                  .toString()
                                  .replaceAll('+0000', ''),
                              'EEE MMM dd hh:mm:ss  yyyy')
                            ..startOf(Units.DAY);
                          var dateparse = currentDate.fromNow().split(" ");
                          bool image = false;
                          if (met[index]['entities']['media'] == null) {
                            image = true;
                          } else {
                            image = false;
                            url =
                                met[index]['entities']['media'][0]['media_url'];
                          }

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(met[index]
                                            ['user']['profile_image_url_https']
                                        .replaceAll('_normal', '')),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '${met[index]['user']['name']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              '@${met[index]['user']['screen_name']} · ${dateparse[0] + " " + dateparse[1]}',
                                              style: const TextStyle(
                                                  color: Colors.grey),
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5.0,
                                        ),
                                        Text(met[index]['full_text']),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Container(
                                              child: image
                                                  ? Container()
                                                  : Image.network(
                                                      '$url?format=jpg&name=small')),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
