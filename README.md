# Marvel Comics
The MarvelComics app shows detailed info about Marvel comics and characters (like comics viewer). All data, that shows in app, is provided by Marvel (www.marvel.com). Marvel provide RESTful API for it. Check it at http://developer.marvel.com/documentation/getting_started.

# Technical review
The App uses AFNetworking for download data from Marvel database. After downloading data parsed by FSDataParser ( AFNetworking return JSON, FSDataParser return array of NSManagedObject subclass after parsing is finished). App uses CoreData just for cache (in-memory CoreData storage type). Each ViewController in app use NSFetchedResultController for automatically update views with new data.

# Build requirements
- iOS SDK 9.0
- xCode 7
- AFNetworking 2.6

# Some screenshots of the working app

<p> - Portrait orientation: </p>
<img src="/../Screenshots/Screenshots/teams.png" width="250" height="445"/>
<img src="/../Screenshots/Screenshots/characters.png" width="250" height="445"/>
<img src="/../Screenshots/Screenshots/character_detail.png" width="250" height="445"/>
<img src="/../Screenshots/Screenshots/comic_detail.png" width="250" height="445"/>
<img src="/../Screenshots/Screenshots/image_viewer.png" width="250" height="445"/>

<p> - Landscape orientation: </p>
<img src="/../Screenshots/Screenshots/all_characters_landscape.png" width="445" height="250"/>
<img src="/../Screenshots/Screenshots/character_detail_landscape.png" width="445" height="250"/>
<img src="/../Screenshots/Screenshots/comic_detail_landscape.png" width="445" height="250"/>

