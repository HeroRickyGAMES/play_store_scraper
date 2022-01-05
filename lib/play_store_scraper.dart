library play_store_scraper;

import 'package:play_store_scraper/src/scraper_result.dart';
import 'package:web_scraper/web_scraper.dart';

export 'src/scraper_result.dart';

class PlayStoreScraper {
  /// domain for the google play website
  final String domain = 'https://play.google.com';

  /// creating a WebScraper object which helps us scrape data from the website
  final WebScraper webScraper = WebScraper('https://play.google.com');

  /// this method returns a Future with a Map of details about the required app from the Play Store
  /// [appID] is the appID for a particular app on the play store
  /// [gl] is an optional parameter for providing the Geographical location.
  /// It's default value is "in" i.e, for the the Geographical Location of India.
  /// You can provide any Geographical Location you want
  /// for example, "in" => India, "us" => USA, "ch" => China, "uk" => United Kingdom and so on..
  Future<Map<String, dynamic>> app(
      {required String appID, String gl = 'in'}) async {
    /// defining the end-point of the website
    final String endpoint = '/store/apps/details?id=$appID&gl=$gl';

    /// this will contain the final result of the scrapping
    Map<String, dynamic> result = {};

    if (await webScraper.loadWebPage(endpoint)) {
      try {
        /// grab the title of the app
        final title = webScraper.getElement('title', []).first['title'];

        /// grab the description of the app
        final description =
            webScraper.getElement('div.W4P4ne', []).first['title'];

        /// grab all additional info of the app
        final additionalInfo =
            webScraper.getElement('div.IQ1z0d > span.htlgb', []);

        final String updated = additionalInfo[0]['title'];

        final String size = additionalInfo[1]['title'];

        final String installs = additionalInfo[2]['title'];

        final String version = additionalInfo[3]['title'];

        final String androidVersion = additionalInfo[4]['title'];

        final String contentRating =
            (additionalInfo[5]['title']).split('Learn More')[0];

        final String developer =
            additionalInfo[additionalInfo.length - 2]['title'];

        /// grab all developer details
        final devElement = webScraper.getElement(
          'div.hAyfc > span.htlgb > div.IQ1z0d > span.htlgb > div > a',
          ['href'],
        );

        String developerWebsite = "", developerEmail = "", privacyPolicy = "";

        for (int i = 0; i < devElement.length; i++) {
          if (devElement[i]['title'] == 'Visit website') {
            try {
              developerWebsite = devElement[i]['attributes']['href'];
            } catch (_) {
              developerWebsite = "";
            }
            try {
              developerEmail = devElement[i + 1]['title'];
            } catch (_) {
              developerEmail = "";
            }
            try {
              privacyPolicy = devElement[i + 2]['attributes']['href'];
            } catch (_) {
              privacyPolicy = "";
            }
          }
        }

        /// grab the developer address
        final developerAddress = webScraper.getElement(
          'div.IQ1z0d > span.htlgb > div',
          [],
        ).last['title'];

        final ratingsScoreText = webScraper.getElement(
          'div.W4P4ne > c-wiz > div.K9wGie > div.BHMmbe',
          [],
        ).first['title'];

        final dataFromScripts = webScraper.getAllScripts();
        String ratingsScore = '',
            ratingsCount = '',
            price = '',
            priceCurrency = '';
        bool free = false;

        for (var scriptData in dataFromScripts) {
          if (scriptData.contains('ratingValue')) {
            var dataList = scriptData.split('",');
            for (var listElement in dataList) {
              if (listElement.contains('ratingValue')) {
                ratingsScore = listElement.split(':"')[1];
              }
              if (listElement.contains('ratingCount')) {
                ratingsCount = listElement.split(':"')[1].split('"},')[0];
              }
              if (listElement.contains('"price"')) {
                price = listElement.split(':"')[1];
                if (price == '0') free = true;
              }
              if (listElement.contains('"priceCurrency"')) {
                priceCurrency = listElement.split(':"')[1];
              }
            }
          }
        }

        /// grab the genre of the app
        final genreElement = webScraper.getElement(
          'div.jdjqLd > div.ZVWMWc > div.qQKdcc > span > a',
          ['href'],
        );
        String developerID = '', genre = '', genreID = '';

        for (var genreEle in genreElement) {
          if ((genreEle['attributes']['href']).toString().contains('id')) {
            developerID =
                (genreEle['attributes']['href']).toString().split('id=')[1];
          }
          if ((genreEle['attributes']['href'])
              .toString()
              .contains('category')) {
            genre = genreEle['title'];
            genreID = (genreEle['attributes']['href'])
                .toString()
                .split('category/')[1];
          }
        }

        /// grab the app icon
        final iconElement = webScraper.getElement(
          'div.oQ6oV > div.hkhL9e > div.xSyT2c > img',
          ['src', 'alt'],
        );
        String icon = '';

        for (var element in iconElement) {
          if ((element['attributes']['alt']).toString().toLowerCase() ==
              'cover art') {
            icon = element['attributes']['src'];
          }
        }

        String url =
            'https://play.google.com/store/apps/details?id=$appID&hl=en';
        String devUrl =
            'https://play.google.com/store/apps/dev?id=$developerID';

        ScraperResult _data = ScraperResult(
          title: title,
          description: description,
          updated: updated,
          size: size,
          installs: installs,
          version: version,
          androidVersion: androidVersion,
          contentRating: contentRating,
          developer: developer,
          developerWebsite: developerWebsite,
          developerEmail: developerEmail,
          privacyPolicy: privacyPolicy,
          developerAddress: developerAddress,
          ratingsScoreText: ratingsScoreText,
          ratingsScore: ratingsScore,
          ratingsCount: ratingsCount,
          price: price,
          free: free,
          priceCurrency: priceCurrency,
          developerID: developerID,
          genre: genre,
          genreID: genreID,
          icon: icon,
          appID: appID,
          appUrl: url,
          developerUrl: devUrl,
        );

        /// creating the map containing all data
        result.addAll({
          'isError': false,
          'data': _data,
        });
      } catch (error) {
        result.addAll({
          "isError": true,
          "error": error.toString(),
          "message": "Cannot find the app on Play Store."
              "\nPlease make sure that you have mentioned the correct appID "
              "and the app is available in the Geographical Location mentioned with the 'gl' attribute passed to the app() method."
              "\n If you have not mentioned anything for the 'gl' attribute it defaults to the 'in' i.e, the Geographical Location of India."
        });
      }
    } else {
      /// if there error in getting access to play store
      result.addAll({
        "isError": true,
        "error": "error in getting access to play store",
        "message": 'Cannot load url.'
            '\nPlease make sure that you are connected to the Internet.'
            '\nPlease make sure that you have mentioned the correct appID '
            'and the app is available in the Geographical Location mentioned with the "gl" attribute passed to the app() method.'
            '\n If you have not mentioned anything for the "gl" attribute it defaults to the "in" i.e, the Geographical Location of India.'
      });
    }

    return result;
  }
}
