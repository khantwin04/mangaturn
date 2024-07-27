import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/models/manga_models/genre_model.dart';
import 'package:mangaturn/models/manga_models/insert_manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/models/manga_models/update_manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_update_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/services/bloc/post/edit_manga_cubit.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

enum Status { OnGoing, Completed }

enum Update { Daily, Weekly, Normal }

class EditManga extends StatefulWidget {
  static const String routeName = 'edit_manga';

  @override
  _EditMangaState createState() => _EditMangaState();
}

class _EditMangaState extends State<EditManga> {
  late int id;
  String name = '';
  String otherNames = '';
  String author = '';
  Status status = Status.OnGoing;
  Update update = Update.Normal;
  late int publishedDateInMilliSeconds;
  String description = '';
  List<int> genreIntList = [];
  List<String> genreStringList = [];
  String? coverImageBase64;
  String? coverImage;
  bool newManga = true;
  List<GenreModel> chosenList = [];
  Uint8List? _uint8listImage;
  final _formKey = GlobalKey<FormState>();
  bool newImage = false;
  bool isAdult = false;

  Future<void> pickCover() async {
    if (!newManga)
      setState(() {
        newImage = true;
      });

    List<Asset> resultList = [];
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        // selectedAssets: images,
        androidOptions: AndroidOptions(
          maxImages: 1,
          lightStatusBar: true,
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
          coverImageBase64 = Utility.base64String(value.buffer.asUint8List());
          _uint8listImage = value.buffer.asUint8List();
        });
      });
    }
  }

  initialVariable(MangaModel? model) async {
    if (model == null) {
      newManga = true;
      name = '';
      otherNames = '';
      author = '';
      status = Status.OnGoing;
      update = Update.Normal;
      publishedDateInMilliSeconds = 0;
      description = '';
      genreIntList = [];
      genreStringList = [];
    } else {
      id = model.id;
      isAdult = model.isAdult ?? false;
      name = model.name!;
      newManga = false;
      otherNames = model.otherNames!;
      author = model.author!;
      status = model.status == "OnGoing" ? Status.OnGoing : Status.Completed;
      if (model.update == "Daily") {
        update = Update.Daily;
      } else if (model.update == "Weekly") {
        update = Update.Weekly;
      } else {
        update = Update.Normal;
      }
      publishedDateInMilliSeconds = 0;
      description = model.description!;
      coverImage = model.coverImagePath!;
      genreIntList = model.genreList!.map((e) => e.id).toList();
      genreStringList = model.genreList!.map((e) => e.name).toList();
      chosenList.addAll(model.genreList!);
      coverImageBase64 = await Utility.NetworkImageToBase64Prefix(coverImage!);
    }
  }

  void uploadNewManga() {
    if (_formKey.currentState!.validate()) {
      if (genreStringList.isEmpty) {
        AlertError(
            context: context,
            title: 'Genres Required',
            content: 'You need to pick genres.');
      } else if (coverImageBase64 == null) {
        AlertError(
            context: context,
            title: 'Cover Photo Required',
            content: 'Upload cover photo');
      } else {
        InsertMangaModel insertModel = InsertMangaModel(
          name: name,
          otherNames: otherNames,
          author: author,
          description: description,
          status: status.toString().split('.').last,
          update: update.toString().split('.').last,
          genre: genreIntList,
          coverImage: coverImageBase64!,
          isAdult: isAdult,
        );
        BlocProvider.of<EditMangaCubit>(context).insertNewManga(insertModel);
      }
    }
  }

  void updateOldManga() async {
    if (newImage) {
      await Utility.deleteImageFromCache(coverImage!);
      await DefaultCacheManager().removeFile(coverImage!);
    }
    if (_formKey.currentState!.validate()) {
      if (genreStringList.isEmpty) {
        AlertError(
            context: context,
            title: 'Genres Required',
            content: 'You need to pick genres.');
      } else if (coverImageBase64 == null) {
        AlertError(
            context: context,
            title: 'Cover Photo Required',
            content: 'Upload cover photo');
      } else {
        UpdateMangaModel updateMangaModel = UpdateMangaModel(
          id: id,
          name: name,
          otherNames: otherNames,
          author: author,
          description: description,
          status: status.toString().split('.').last,
          update: update.toString().split('.').last,
          genre: genreIntList,
          coverImage: coverImageBase64!,
          isAdult: isAdult,
        );
        BlocProvider.of<EditMangaCubit>(context)
            .updateOldManga(updateMangaModel);
      }
    }
  }

  @override
  void didChangeDependencies() {
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null) {
      initialVariable(arg as MangaModel);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: newManga ? Text('Upload New') : Text('Edit'),
      ),
      body: BlocConsumer<EditMangaCubit, EditMangaState>(
        listener: (context, state) {
          if (state is EditMangaSuccess) {
            if (newManga) {
              BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
              BlocProvider.of<GetUploadedMangaBloc>(context).setPage = 0;
              BlocProvider.of<GetUploadedMangaBloc>(context)
                  .add(GetUploadedMangaReload());
              BlocProvider.of<GetAllMangaCubit>(context).clear();
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("views", "desc", 0);
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("name", "asc", 0);
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("updated_Date", "desc", 0);
              BlocProvider.of<GetMangaByNameBloc>(context).setPage = 0;
              BlocProvider.of<GetMangaByNameBloc>(context)
                  .add(GetMangaByNameReload());
              BlocProvider.of<GetMangaByUpdateBloc>(context).setPage = 0;
              BlocProvider.of<GetMangaByUpdateBloc>(context)
                  .add(GetMangaByUpdateReload());
              Navigator.of(context)
                  .pop(['success', state.id, name, state.cover, description]);
            } else {
              BlocProvider.of<GetUploadedMangaBloc>(context).setPage = 0;
              BlocProvider.of<GetUploadedMangaBloc>(context)
                  .add(GetUploadedMangaReload());
              BlocProvider.of<GetAllMangaCubit>(context).clear();
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("views", "desc", 0);
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("name", "asc", 0);
              BlocProvider.of<GetAllMangaCubit>(context)
                  .fetchAllManga("updated_Date", "desc", 0);
              BlocProvider.of<GetMangaByNameBloc>(context).setPage = 0;
              BlocProvider.of<GetMangaByNameBloc>(context)
                  .add(GetMangaByNameReload());
              BlocProvider.of<GetMangaByUpdateBloc>(context).setPage = 0;
              BlocProvider.of<GetMangaByUpdateBloc>(context)
                  .add(GetMangaByUpdateReload());
              Navigator.of(context).pop(id);
            }
          }
        },
        builder: (context, state) {
          if (state is EditMangaLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is EditMangaFail) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.error),
                  ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<EditMangaCubit>(context)
                            .emit(EditMangaInitial());
                      },
                      child: Text('Retry')),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          pickCover();
                        },
                        child: Container(
                          height: 180,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10.0),
                            image: _uint8listImage == null
                                ? coverImage == null
                                    ? null
                                    : DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          coverImage!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                : DecorationImage(
                                    image: MemoryImage(_uint8listImage!),
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          child: Icon(Icons.add),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Chapter Update',
                              style: TextStyle(fontSize: 20),
                            ),
                            DropdownButton(
                                underline: Container(),
                                style: TextStyle(
                                    color: Colors.indigo, fontSize: 18),
                                value: update,
                                onChanged: (Update? data) {
                                  if (data == null) {
                                    setState(() {
                                      update = Update.Normal;
                                    });
                                  } else {
                                    setState(() {
                                      update = data;
                                    });
                                  }
                                },
                                items: [
                                  DropdownMenuItem(
                                      child: Text(
                                        'Normal',
                                      ),
                                      value: Update.Normal),
                                  DropdownMenuItem(
                                      child: Text('Daily'),
                                      value: Update.Daily),
                                  DropdownMenuItem(
                                    child: Text('Weekly'),
                                    value: Update.Weekly,
                                  ),
                                ]),
                            Text(
                              'Status',
                              style: TextStyle(fontSize: 20),
                            ),
                            DropdownButton(
                                style: TextStyle(
                                    color: Colors.indigo, fontSize: 18),
                                underline: Container(),
                                value: status,
                                onChanged: (Status? data) {
                                  setState(() {
                                    status = data!;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(
                                    child: Text('OnGoing'),
                                    value: Status.OnGoing,
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Completed'),
                                    value: Status.Completed,
                                  ),
                                ]),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  genreStringList.length == 0
                      ? Container(
                          width: double.infinity,
                          child: Text(
                            'You have to pick genres',
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Container(
                          padding: EdgeInsets.all(5.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Wrap(
                              children: genreStringList
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Chip(label: Text(e)),
                                      ))
                                  .toList()),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            final data = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PickGenre(
                                    chosenList: chosenList,
                                  ),
                                  fullscreenDialog: true,
                                ));
                            print(data.length);
                            setState(() {
                              chosenList = [];
                              chosenList.addAll(data);
                              genreStringList = [];
                              genreStringList =
                                  chosenList.map((e) => e.name).toList();
                              genreIntList = [];
                              genreIntList =
                                  chosenList.map((e) => e.id).toList();
                            });
                          },
                          child: Text('Pick Genres'))),
                  CheckboxListTile(
                    subtitle: Text('Default value will be false.'),
                    title: Text('Is this manga 18+?'),
                    value: isAdult,
                    onChanged: (value) {
                      setState(() {
                        isAdult = value!;
                      });
                    },
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                            initialVal: name,
                            context: context,
                            label: 'Original name',
                            hintText: 'Most well-known name',
                            validatorText: 'Required',
                            action: newManga
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onChange: (data) {
                              name = data;
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                            initialVal: otherNames,
                            context: context,
                            label: 'Other names',
                            hintText: 'Other names of manga',
                            validatorText: 'Required',
                            action: newManga
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onChange: (data) {
                              otherNames = data;
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                            initialVal: author,
                            context: context,
                            label: 'Author',
                            hintText: 'Author name',
                            validatorText: 'Required',
                            action: newManga
                                ? TextInputAction.next
                                : TextInputAction.done,
                            onChange: (data) {
                              author = data;
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        CustomTextField(
                            initialVal: description,
                            context: context,
                            hintText: 'Tell readers more about manga',
                            validatorText: 'Required',
                            action: TextInputAction.newline,
                            inputType: TextInputType.multiline,
                            maxLines: 30,
                            onChange: (data) {
                              description = data;
                            }),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () async {
                            newManga ? uploadNewManga() : updateOldManga();
                          },
                          child: newManga
                              ? Text('Upload new manga')
                              : Text('Update manga'))),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class PickGenre extends StatefulWidget {
  List<GenreModel> chosenList;

  PickGenre({required this.chosenList});

  @override
  _PickGenreState createState() => _PickGenreState();
}

class _PickGenreState extends State<PickGenre> {
  List<GenreModel> chooseList = [];

  @override
  void initState() {
    chooseList = widget.chosenList;
    super.initState();
  }

  bool containsKey(int id) {
    for (int i = 0; i < chooseList.length; i++) {
      if (chooseList[i].id == id) {
        print(chooseList[i].name);
        return true;
      }
    }
    return false;
  }

  void removeValue(int id) {
    for (int i = 0; i < chooseList.length; i++) {
      if (chooseList[i].id == id) {
        chooseList.removeAt(i);
      }
    }
  }

  Future<bool> back() async {
    Navigator.of(context).pop(chooseList);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: back,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Pick Genres'),
          leading: IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              back();
            },
          ),
        ),
        body: BlocBuilder<GetAllGenreCubit, GetAllGenreState>(
          builder: (context, state) {
            if (state is GetAllGenreSuccess) {
              List<GenreModel> genreList = state.genreList;
              return ListView.builder(
                itemCount: genreList.length,
                itemBuilder: (context, index) {
                  GenreModel genre = genreList[index];
                  return Container(
                    color: containsKey(genre.id)
                        ? Colors.blue[100]
                        : Colors.transparent,
                    child: ListTile(
                        title: Text(genre.name),
                        onTap: () {
                          setState(() {
                            containsKey(genre.id)
                                ? removeValue(genre.id)
                                : chooseList.add(genre);
                          });
                        }),
                  );
                },
              );
            } else if (state is GetAllGenreFail) {
              return Center(child: Text(state.error));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
