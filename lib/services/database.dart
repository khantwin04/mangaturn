import 'dart:async';
import 'dart:io';
import 'package:mangaturn/models/chapter_models/recent_chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/models/manga_models/favourite_manga_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DBHelper {
  static Database? _db;
  static const String DB_NAME = 'manga.db';

  //mangaData
  static const String MANGA_ID = 'mangaId';
  static const String MANGA_NAME = 'mangaName';
  static const String MANGA_COVER = 'mangaCover';
  static const String MANGA_TABLE = 'mangaInfo';

  //ChapterData
  static const String CHAPTER_MANGA_ID = 'mangaId';
  static const String CHAPTER_ID = 'chapterId';
  static const String CHAPTER_NAME = 'chapterName';
  static const String TOTAL_PAGE = 'totalPage';
  static const String CHAPTER_TABLE = 'chapterInfo';

  //PageData
  static const String PAGE_CHAPTER_ID = 'chapterId';
  static const String PAGE_MANGA_ID = 'mangaId';
  static const String PAGE_ID = 'pageId';
  static const String CONTENT_PAGE = 'contentPage';
  static const String PAGE_TABLE = 'pageInfo';

  //recentData
  static const String RECENT_MANGA_ID = 'mangaId';
  static const String RECENT_MANGA_NAME = 'mangaName';
  static const String RECENT_CHAPTER_ID = 'chapterId';
  static const String RECENT_CHAPTER_NAME = 'chapterName';
  static const String RECENT_RESUMEPAGENO = 'resumePageNo';
  static const String RECENT_RESUMEPOSITION = 'resumePosition';
  static const String RECENT_TOTALPAGE = 'totalPage';
  static const String RECENT_MAX_POSITION = 'maxScrollPosition';
  static const String RECENT_RESUME_IMAGE = 'resumeImage';
  static const String RECENT_TABLE = 'recentChapter';

  //favData
  static const String FAV_MANGA_ID = 'mangaId';
  static const String FAV_MANGA_NAME = 'mangaName';
  static const String FAV_MANGA_COVER = 'mangaCover';
  static const String FAV_TABLE = 'favManga';

  //followData
  static const String FOLLOW_USER_ID = 'userId';
  static const String FOLLOW_USER_NAME = 'userName';
  static const String FOLLOW_USER_COVER = 'userCover';
  static const String FOLLOW_USER_MESSENGER = 'userMessenger';
  static const String FOLLOW_TABLE = 'followUser';

  Future<Database> get db async {
    if (null != _db) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $MANGA_TABLE ($MANGA_ID INTEGER PRIMARY KEY, $MANGA_NAME TEXT, $MANGA_COVER TEXT)");
    await db.execute(
        "CREATE TABLE $CHAPTER_TABLE ($CHAPTER_MANGA_ID INTEGER, $CHAPTER_ID INTEGER PRIMARY KEY, $CHAPTER_NAME TEXT, $TOTAL_PAGE INTEGER)");
    await db.execute(
        "CREATE TABLE $PAGE_TABLE ($PAGE_CHAPTER_ID INTEGER, $PAGE_MANGA_ID INTEGER, $PAGE_ID INTEGER PRIMARY KEY, $CONTENT_PAGE TEXT)");
    await db.execute(
        "CREATE TABLE $RECENT_TABLE($RECENT_MANGA_ID INTEGER, $RECENT_MANGA_NAME TEXT, $RECENT_CHAPTER_ID INTEGER PRIMARY KEY, $RECENT_CHAPTER_NAME TEXT, $RECENT_RESUMEPAGENO INTEGER, $RECENT_RESUMEPOSITION REAL, $RECENT_TOTALPAGE INTEGER, $RECENT_MAX_POSITION REAL, $RECENT_RESUME_IMAGE TEXT)");
    await db.execute(
        "CREATE TABLE $FAV_TABLE ($FAV_MANGA_ID INTEGER PRIMARY KEY, $FAV_MANGA_NAME TEXT, $FAV_MANGA_COVER TEXT)");
    await db.execute(
        "CREATE TABLE $FOLLOW_TABLE ($FOLLOW_USER_ID INTEGER PRIMARY KEY, $FOLLOW_USER_NAME TEXT, $FOLLOW_USER_COVER TEXT, $FOLLOW_USER_MESSENGER TEXT)");
  }

  //downloadChapterProcess

  Future<DownloadManga> saveMangaInfo(DownloadManga manga) async {
    var dbClient = await db;
    int result = await dbClient.insert(MANGA_TABLE, manga.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('manga save result $result');
    return manga;
  }

  Future<DownloadChapter> saveChapterInfo(DownloadChapter chapter) async {
    var dbClient = await db;
    int result = await dbClient.insert(CHAPTER_TABLE, chapter.toMap());
    print('chapter save result $result');
    return chapter;
  }

  Future<DownloadPage> savePages(DownloadPage page) async {
    var dbClient = await db;
    int result = await dbClient.insert(PAGE_TABLE, page.toMap());
    print('page save result $result');
    return page;
  }

  Future<List<DownloadManga>> getMangaList() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(MANGA_TABLE);
    List<DownloadManga> manga = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        manga.add(DownloadManga.fromMap(maps[i]));
      }
    }
    return manga;
  }

  Future<List<DownloadChapter>> getChapterLists(int mangaId) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(CHAPTER_TABLE,
        where: '$CHAPTER_MANGA_ID=${mangaId}');
    List<DownloadChapter> chapters = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        chapters.add(DownloadChapter.fromMap(maps[i]));
      }
    }
    return chapters;
  }

  Future<List<DownloadPage>> getPages(int chapterId) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(PAGE_TABLE,
        where: '$PAGE_CHAPTER_ID=${chapterId}');
    List<DownloadPage> pages = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        pages.add(DownloadPage.fromMap(maps[i]));
      }
    }
    return pages;
  }

  Future<int> deleteMangaById(int mangaId) async {
    var dbClient = await db;
    int result =
        await dbClient.delete(MANGA_TABLE, where: '$MANGA_ID = $mangaId');
    await deleteChapter(0, mangaId, true);
    return result;
  }

  Future<int> deleteChapter(int chapterId, int mangaId, bool all) async {
    print(all);
    var dbClient = await db;
    int result;
    if (all == true) {
      result =
          await dbClient.delete(CHAPTER_TABLE, where: '$MANGA_ID = $mangaId');
    } else {
      result = await dbClient.delete(CHAPTER_TABLE,
          where: '$CHAPTER_ID = $chapterId');
    }
    await deletePages(chapterId, mangaId, all);
    return result;
  }

  Future<void> deletePages(int? chapterId, int mangaId, bool all) async {
    var dbClient = await db;
    List<DownloadPage> pages = await getPages(chapterId!);
    for (int i = 0; i < pages.length; i++) {
      final dir = File(pages[i].contentPage!);
      dir.deleteSync();
    }
    int result;
    if (all == true) {
      result =
          await dbClient.delete(PAGE_TABLE, where: '$PAGE_MANGA_ID = $mangaId');
    } else {
      print('not all');
      result =
          await dbClient.delete(PAGE_TABLE, where: '$CHAPTER_ID = $chapterId');
    }
    print(result);
  }

  //SavingRecentMangaProcess

  Future<void> saveRecentChapter(RecentChapterModel recentChapter) async {
    var dbClient = await db;
    int result = await dbClient.insert(RECENT_TABLE, recentChapter.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('recent save result $result');
  }

  Future<List<RecentChapterModel>> getRecentChapterList() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(RECENT_TABLE);
    List<RecentChapterModel> recentChapterList = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        recentChapterList.add(RecentChapterModel.fromJson(maps[i]));
      }
    }
    return recentChapterList;
  }

  Future<RecentChapterModel> getRecentChapterById(int chapterId) async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(RECENT_TABLE,
        where: '$RECENT_CHAPTER_ID = $chapterId');
    if (maps.length > 0) {
      return RecentChapterModel.fromJson(maps[0]);
    } else {
      return RecentChapterModel(chapterId: null);
    }
  }

  Future<int> deleteRecentChapterById(int chapterId) async {
    var dbClient = await db;
    int result = await dbClient.delete(RECENT_TABLE,
        where: '$RECENT_CHAPTER_ID = $chapterId');
    print(result);
    return result;
  }

  Future<int> deleteRecentChapterByMangaId(int mangaId) async {
    var dbClient = await db;
    int result = await dbClient.delete(RECENT_TABLE,
        where: '$RECENT_MANGA_ID = $mangaId');
    print(result);
    return result;
  }

  Future<int> deleteAllRecentChapter() async {
    var dbClient = await db;
    int result = await dbClient.delete(RECENT_TABLE);
    return result;
  }

  //SavingFavMangaProcess

  Future<FavMangaModel> saveFavMangaInfo(FavMangaModel manga) async {
    var dbClient = await db;
    int result = await dbClient.insert(FAV_TABLE, manga.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('manga save result $result');
    return manga;
  }

  Future<List<FavMangaModel>> getFavMangaList() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(FAV_TABLE);
    List<FavMangaModel> manga = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        manga.add(FavMangaModel.fromJson(maps[i]));
      }
    }
    return manga;
  }

  Future<int> deleteFavMangaById(int mangaId) async {
    var dbClient = await db;
    int result =
        await dbClient.delete(FAV_TABLE, where: '$FAV_MANGA_ID = $mangaId');
    return result;
  }

  Future<int> deleteAllFavManga() async {
    var dbClient = await db;
    int result = await dbClient.delete(FAV_TABLE);
    return result;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
