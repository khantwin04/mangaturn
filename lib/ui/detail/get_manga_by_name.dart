import 'package:flutter/material.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';

class GetMangaByName extends StatefulWidget {
  String mangaName;
  GetMangaByName({required this.mangaName});

  @override
  _GetMangaByNameState createState() => _GetMangaByNameState();
}

class _GetMangaByNameState extends State<GetMangaByName> {
  late ApiRepository apiRepository;
  late Future<List<MangaModel>> futureMangaModel;

  void getToken() async {
    final data = await AuthFunction.getToken();
    setState(() {
      futureMangaModel =
          apiRepository.searchMangaByName(widget.mangaName, 0, data!);
    });
  }

  @override
  void initState() {
    apiRepository = getIt.call();
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MangaModel>>(
        future: futureMangaModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ComicDetail(model: snapshot.data![0],);
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
