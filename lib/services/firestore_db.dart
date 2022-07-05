import 'dart:async';
import 'dart:io';
import 'package:mangaturn/models/firestore_models/follow_uploader_model.dart';
import 'package:mangaturn/models/firestore_models/noti_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class FirestoreDB {
  static Database? _db;
  static const String DB_NAME = 'firestore.db';

  //FollowUserData
  static const String FOLLOW_USER_ID = 'userId';
  static const String FOLLOW_USER_NAME = 'userName';
  static const String FOLLOW_USER_COVER = 'userCover';
  static const String FOLLOW_USER_MESSENGER = 'userMessenger';
  static const String FOLLOW_TABLE = 'followUser';

  //NotiModelData
  static const String NOTI_ID = 'id';
  static const String NOTI_MANGA_ID = 'mangaId';
  static const String NOTI_MANGA_NAME = 'mangaName';
  static const String NOTI_MANGA_COVER = 'mangaCover';
  static const String NOTI_TITLE = 'title';
  static const String NOTI_BODY = 'body';
  static const String NOTI_SEE = 'see';
  static const String NOTI_TABLE = 'noti';

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
        "CREATE TABLE $FOLLOW_TABLE ($FOLLOW_USER_ID INTEGER PRIMARY KEY, $FOLLOW_USER_NAME TEXT, $FOLLOW_USER_COVER TEXT, $FOLLOW_USER_MESSENGER TEXT)");
    await db.execute(
        "CREATE TABLE $NOTI_TABLE ($NOTI_ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $NOTI_MANGA_ID INTEGER, $NOTI_MANGA_NAME TEXT, $NOTI_MANGA_COVER TEXT, $NOTI_TITLE TEXT, $NOTI_BODY TEXT, $NOTI_SEE TEXT)");
  }

  //FollowUserFunction

  Future<FollowModel> followUser(FollowModel follow) async {
    var dbClient = await db;
    int result = await dbClient.insert(FOLLOW_TABLE, follow.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    print('Followed ${follow.userName}');
    return follow;
  }

  Future<List<FollowModel>> getFollowUsers() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(FOLLOW_TABLE);
    List<FollowModel> followedUsers = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        followedUsers.add(FollowModel.fromJson(maps[i]));
      }
    }
    return followedUsers;
  }

  Future<int> unfollowUserById(int userId) async {
    var dbClient = await db;
    int result =
    await dbClient.delete(FOLLOW_TABLE, where: '$FOLLOW_USER_ID = $userId');
    return result;
  }

  Future<int> unfollowAllUsers() async {
    var dbClient = await db;
    int result =
    await dbClient.delete(FOLLOW_TABLE);
    return result;
  }

  //IncomingNotiFunction

  Future<NotiModel> saveNotification(NotiModel notiModel) async {
    var dbClient = await db;
      int result = await dbClient.insert(NOTI_TABLE, notiModel.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      print('Saving ${notiModel.id}');
      return notiModel;
    
  }

  Future<List<NotiModel>> getAllNotification() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query(NOTI_TABLE);
    List<NotiModel> savedNoti = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        savedNoti.add(NotiModel.fromJson(maps[i]));
      }
    }
    return savedNoti;
  }

  Future<int> updateNotificationById(int notiId, NotiModel model) async {
    var dbClient = await db;
    int result =
    await dbClient.update(NOTI_TABLE, model.toJson(), where: '$NOTI_ID = $notiId');
    return result;
  }

  Future<int> deleteNotificationById(int notiId) async {
    var dbClient = await db;
    int result =
    await dbClient.delete(NOTI_TABLE, where: '$NOTI_ID = $notiId');
    return result;
  }

  Future<int> deleteAllNotification() async {
    var dbClient = await db;
    int result =
    await dbClient.delete(NOTI_TABLE);
    return result;
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }

}
