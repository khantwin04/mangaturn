import 'dart:convert';
import 'package:mangaturn/config/local_storage.dart';
import 'package:mangaturn/models/auth_models/login_model.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/insert_chapter_model.dart';
import 'package:mangaturn/models/chapter_models/latestChapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/models/chapter_models/update_chapter_model.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/models/comment_model/get_unread_comment_by_admin.dart';
import 'package:mangaturn/models/comment_model/post_comment_model.dart';
import 'package:mangaturn/models/firestore_models/customPayload.dart';
import 'package:mangaturn/models/firestore_models/payload.dart';
import 'package:mangaturn/models/manga_models/character_model.dart';
import 'package:mangaturn/models/manga_models/genre_model.dart';
import 'package:mangaturn/models/manga_models/insert_character_model.dart';
import 'package:mangaturn/models/manga_models/insert_manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:mangaturn/models/manga_models/update_character_model.dart';
import 'package:mangaturn/models/manga_models/update_manga_model.dart';
import 'package:mangaturn/models/point_model/point_relcaim_model.dart';
import 'package:mangaturn/models/point_model/request_reclaim_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/models/user_models/point_purchase_model.dart';
import 'package:mangaturn/models/user_models/requestPointModel.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/models/version_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/api.dart';
import 'package:http/http.dart' as http;

class ApiRepository {
  final ApiService _apiService;

  ApiRepository(this._apiService);

  // Auth api

  Future<AuthResponseModel> signUp(SignUpModel model) =>
      _apiService.signUp(model);

  Future<AuthResponseModel> login(LoginModel model) => _apiService.login(model);

  Future<AuthResponseModel> refreshToken(String refreshToken) =>
      _apiService.refreshToken(refreshToken);

  // User Api
  Future<GetUserModel> getUserById(userId, String token) =>
      _apiService.getUserById(userId, token);

  Future<List<GetUserModel>> getAllAdmin(int page, String token) async {
    String jsonString = await _apiService.getAllAdmin(page, token);
    Map<String, dynamic> map = json.decode(jsonString) as Map<String, dynamic>;
    List userMap = map['userList'];
    return userMap.map<GetUserModel>((e) => GetUserModel.fromJson(e)).toList();
  }

  Future<List<GetUserModel>> getAdminByName(
      String name, int page, String token) async {
    String jsonString = await _apiService.getAdminByName(name, page, token);
    Map<String, dynamic> map = json.decode(jsonString) as Map<String, dynamic>;
    List userMap = map['userList'];
    return userMap.map<GetUserModel>((e) => GetUserModel.fromJson(e)).toList();
  }

  Future<GetUserModel> getUserProfile(String token) =>
      _apiService.getUserProfile(token);

  Future<String> userUpdate(UpdateUserInfoModel update, String token) =>
      _apiService.userUpdate(update, token);

  Future<String> userPasswordUpdate(
          UpdateUserPassword password, String token) =>
      _apiService.userPasswordUpdate(password, token);

  // Genre api

  Future<List<GenreModel>> getAllGenre(String token) =>
      _apiService.getAllGenre(token);

  // Manga api

  Future<GetAllMangaModel> getAllManga(
      String sortBy, String sortType, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    return _apiService.getAllManga(
        sortBy, sortType, page, show == true ? '' : show, token);
  }

  Future<GetAllMangaModel> getMangaByUploaderName(String sortBy,
      String sortType, int page, String uploaderName, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    return _apiService.getMangaByUploaderName(
        sortBy, sortType, page, uploaderName, show == true ? '' : show, token);
  }

  Future<GetAllMangaModel> getMangaByGenreId(
      List<int> genreIdList, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    return _apiService.getMangaByGenreId(
        genreIdList.join(','), page, show == true ? '' : show, token);
  }

  Future<MangaModel> getMangaById(int id, String token) =>
      _apiService.getMangaById(id, token);

  Future<GetAllMangaModel> getMangaByUpdate(
      String update, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    return _apiService.getMangaByUpdate(
        update, page, show == true ? '' : show, token);
  }

  Future<GetAllMangaModel> getMangaByUploader(
      String name, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    return _apiService.getMangaByUploader(
        name, page, show == true ? '' : show, token);
  }

  Future<List<MangaModel>> searchMangaByGenreId(
      List<int> genreIdList, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    GetAllMangaModel data = await _apiService.getMangaByGenreId(
        genreIdList.join(','), page, show == true ? '' : show, token);
    return data.mangaList;
  }

  Future<List<MangaModel>> searchMangaByName(
      String name, int page, String token) async {
    bool show = await LocalStorage.getMangaShowLimit() ?? true;
    GetAllMangaModel data = await _apiService.searchMangaByName(
        name, page, show == true ? '' : show, token);
    return data.mangaList;
  }

  Future<String> insertNewManga(InsertMangaModel data, String token) =>
      _apiService.insertNewManga(data, token);

  Future<String> updateManga(UpdateMangaModel data, String token) =>
      _apiService.updateManga(data, token);

  Future<String> addFavourtieManga(int mangaId, String token) =>
      _apiService.addFavouriteManga(mangaId, token);

  Future<String> removeFavouriteManga(int mangaId, String token) =>
      _apiService.removeFavourite(mangaId, token);

  Future<GetAllMangaModel> getAllFavouriteManga(int page, String token) =>
      _apiService.getAllFavouriteManga(page, token);

  Future<String> deleteMangaById(int mangaId, String token) =>
      _apiService.deleteMangaById(mangaId, token);

  // Chapter api

  Future<List<LatestChapterModel>> getLatestChapter(String token) =>
      _apiService.getLatestChapter(token);

  Future<List<ChapterModel>> getAllChapters(int mangaId, String sortBy,
      String sortType, int page, int size, String token) async {
    String jsonString = await _apiService.getAllChapter(
        mangaId, sortBy, sortType, page, size, token);
    List parsed = json.decode(jsonString)['chapterList'];
    return parsed.map((e) => ChapterModel.fromJson(e)).toList();
  }

  Future<List<PageModel>> getAllPages(
      int chapterId, int totalPages, int page, String token) async {
    String jsonString =
        await _apiService.getAllPages(chapterId, totalPages, page, token);
    List parsed = json.decode(jsonString)['pages'];
    return parsed.map((e) => PageModel.fromJson(e)).toList();
  }

  Future<String> purchaseChapter(int chapterId, String token) =>
      _apiService.purchaseChapter(chapterId, token);

  Future<String> insertNewChapter(InsertChapterModel data, String token) =>
      _apiService.insertNewChapter(data, token);

  Future<String> getLastChapterNo(int mangaId, String token) =>
      _apiService.getLastChapterNo(mangaId, token);

  Future<String> updateOldChapter(UpdateChapterModel data, String token) =>
      _apiService.updateOldChapter(data, token);

  // Character api

  Future<List<CharacterModel>> getAllCharacters(int mangaId, String token) =>
      _apiService.getAllCharacters(mangaId, token);

  Future<String> insertNewCharacter(InsertCharacterModel data, String token) =>
      _apiService.insertNewCharacter(data, token);

  Future<String> deleteCharacter(int characterId, String token) =>
      _apiService.deleteCharacter(characterId, token);

  // Point purchase api

  Future<String> requestPointPurchase(RequestPointModel data, String token) =>
      _apiService.requestPointPurchase(data, token);

  Future<List<PointPurchaseModel>> getPointPurchaseList(
      String token, int page, int size) async {
    final data = await _apiService.getPointPurchaseList(token, page, size);
    return data.pointPurchaseList;
  }

  Future<PointPurchaseModel> getPointPurchaseById(int id, String token) =>
      _apiService.getPointPurchaseById(id, token);

  // Point reclaim api

  Future<List<PointReclaimModel>> getAllPointReclaimList(
      int page, String token) async {
    final data = await _apiService.getAllPointReclaim(page, token);

    return data.pointReclaimList;
  }

  Future<String> requestPointReclaim(RequestReclaimModel data, String token) =>
      _apiService.requestPointReclaim(data, token);

  Future<PointReclaimModel> getPointReclaimById(int id, String token) =>
      _apiService.getPointReclaimById(id, token);

  // Android version api

  Future<VersionModel> checkVersion(String version, String token) =>
      _apiService.checkVersion(version, token);

  // Notification api

  final String serverToken =
      'AAAAcERNUCs:APA91bF8pyLep0iIkTxFPYEhawoReUIy_EG5G85zldEAz7cVzErQzQ-vJOoyp1BrG1--YvQQmCgu9HHGWsHVTN3ZePU-EHJYkbUy32c3y3A4IyLVZEXxLGPrjv4BmUTXPKxSA5M_RPEi';

  Future<void> sendNotification(Payload payload) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(payload.toJson()),
    );
  }

  Future<void> sendCustomNotification(CustomPayload customPayload) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(customPayload.toJson()),
    );
  }

  //Comment Api
  Future<List<GetCommentModel>> getAllCommentByMangaId(
      int mangaId, int page, String token) async {
    String jsonString =
        await _apiService.getAllCommentByMangaId(mangaId, page, token);
    List decodedMap = json.decode(jsonString)['commentList'];
    return decodedMap
        .map<GetCommentModel>((e) => GetCommentModel.fromJson(e))
        .toList();
  }

  Future<List<GetCommentModel>> getLastCommentByMangaId(
      int mangaId, int page, String token) async {
    String jsonString =
        await _apiService.getLastCommentByMangaId(mangaId, token);
    List decodedMap = json.decode(jsonString)['commentList'];
    return decodedMap
        .map<GetCommentModel>((e) => GetCommentModel.fromJson(e))
        .toList();
  }

  Future<List<GetCommentModel>> getMentionedComments(
     int page, String token) async {
    String jsonString =
        await _apiService.getMentionedComments(page, token);
    List decodedMap = json.decode(jsonString)['commentList'];
    return decodedMap
        .map<GetCommentModel>((e) => GetCommentModel.fromJson(e))
        .toList();
  }

  Future<String> postComment(PostCommentModel commentModel, String token) =>
      _apiService.postComment(commentModel, token);

  Future<String> getUnreadCommentCount(String token) =>
      _apiService.getUnreadCommentCount(token);

   Future<List<GetUnreadCommentByAdmin>> getUnreadCommentByAdmin(String token) =>
      _apiService.getUnreadCommentByAdmin(token);
      
}
