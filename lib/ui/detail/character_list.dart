import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/models/manga_models/character_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:mangaturn/ui/detail/view_character.dart';

class CharacterList extends StatefulWidget {
  final int mangaId;
  const CharacterList(this.mangaId, {Key? key}) : super(key: key);

  @override
  _CharacterListState createState() => _CharacterListState();
}

class _CharacterListState extends State<CharacterList> {
  late ApiRepository _apiRepository;
  Future<List<CharacterModel>>? futureCharacterList;
  late String token;
  bool fullWidth = false;

  void getToken() async {
    final data = await AuthFunction.getToken();
    setState(() {
      token = data!;
    });
    futureCharacterList =
        _apiRepository.getAllCharacters(widget.mangaId, token);
  }

  @override
  void initState() {
    _apiRepository = ApiRepository(getIt.call());
    getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CharacterModel>>(
      future: futureCharacterList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final characterList = snapshot.data;
          return Container(
            height: snapshot.data!.length == 0 ? 0 : 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Header(context, 'Artworks'),
                ),
                Expanded(
                  child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: characterList!.length,
                      //gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      //   childAspectRatio: fullWidth?1:(1 / 1.9), crossAxisCount: fullWidth?1:3),
                      itemBuilder: (BuildContext context, int index) {
                        final character = characterList[index];
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ViewCharacter(index: index, characterList: characterList),
                            ));
                          },
                          child: Container(
                            width: 120,
                            padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Hero(
                                    tag: character.id.toString(),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5.0),
                                      child: CachedNetworkImage(
                                        imageUrl: character.profileImagePath,
                                        placeholder: (_, __) => Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (_, __, ___) => Center(
                                          child: Icon(Icons.error),
                                        ),
                                        fit: BoxFit.cover,
                                        width: 100,
                                        alignment: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 50,
                                  width: 200,
                                  child: Text(
                                    character.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(snapshot.error.toString()),
          );
        } else {
          return Container(
            // height: 20,
            // padding: EdgeInsets.symmetric(horizontal: 30.0),
            // child: Center(
            //   child: LinearProgressIndicator(),
            // ),
          );
        }
      },
    );
  }
}
