import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/models/chapter_models/update_chapter_model.dart';
import 'package:mangaturn/models/manga_models/character_model.dart';
import 'package:mangaturn/models/manga_models/update_character_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/view_character.dart';
import 'package:mangaturn/ui/workspace/edit_characters.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

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

  int currentIndex = 0;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artworks'),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showHelp(context);
            },
          ),
          IconButton(
            icon: fullWidth
                ? Icon(Icons.fullscreen_exit)
                : Icon(Icons.fullscreen),
            onPressed: () {
              setState(() {
                fullWidth = !fullWidth;
              });
            },
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    EditCharacters(true, widget.mangaId, null),
              ));
              if (result != null && result == 'success') {
                setState(() {
                  futureCharacterList = null;
                  futureCharacterList =
                      _apiRepository.getAllCharacters(widget.mangaId, token);
                });
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<CharacterModel>>(
        future: futureCharacterList,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final characterList = snapshot.data;

            if (fullWidth) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                    itemCount: characterList!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final character = characterList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewCharacter(
                                index: index, characterList: characterList),
                          ));
                        },
                        onLongPress: () async {
                          UpdateCharacterModel update = UpdateCharacterModel(
                            id: character.id,
                            mangaId: widget.mangaId,
                            name: character.name,
                            profileImage: character.profileImagePath,
                          );
                          final result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) =>
                                EditCharacters(false, widget.mangaId, update),
                          ));
                          if (result != null && result == 'success') {
                            setState(() {
                              futureCharacterList = null;
                              futureCharacterList = _apiRepository
                                  .getAllCharacters(widget.mangaId, token);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Stack(
                            children: [
                              Positioned(
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
                                      width: double.infinity,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 50,
                                  color: Colors.black45,
                                  width: double.infinity,
                                  child: Center(
                                    child: Text(
                                      character.name,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: GridView.builder(
                    itemCount: characterList!.length,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: (1 / 1.9), crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      final character = characterList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ViewCharacter(
                                index: index, characterList: characterList),
                          ));
                        },
                        onLongPress: () async {
                          UpdateCharacterModel update = UpdateCharacterModel(
                            id: character.id,
                            mangaId: widget.mangaId,
                            name: character.name,
                            profileImage: character.profileImagePath,
                          );
                          final result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                            builder: (context) =>
                                EditCharacters(false, widget.mangaId, update),
                          ));
                          if (result != null && result == 'success') {
                            setState(() {
                              futureCharacterList = null;
                              futureCharacterList = _apiRepository
                                  .getAllCharacters(widget.mangaId, token);
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
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
                                      height: 100,
                                      width: double.infinity,
                                      alignment: Alignment.topCenter,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 50,
                                width: double.infinity,
                                child: Text(
                                  character.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              );
            }
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.help_outline),
              SizedBox(width: 5),
              Text('Help'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Long Press to edit on image'),
              ),
            ],
          ),
        );
      },
    );
  }
}
