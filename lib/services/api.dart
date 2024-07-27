import 'package:mangaturn/models/auth_models/login_model.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/models/chapter_models/insert_chapter_model.dart';
import 'package:mangaturn/models/chapter_models/latestChapter_model.dart';
import 'package:mangaturn/models/chapter_models/update_chapter_model.dart';
import 'package:mangaturn/models/comment_model/get_unread_comment_by_admin.dart';
import 'package:mangaturn/models/comment_model/post_comment_model.dart';
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
import 'package:dio/dio.dart';
import 'package:mangaturn/models/version_model.dart';
import 'package:retrofit/retrofit.dart';
part 'api.g.dart';

@RestApi(baseUrl: 'http://146.190.80.28:8080/mt/api/')
abstract class ApiService {
  factory ApiService(Dio dio) => _ApiService(dio);

  // Auth api
  @POST('auth/signup')
  Future<AuthResponseModel> signUp(@Body() SignUpModel model);

  @POST('auth/login')
  Future<AuthResponseModel> login(@Body() LoginModel model);

  @GET('auth/refresh-token/{refreshToken}')
  Future<AuthResponseModel> refreshToken(@Path() String refreshToken);

  // User api

  @GET('user/{userId}')
  Future<GetUserModel> getUserById(
      @Path() userId, @Header('Authorization') String token);

  @GET('all-uploader?page={page}')
  Future<String> getAllAdmin(
      @Path() int page, @Header('Authorization') String token);

  @GET('all-uploader?username={name}&page={page}')
  Future<String> getAdminByName(
      @Path() name, @Path() int page, @Header('Authorization') String token);

  @GET('profile')
  Future<GetUserModel> getUserProfile(@Header('Authorization') String token);

  @PUT('update-user')
  Future<String> userUpdate(@Body() UpdateUserInfoModel update,
      @Header('Authorization') String token);

  @PUT('change-password')
  Future<String> userPasswordUpdate(
      @Body() UpdateUserPassword pwd, @Header('Authorization') String token);

  // Genre api

  @GET('genre')
  Future<List<GenreModel>> getAllGenre(@Header('Authorization') String token);

  // Manga api

  @GET(
      'all-manga?sort={sortBy},{sortType}&page={page}&size=11&isAdult={isAdult}')
  Future<GetAllMangaModel> getAllManga(
      @Path() String sortBy,
      @Path() String sortType,
      @Path() int page,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @GET(
      'all-manga?sort={sortBy},{sortType}&page={page}&size=11&uploadedBy={uploaderName}&isAdult={isAdult}')
  Future<GetAllMangaModel> getMangaByUploaderName(
      @Path() String sortBy,
      @Path() String sortType,
      @Path() int page,
      @Path() String uploaderName,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @GET(
      'all-manga?genre={genreIdList}&page={page}&sort=updated_Date,desc&size=4&isAdult={isAdult}')
  Future<GetAllMangaModel> getMangaByGenreId(
      @Path() String genreIdList,
      @Path() int page,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @GET('manga/{id}')
  Future<MangaModel> getMangaById(
      @Path() int id, @Header('Authorization') String token);

  @GET('all-manga?status={update}&page={page}&isAdult={isAdult}')
  Future<GetAllMangaModel> getMangaByUpdate(
      @Path() String update,
      @Path() int page,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @GET('all-manga?uploadedBy={name}&page={page}&isAdult={isAdult}')
  Future<GetAllMangaModel> getMangaByUploader(
      @Path() String name,
      @Path() int page,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @GET('all-manga?name={name}&page={page}&isAdult={isAdult}')
  Future<GetAllMangaModel> searchMangaByName(
      @Path() String name,
      @Path() int page,
      @Path() dynamic isAdult,
      @Header('Authorization') String token);

  @POST('add-manga')
  Future<String> insertNewManga(
      @Body() InsertMangaModel data, @Header('Authorization') String token);

  @PUT('update-manga')
  Future<String> updateManga(
      @Body() UpdateMangaModel data, @Header('Authorization') String token);

  @POST('add-favourite/{mangaId}')
  Future<String> addFavouriteManga(
      @Path() int mangaId, @Header('Authorization') String token);

  @DELETE('remove-favourite/{mangaId}')
  Future<String> removeFavourite(
      @Path() int mangaId, @Header('Authorization') String token);

  @GET('favourite-manga?page={page}')
  Future<GetAllMangaModel> getAllFavouriteManga(
      @Path() int page, @Header('Authorization') String token);

  @DELETE('delete-manga/{mangaId}')
  Future<String> deleteMangaById(
      @Path() int mangaId, @Header('Authorization') String token);

  // Chapter api

  @GET('latest-chapter')
  Future<List<LatestChapterModel>> getLatestChapter(
      @Header('Authorization') String token);

  @GET('all-chapter/{mangaId}?sort={sortBy},{sortType}&page={page}&size={size}')
  Future<String> getAllChapter(
      @Path() int mangaId,
      @Path() String sortBy,
      @Path() String sortType,
      @Path() int page,
      @Path() int size,
      @Header('Authorization') String token);

  @GET('chapter/{chapterId}?size={totalPages}&page={page}')
  Future<String> getAllPages(@Path() int chapterId, @Path() int totalPages,
      @Path() int page, @Header('Authorization') String token);

  @POST('purchase-chapter/{chapterId}')
  Future<String> purchaseChapter(
      @Path() int chapterId, @Header('Authorization') String token);

  @POST('add-chapter')
  Future<String> insertNewChapter(
      @Body() InsertChapterModel data, @Header('Authorization') String token);

  @GET('chapter-no/{mangaId}')
  Future<String> getLastChapterNo(
      @Path() int mangaId, @Header('Authorization') String token);

  @PUT('update-chapter')
  Future<String> updateOldChapter(
      @Body() UpdateChapterModel data, @Header('Authorization') String token);

  // Character api

  @GET('character/{mangaId}')
  Future<List<CharacterModel>> getAllCharacters(
      @Path() int mangaId, @Header('Authorization') String token);

  @POST('character')
  Future<String> insertNewCharacter(
      @Body() InsertCharacterModel data, @Header('Authorization') String token);

  @DELETE('character/{characterId}')
  Future<String> deleteCharacter(
      @Path() int characterId, @Header('Authorization') String token);

  // Point purchase api

  @POST('point-purchase')
  Future<String> requestPointPurchase(
      @Body() RequestPointModel data, @Header('Authorization') String token);

  @GET('all-point-purchase?page={page}&size={size}')
  Future<GetAllPointPurchaseModel> getPointPurchaseList(
      @Header('Authorization') String token, int page, int size);

  @GET('point-purchase/{id}')
  Future<PointPurchaseModel> getPointPurchaseById(
      @Path() int id, @Header('Authorization') String token);

  //Point Reclaim api

  @GET('all-point-reclaim?page={page}')
  Future<GetAllPointReclaimList> getAllPointReclaim(
      @Path() int page, @Header('Authorization') String token);

  @POST('point-reclaim')
  Future<String> requestPointReclaim(
      @Body() RequestReclaimModel data, @Header('Authorization') String token);

  @POST('point-reclaim/{id}')
  Future<PointReclaimModel> getPointReclaimById(
      @Path() int id, @Header('Authorization') String token);

  // Android Version api

  @GET('check-version?ver={version}')
  Future<VersionModel> checkVersion(
      @Path() String version, @Header('Authorization') String token);

  // Comment Api
  @POST('comment')
  Future<String> postComment(@Body() PostCommentModel commentModel,
      @Header('Authorization') String token);

  @GET('all-comment?mangaId={mangaId}&page={page}')
  Future<String> getAllCommentByMangaId(@Path() int mangaId, @Path() int page,
      @Header('Authorization') String token);

  @GET('all-comment?newMentionedComment=true&page={page}')
  Future<String> getMentionedComments(
      @Path() int page, @Header('Authorization') String token);

  @GET('all-comment?mangaId={mangaId}&size=5')
  Future<String> getLastCommentByMangaId(
      @Path() int mangaId, @Header('Authorization') String token);

  @GET('comment-count')
  Future<String> getUnreadCommentCount(@Header('Authorization') String token);

  @GET('comment-count-each')
  Future<List<GetUnreadCommentByAdmin>> getUnreadCommentByAdmin(
      @Header('Authorization') String token);
}
