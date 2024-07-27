import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_all_user_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_update_bloc.dart';
import 'package:mangaturn/services/bloc/put/update_user_info_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

class UpdateUserInfoView extends StatefulWidget {
  final UpdateUserInfoModel user;
  final bool isAdmin;

  UpdateUserInfoView(this.user, this.isAdmin);

  @override
  _UpdateUserInfoViewState createState() => _UpdateUserInfoViewState();
}

class _UpdateUserInfoViewState extends State<UpdateUserInfoView> {
  final _formKey = GlobalKey<FormState>();
  bool updateImg = false;
  String kpayPhone = '';
  String wavepayPhone = '';
  int _id = 0;

  bool _updateFail = false;

  String _error = '';

  late FocusNode pwdFocus;
  late FocusNode cpwdFocus;
  String _password = '';
  String _confrimPwd = '';
  bool _hidePwd = true;
  bool _hideCpwd = true;

  String imgExt = 'png';
  String? base64Prefix;

  Uint8List? _profileImg;

  String _username = '';
  String? _description;

  void initState() {
    _id = widget.user.id;
    _username = widget.user.username;
    if (widget.user.payment != null && widget.user.payment != '') {
      print(widget.user.payment);
      kpayPhone = json.decode(widget.user.payment!)['kPay'] ?? '';
      wavepayPhone = json.decode(widget.user.payment!)['wavePay'] ?? '';
    }
    _description = widget.user.description;
    pwdFocus = new FocusNode();
    cpwdFocus = new FocusNode();
    base64Prefix = "data:image/" + imgExt + ";base64,";
    super.initState();
  }

  void focusOnCPwd() {
    FocusScope.of(context).requestFocus(cpwdFocus);
  }

  @override
  void dispose() {
    pwdFocus.dispose();
    cpwdFocus.dispose();
    super.dispose();
  }

  void choosePicker() {
    if (Platform.isWindows) {
      //pickImg();
    } else {
      pickImgAndroid();
    }
  }

  Future<void> pickImgAndroid() async {
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
      setState(() {
        updateImg = true;
      });
      await resultList[0].getByteData().then((value) {
        setState(() {
          _profileImg = value.buffer.asUint8List();
        });
      });
    }
  }

  Widget showImage() {
    if (widget.user.profile == null && _profileImg == null) {
      return InkWell(
        onTap: () {
          choosePicker();
        },
        child: Container(
          color: Colors.black26,
          width: 100,
          height: 100,
          child: Icon(Icons.add),
        ),
      );
    } else if (widget.user.profile != null && _profileImg == null) {
      return InkWell(
        onTap: () {
          choosePicker();
        },
        child: CachedNetworkImage(
          imageUrl: widget.user.profile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Center(
            child: Icon(Icons.error),
          ),
          placeholder: (_, __) => Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          choosePicker();
        },
        child: Image.memory(
          _profileImg!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Info'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(
                text: 'Update Info',
              ),
              Tab(text: 'Update Password'),
            ],
          ),
        ),
        body: BlocConsumer<UpdateUserInfoCubit, UpdateUserInfoState>(
          listener: (context, state) {
            if (state is UpdateUserInfoSuccess) {
              if (widget.isAdmin) {
                BlocProvider.of<GetUserProfileCubit>(context, listen: false)
                    .getUserProfile();
                BlocProvider.of<GetAllMangaCubit>(context).clear();
                BlocProvider.of<GetAllMangaCubit>(context)
                    .fetchAllManga("views", "desc", 0);
                BlocProvider.of<GetAllMangaCubit>(context)
                    .fetchAllManga("name", "asc", 0);
                BlocProvider.of<GetAllMangaCubit>(context)
                    .fetchAllManga("updatedDate", "desc", 0);

                BlocProvider.of<GetMangaByGenreIdCubit>(context).clear();
                BlocProvider.of<GetMangaByGenreIdCubit>(context)
                    .fetchMMManga([29769], 0);

                BlocProvider.of<GetMangaByUpdateBloc>(context).setPage = 0;
                BlocProvider.of<GetMangaByUpdateBloc>(context)
                    .add(GetMangaByUpdateReload());

                BlocProvider.of<GetMangaByNameBloc>(context).setPage = 0;
                BlocProvider.of<GetMangaByNameBloc>(context)
                    .add(GetMangaByNameReload());

                BlocProvider.of<GetAllUserBloc>(context).setPage = 0;
                BlocProvider.of<GetAllUserBloc>(context)
                    .add(GetAllUserReload());

                Navigator.of(context).pop();
              } else {
                BlocProvider.of<GetUserProfileCubit>(context, listen: false)
                    .getUserProfile();
                Navigator.of(context).pop();
              }
            }
          },
          builder: (context, state) {
            if (state is UpdateUserInfoLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is UpdateUserInfoFail) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        state.error,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ElevatedButton(
                      child: Text('Try Again'),
                      onPressed: () {
                        BlocProvider.of<UpdateUserInfoCubit>(context)
                            .emit(UpdateUserInfoInitial());
                      },
                    ),
                  ],
                ),
              );
            } else {
              return TabBarView(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        widget.isAdmin
                            ? Text(
                                'You can add link.',
                                textAlign: TextAlign.center,
                              )
                            : Container(),
                        Form(
                          child: Column(
                            children: [
                              _updateFail
                                  ? Container(
                                      padding: EdgeInsets.all(10.0),
                                      child: Text(
                                        '* ' + _error,
                                        style: TextStyle(color: Colors.red),
                                        textAlign: TextAlign.left,
                                      ),
                                    )
                                  : Container(),
                              Row(
                                children: [
                                  showImage(),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          CustomTextField(
                                              initialVal: _username,
                                              context: context,
                                              label: 'Your name',
                                              action: TextInputAction.done,
                                              validatorText: 'Enter your name!',
                                              onChange: (_name) {
                                                setState(() {
                                                  _username = _name;
                                                });
                                              }),
                                          Container(
                                            height: 40,
                                            width: double.infinity,
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              widget.isAdmin == false
                                  ? Container()
                                  : Column(
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            initialVal: wavepayPhone,
                                            context: context,
                                            label: 'WavePay Phone Number',
                                            inputType: TextInputType.number,
                                            action: TextInputAction.done,
                                            onChange: (_val) {
                                              setState(() {
                                                wavepayPhone = _val;
                                              });
                                            }),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            initialVal: kpayPhone,
                                            context: context,
                                            label: 'KPay Phone Number',
                                            inputType: TextInputType.number,
                                            action: TextInputAction.done,
                                            onChange: (_val) {
                                              setState(() {
                                                kpayPhone = _val;
                                              });
                                            }),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        CustomTextField(
                                            hintText: 'About us',
                                            maxLines: 10,
                                            initialVal: _description!,
                                            context: context,
                                            action: TextInputAction.newline,
                                            inputType: TextInputType.multiline,
                                            onChange: (data) {
                                              setState(() {
                                                _description = data;
                                              });
                                            }),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                        Container(
                            padding: EdgeInsets.only(top: 10),
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (updateImg) {
                                    if (widget.user.profile != null) {
                                      await Utility.deleteImageFromCache(
                                          widget.user.profile!);
                                      await DefaultCacheManager()
                                          .removeFile(widget.user.profile!);
                                    }

                                    UpdateUserInfoModel update =
                                        UpdateUserInfoModel(
                                            id: _id,
                                            username: _username,
                                            profile: Utility.base64String(
                                                _profileImg!),
                                            description: _description,
                                            type: widget.user.type,
                                            payment:
                                                '{\"wavePay\":\"$wavepayPhone\",\"kPay\":\"$kpayPhone\"}');
                                    BlocProvider.of<UpdateUserInfoCubit>(
                                            context,
                                            listen: false)
                                        .updateInfo(update);
                                  } else {
                                    UpdateUserInfoModel update =
                                        UpdateUserInfoModel(
                                            id: _id,
                                            username: _username == "" ||
                                                    _username == " "
                                                ? "Unknown"
                                                : _username,
                                            type: widget.user.type,
                                            description: _description,
                                            payment:
                                                '{\"wavePay\":\"$wavepayPhone\",\"kPay\":\"$kpayPhone\"}');
                                    BlocProvider.of<UpdateUserInfoCubit>(
                                            context,
                                            listen: false)
                                        .updateInfo(update);
                                  }
                                },
                                child: Text('Update My Info')))
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    padding: EdgeInsets.all(20.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomPwdField(
                              context: context,
                              label: 'Old password',
                              validatorText: 'Need password!',
                              action: TextInputAction.done,
                              node: pwdFocus,
                              hide: _hidePwd,
                              hideBtn: (value) {
                                setState(() {
                                  _hidePwd = !value;
                                });
                              },
                              onChange: (_pwd) {
                                setState(() {
                                  _password = _pwd;
                                });
                              }),
                          SizedBox(
                            height: 15,
                          ),
                          CustomPwdField(
                              context: context,
                              label: 'New password',
                              action: TextInputAction.done,
                              validatorText: 'Enter new password!',
                              hide: _hideCpwd,
                              hideBtn: (value) {
                                setState(() {
                                  _hideCpwd = !value;
                                });
                              },
                              onChange: (_pwd) {
                                setState(() {
                                  _confrimPwd = _pwd;
                                });
                              }),
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              width: double.infinity,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    UpdateUserPassword pwd = UpdateUserPassword(
                                      newPassword: _confrimPwd,
                                      oldPassword: _password,
                                    );
                                    if (_formKey.currentState!.validate()) {
                                      print(pwd.oldPassword);
                                      print(pwd.newPassword);
                                      BlocProvider.of<UpdateUserInfoCubit>(
                                              context,
                                              listen: false)
                                          .updateUserPassword(pwd);
                                    }
                                  },
                                  child: Text('Update Password'))),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
