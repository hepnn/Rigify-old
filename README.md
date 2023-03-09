# Rigify - Public Transit Routes and Timetables

GTFS data fetching and converting it into a user friendly UI. Built using Flutter Framework

[<img src="https://play.google.com/intl/en_us/badges/images/generic/en-play-badge.png"
      alt="Get it on Google Play"
      height="80">](https://play.google.com/store/apps/details?id=com.yamawagi.rigify)
      

## About

Developed in motion of not being able to find a good looking and not full of Ads public transit timetable app and deciding to build one on my own.

* This project uses AdMob for showing Banner Ads (Currently only Banner ads are implemented) and Twitter API for fetching user feed for News page implementation. These two are optional and can be easily disabled.

- Main data is gotten from a GTFS feed found here [routes](https://saraksti.rigassatiksme.lv/riga/routes.txt) and [stops](https://openmobilitydata-data.s3-us-west-1.amazonaws.com/public/feeds/rigas-satiksme/333/20221105/original/stops.txt).
- In App Purchases to remove ads are also implemented.

While this app is developed for a specific data feed, it can be easily modified and replaced with different GTFS data. A better template is in progress!

## Features

- Light / dark / system theme switch
- l10n / localization -  [flutter_localizations](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- In App Purchases - [in_app_purchase](https://pub.dev/packages/in_app_purchase)
- Search bar
- Favorites - [hive](https://pub.dev/packages/hive)
- Firebase Analytics & Crashlytics
- Logging
- Splash screen

      
## Screenshots

<img align="center" width="250" height="500" src="https://i.imgur.com/rRcC1ee.png">
<img align="center" width="250" height="500" src="https://i.imgur.com/iKedkMD.png">
<img align="center" width="250" height="500" src="https://i.imgur.com/Bpy6DAa.png">
<details>
<summary>Click for more</summary>
<img align="center" width="250" height="500" src="https://i.imgur.com/MLcYbVO.png">
<img align="center" width="250" height="500" src="https://i.imgur.com/QVgl376.png">
<img align="center" width="250" height="500" src="https://i.imgur.com/2FN3ece.png">
</details>

## Setup
- In App Purchases
    - An upload to play store is first required in order to properly display legitimate Ads, afterwards change the <b>productId</b> value in `lib\IAP\ad_removal_state.gen.dart` to your own ID.
- Setup your own API keys, references below.
- You will have to run `flutter gen-l10n` to generate l10n

## Env values

Env values are stored in <b>keys.dart</b> file. 

To enable AdMob, add:

`Ad unit ID for Android`

`Ad unit ID for IOS` 

To enable fetching from Twitter, add:

`Consumer key`

`Consumer secret`

`Token`

`Secret`
## Roadmap

- Map that shows routes and stops visually

- More language support

- Ticket reader using nfc (Reversing the hex data from mifare UL cards) 

