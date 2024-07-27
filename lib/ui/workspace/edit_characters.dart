import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/models/manga_models/insert_character_model.dart';
import 'package:mangaturn/models/manga_models/update_character_model.dart';
import 'package:mangaturn/services/bloc/post/edit_characters_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

class EditCharacters extends StatefulWidget {
  final bool newCharacter;
  final int mangaId;
  final UpdateCharacterModel? oldCharacter;
  EditCharacters(this.newCharacter, this.mangaId, this.oldCharacter, {Key? key})
      : super(key: key);

  @override
  _EditCharactersState createState() => _EditCharactersState();
}

class _EditCharactersState extends State<EditCharacters> {
  String name = '';
  String profileImage = '';
  String profileImageBase64 = '';
  Uint8List? uint8listImage;
  final formKey = GlobalKey<FormState>();

  bool newImage = false;

  initialValues() async {
    if (widget.newCharacter) {
      name = '';
      profileImage = '';
      profileImageBase64 = '';
    } else {
      print(widget.oldCharacter!.profileImage);
      name = widget.oldCharacter!.name;
      profileImage = widget.oldCharacter!.profileImage;
      profileImageBase64 = await Utility.NetworkImageToBase64Prefix(
          widget.oldCharacter!.profileImage);
    }
  }

  Future<void> pickCover() async {
    if (!widget.newCharacter)
      setState(() {
        newImage = true;
      });

    List<Asset> resultList = [];
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        // selectedAssets: images,
        androidOptions: AndroidOptions(
          lightStatusBar: true,
          maxImages: 1,
          actionBarTitle: "Select images",
          allViewTitle: "All Photos",
          useDetailsView: false,
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }
    if (resultList[0] != null) {
      await resultList[0].getByteData().then((value) {
        setState(() {
          profileImageBase64 = Utility.base64String(value.buffer.asUint8List());
          uint8listImage = value.buffer.asUint8List();
        });
      });
    }
  }

  void insertNewCharacter() {
    if (formKey.currentState!.validate()) {
      if (profileImageBase64 == '') {
        AlertError(
            context: context, title: 'Photo Required', content: 'Upload photo');
      } else {
        InsertCharacterModel insert = InsertCharacterModel(
          mangaId: widget.mangaId,
          name: name,
          profileImage: profileImageBase64,
        );
        BlocProvider.of<EditCharactersCubit>(context)
            .insertNewCharacter(insert);
      }
    }
  }

  Future<void> updateOldCharacter() async {
    if (formKey.currentState!.validate()) {
      await Utility.deleteImageFromCache(widget.oldCharacter!.profileImage);
      await DefaultCacheManager().removeFile(widget.oldCharacter!.profileImage);

      UpdateCharacterModel update = UpdateCharacterModel(
        id: widget.oldCharacter!.id,
        mangaId: widget.mangaId,
        name: name,
        profileImage: profileImageBase64,
      );
      BlocProvider.of<EditCharactersCubit>(context).deleteCharacter(update);
    }
  }

  @override
  void initState() {
    initialValues();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            widget.newCharacter ? Text('Upload Artwork') : Text('Edit artwork'),
        actions: [
          TextButton(
              onPressed: () {
                if (widget.newCharacter) {
                  insertNewCharacter();
                } else {
                  updateOldCharacter();
                }
              },
              child: widget.newCharacter ? Text('Upload') : Text('Delete'))
        ],
      ),
      body: BlocConsumer<EditCharactersCubit, EditCharactersState>(
        listener: (context, state) {
          if (state is EditCharactersSuccess) {
            Navigator.of(context).pop('success');
          }
        },
        builder: (context, state) {
          if (state is EditCharactersFail) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(state.error),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: () {
                      BlocProvider.of<EditCharactersCubit>(context)
                          .emit(EditCharactersInitial());
                    },
                    child: Text('Retry'))
              ],
            ));
          } else if (state is EditCharactersLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                        readOnly: widget.newCharacter ? false : true,
                        initialVal: name,
                        label: 'Name',
                        context: context,
                        action: TextInputAction.done,
                        onChange: (data) {
                          setState(() {
                            name = data;
                          });
                        }),
                    SizedBox(
                      height: 10,
                    ),
                    uint8listImage == null
                        ? widget.newCharacter
                            ? InkWell(
                                onTap: () {
                                  pickCover();
                                },
                                child: Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                    color: Colors.grey,
                                  )),
                                  width: double.infinity,
                                  child: Icon(Icons.add),
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  pickCover();
                                },
                                child: CachedNetworkImage(
                                  imageUrl: profileImage,
                                  placeholder: (_, __) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (_, __, ___) => Center(
                                    child: Icon(Icons.error),
                                  ),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              )
                        : InkWell(
                            onTap: () {
                              pickCover();
                            },
                            child: Container(
                              width: double.infinity,
                              child: Image(
                                fit: BoxFit.cover,
                                image: MemoryImage(uint8listImage!),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
