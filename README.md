# play_store_scraper

A flutter package to scrape data from the Google Play Store.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  play_store_scraper: any
```

In your library add the following import:

```dart
import 'package:play_store_scraper/play_store_scraper.dart';
```

### How to use

```
1. First create an object

    PlayStoreScraper scraper = PlayStoreScraper();
    ScraperResult? _result;  
    bool _isError = true;
    String _errorMsg = "", _error = "";

2. Then pass the appID to the app method to get a Future as a map of all the required data for example,  

    var data = await scraper.app(appID: "com.snapchat.android"); 

3. Access Data as,  
    
    _isError = data['isError'];
    if (_isError) {
      _errorMsg = data['message'];
      _error = data['error'];
    } else {
      _result = data['data'];
      print(_result!.title);
    }
    
For an example of how to use it, checkout the example/main.dart file  
```

You can checkout this example app [Example](https://github.com/varamsky/google_play_store_scraper_dart/blob/master/example/main.dart).

## Success Results

```map
{
'isError': false,
'data': _data,
}
where _data is ScraperResult which is as
    ScraperResult({title, description, updated, size, installs, version, androidVersion, contentRating, developer, developerWebsite, developerEmail, privacyPolicy, developerAddress, ratingsScoreText, ratingsScore, ratingsCount, price, free, priceCurrency, developerID, genre, genreID, icon, appID, appUrl, developerUrl});
```
## Error Results

```map
{
"isError": true,
"error": error.toString(),
"message": msg.toString,
}
```

### Created & Maintained By

[Ankush Mishra](https://github.com/ankushmishra2903-official). or just drop a mail at ankushmishra2903@gmail.com :v:

# License

    Copyright 2022 Ankush Mishra

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

