import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/search_manga_by_name_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';
import 'package:mangaturn/ui/home/search_with_genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/ui/workspace/comic_detail.dart';

class Search extends StatefulWidget {
  final bool isAdmin;
  Search({this.isAdmin = false});

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int page = 0;
  late String mangaName;
  late String uploaderName;
  int uploaderPage = 0;
  late String adminName;
  int adminPage = 0;
  int tabIndex = 0;
  List<MangaModel>? searchResult;
  List<MangaModel>? uploaderResult;
  List<GetUserModel>? adminResult;

  ScrollController? _controller;
  ScrollController? _uploaderController;
  ScrollController? _adminController;

  bool moreMangaLoading = false;
  bool moreUploaderLoading = false;
  bool moreAdminLoading = false;

  _scrollListener() {
    var isEnd = _controller!.offset >= _controller!.position.maxScrollExtent &&
        !_controller!.position.outOfRange;
    if (isEnd) {
      setState(() {
        ++page;
        BlocProvider.of<SearchMangaByNameCubit>(context)
            .searchMangaByName(mangaName, page);
      });
    }
  }

  _uploaderListener() {
    var isEnd = _uploaderController!.offset >=
            _uploaderController!.position.maxScrollExtent &&
        !_uploaderController!.position.outOfRange;
    if (isEnd) {
      setState(() {
        ++uploaderPage;
        BlocProvider.of<SearchMangaByNameCubit>(context)
            .searchMangaByUploader(uploaderName, uploaderPage);
      });
    }
  }

  _adminListener() {
    var isEnd = _adminController!.offset >=
            _adminController!.position.maxScrollExtent &&
        !_adminController!.position.outOfRange;
    if (isEnd) {
      setState(() {
        ++adminPage;
        BlocProvider.of<SearchMangaByNameCubit>(context)
            .searchUploaderByName(adminName, adminPage);
      });
    }
  }

  @override
  void initState() {
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller!.addListener(_scrollListener);
    _uploaderController =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _uploaderController!.addListener(_uploaderListener);
    _adminController =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _adminController!.addListener(_adminListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
    _uploaderController!.dispose();
    _adminController!.dispose();
  }

  @override
  void didChangeDependencies() {
    BlocProvider.of<SearchMangaByNameCubit>(context)
        .emit(SearchMangaByNameInitial());
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    searchResult =
        BlocProvider.of<SearchMangaByNameCubit>(context).getSearchResult();
    uploaderResult =
        BlocProvider.of<SearchMangaByNameCubit>(context).getUploaderResult();
    adminResult = BlocProvider.of<SearchMangaByNameCubit>(context)
        .getUploaderNameResult();

    return DefaultTabController(
      length: widget.isAdmin ? 1 : 4,
      initialIndex: tabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Search',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          bottom: widget.isAdmin
              ? TabBar(
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      tabIndex = index;
                    });
                  },
                  tabs: [
                    Tab(
                      text: 'By Manga',
                    ),
                  ],
                )
              : TabBar(
                  isScrollable: true,
                  onTap: (index) {
                    setState(() {
                      tabIndex = index;
                    });
                  },
                  tabs: [
                    Tab(
                      text: 'By Manga',
                    ),
                    Tab(text: 'By Uploader'),
                    Tab(text: 'By Genre'),
                    Tab(text: 'Search uploader')
                  ],
                ),
        ),
        body: widget.isAdmin
            ? TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            //icon: Icon(Icons.person),
                            labelText: "Search manga name",
                            labelStyle: TextStyle(color: Colors.black),
                            suffixIcon: Icon(Icons.search),
                          ),
                          onFieldSubmitted: (String? data) {
                            if (data == null) {
                              setState(() {
                                mangaName = '';
                                page = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByName(mangaName, page);
                              });
                            } else {
                              print(data);
                              setState(() {
                                mangaName = data;
                                page = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByName(mangaName, page);
                              });
                            }
                          },
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.name,
                          onChanged: (data) {},
                        ),
                        Expanded(
                          child: BlocConsumer<SearchMangaByNameCubit,
                              SearchMangaByNameState>(
                            listener: (context, state) {
                              if (state is SearchMangaByNameSuccess) {
                                if (mounted) {
                                  setState(() {
                                    moreMangaLoading = false;
                                  });
                                }
                              } else if (state is SearchMangaByNameLoading &&
                                  page != 0) {
                                if (mounted) {
                                  setState(() {
                                    moreMangaLoading = true;
                                  });
                                }
                              }
                            },
                            builder: (context, state) {
                              if (state is SearchMangaByNameFail) {
                                return Center(
                                  child: Text(state.error),
                                );
                              } else if (state is SearchMangaByNameLoading &&
                                  page == 0) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListView.builder(
                                  controller: _controller,
                                  itemCount: searchResult!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        if (widget.isAdmin) {
                                          Navigator.pushNamed(context,
                                              ComicDetailAdminView.routeName,
                                              arguments: [
                                                searchResult![index],
                                                null
                                              ]);
                                        } else {
                                          Navigator.pushNamed(
                                              context, ComicDetail.routeName,
                                              arguments: [
                                                searchResult![index],
                                                null
                                              ]);
                                        }
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: CachedNetworkImage(
                                          width: 50,
                                          imageUrl: searchResult![index]
                                              .coverImagePath!,
                                          errorWidget: (_, __, ___) => Center(
                                            child: Icon(Icons.error),
                                          ),
                                          placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(searchResult![index].name!),
                                      subtitle: Text(
                                          searchResult![index].uploadedBy!),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        moreMangaLoading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Column(
                  //     children: [
                  //       TextFormField(
                  //         decoration: InputDecoration(
                  //           focusedBorder: OutlineInputBorder(),
                  //           enabledBorder: OutlineInputBorder(),
                  //           //icon: Icon(Icons.person),
                  //           labelText: "Search manga by uploader full name",
                  //           labelStyle: TextStyle(color: Colors.black),
                  //           suffixIcon: Icon(Icons.search),
                  //         ),
                  //         onFieldSubmitted: (String? data) {
                  //           if (data == null) {
                  //             setState(() {
                  //               uploaderName = 'Manga Turn';
                  //               uploaderPage = 0;
                  //               BlocProvider.of<SearchMangaByNameCubit>(context)
                  //                   .searchMangaByUploader(
                  //                       uploaderName, uploaderPage);
                  //             });
                  //           } else {
                  //             setState(() {
                  //               uploaderName = data;
                  //               uploaderPage = 0;
                  //               BlocProvider.of<SearchMangaByNameCubit>(context)
                  //                   .searchMangaByUploader(
                  //                       uploaderName, uploaderPage);
                  //             });
                  //           }
                  //         },
                  //         textInputAction: TextInputAction.search,
                  //         keyboardType: TextInputType.name,
                  //         onChanged: (data) {},
                  //       ),
                  //       Expanded(
                  //         child: BlocConsumer<SearchMangaByNameCubit,
                  //             SearchMangaByNameState>(
                  //           listener: (context, state) {
                  //             if (state is SearchMangaByNameSuccess) {
                  //               if (mounted) {
                  //                 setState(() {
                  //                   moreUploaderLoading = false;
                  //                 });
                  //               }
                  //             } else if (state is SearchMangaByNameLoading &&
                  //                 uploaderPage != 0) {
                  //               if (mounted) {
                  //                 setState(() {
                  //                   moreUploaderLoading = true;
                  //                 });
                  //               }
                  //             }
                  //           },
                  //           builder: (context, state) {
                  //             if (state is SearchMangaByNameFail) {
                  //               return Center(
                  //                 child: Text(state.error),
                  //               );
                  //             } else if (state is SearchMangaByNameLoading &&
                  //                 uploaderPage == 0) {
                  //               return Center(
                  //                 child: CircularProgressIndicator(),
                  //               );
                  //             } else {
                  //               return ListView.builder(
                  //                 controller: _uploaderController,
                  //                 itemCount: uploaderResult!.length,
                  //                 itemBuilder: (context, index) {
                  //                   return ListTile(
                  //                     onTap: () {
                  //                       if (widget.isAdmin) {
                  //                         Navigator.pushNamed(context,
                  //                             ComicDetailAdminView.routeName,
                  //                             arguments: [
                  //                               uploaderResult![index],
                  //                               null
                  //                             ]);
                  //                       } else {
                  //                         Navigator.pushNamed(
                  //                             context, ComicDetail.routeName,
                  //                             arguments: [
                  //                               uploaderResult![index],
                  //                               null
                  //                             ]);
                  //                       }
                  //                     },
                  //                     leading: ClipRRect(
                  //                       borderRadius: BorderRadius.all(
                  //                           Radius.circular(5.0)),
                  //                       child: CachedNetworkImage(
                  //                         width: 50,
                  //                         imageUrl: uploaderResult![index]
                  //                             .coverImagePath!,
                  //                         errorWidget: (_, __, ___) => Center(
                  //                           child: Icon(Icons.error),
                  //                         ),
                  //                         placeholder: (_, __) => Center(
                  //                           child: CircularProgressIndicator(),
                  //                         ),
                  //                         fit: BoxFit.cover,
                  //                       ),
                  //                     ),
                  //                     title: Text(uploaderResult![index].name!),
                  //                     subtitle: Text(
                  //                         uploaderResult![index].uploadedBy!),
                  //                   );
                  //                 },
                  //               );
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //       moreUploaderLoading
                  //           ? Padding(
                  //               padding: const EdgeInsets.all(8.0),
                  //               child: LinearProgressIndicator(),
                  //             )
                  //           : Container()
                  //     ],
                  //   ),
                  // ),
                ],
              )
            : TabBarView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            //icon: Icon(Icons.person),
                            labelText: "Search manga by name",
                            labelStyle: TextStyle(color: Colors.black),
                            suffixIcon: Icon(Icons.search),
                          ),
                          onFieldSubmitted: (String? data) {
                            if (data == null) {
                              print(data);
                              setState(() {
                                mangaName = '';
                                page = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByName(mangaName, page);
                              });
                            } else {
                              print(data);
                              setState(() {
                                mangaName = data;
                                page = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByName(mangaName, page);
                              });
                            }
                          },
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.name,
                          onChanged: (data) {},
                        ),
                        Expanded(
                          child: BlocConsumer<SearchMangaByNameCubit,
                              SearchMangaByNameState>(
                            listener: (context, state) {
                              if (state is SearchMangaByNameSuccess) {
                                if (mounted) {
                                  setState(() {
                                    moreMangaLoading = false;
                                  });
                                }
                              } else if (state is SearchMangaByNameLoading &&
                                  page != 0) {
                                if (mounted) {
                                  setState(() {
                                    moreMangaLoading = true;
                                  });
                                }
                              }
                            },
                            builder: (context, state) {
                              if (state is SearchMangaByNameFail) {
                                return Center(
                                  child: Text(state.error),
                                );
                              } else if (state is SearchMangaByNameLoading &&
                                  page == 0) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListView.builder(
                                  controller: _controller,
                                  itemCount: searchResult!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        if (widget.isAdmin) {
                                          Navigator.pushNamed(context,
                                              ComicDetailAdminView.routeName,
                                              arguments: [
                                                searchResult![index],
                                                null
                                              ]);
                                        } else {
                                          Navigator.pushNamed(
                                              context, ComicDetail.routeName,
                                              arguments: [
                                                searchResult![index],
                                                null
                                              ]);
                                        }
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: CachedNetworkImage(
                                          width: 50,
                                          imageUrl: searchResult![index]
                                              .coverImagePath!,
                                          errorWidget: (_, __, ___) => Center(
                                            child: Icon(Icons.error),
                                          ),
                                          placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(searchResult![index].name!),
                                      subtitle: Text(
                                          searchResult![index].uploadedBy!),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        moreMangaLoading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            //icon: Icon(Icons.person),
                            labelText: "Search manga by uploader full name",
                            labelStyle: TextStyle(color: Colors.black),
                            suffixIcon: Icon(Icons.search),
                          ),
                          onFieldSubmitted: (String? data) {
                            if (data == null) {
                              setState(() {
                                uploaderName = '';
                                uploaderPage = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByUploader(
                                        uploaderName, uploaderPage);
                              });
                            } else {
                              setState(() {
                                uploaderName = data;
                                uploaderPage = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchMangaByUploader(
                                        uploaderName, uploaderPage);
                              });
                            }
                          },
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.name,
                          onChanged: (data) {},
                        ),
                        Expanded(
                          child: BlocConsumer<SearchMangaByNameCubit,
                              SearchMangaByNameState>(
                            listener: (context, state) {
                              if (state is SearchMangaByNameSuccess) {
                                if (mounted) {
                                  setState(() {
                                    moreUploaderLoading = false;
                                  });
                                }
                              } else if (state is SearchMangaByNameLoading &&
                                  uploaderPage != 0) {
                                if (mounted) {
                                  setState(() {
                                    moreUploaderLoading = true;
                                  });
                                }
                              }
                            },
                            builder: (context, state) {
                              if (state is SearchMangaByNameFail) {
                                return Center(
                                  child: Text(state.error),
                                );
                              } else if (state is SearchMangaByNameLoading &&
                                  uploaderPage == 0) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListView.builder(
                                  controller: _uploaderController,
                                  itemCount: uploaderResult!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        if (widget.isAdmin) {
                                          Navigator.pushNamed(context,
                                              ComicDetailAdminView.routeName,
                                              arguments: [
                                                uploaderResult![index],
                                                null
                                              ]);
                                        } else {
                                          Navigator.pushNamed(
                                              context, ComicDetail.routeName,
                                              arguments: [
                                                uploaderResult![index],
                                                null
                                              ]);
                                        }
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: CachedNetworkImage(
                                          width: 50,
                                          imageUrl: uploaderResult![index]
                                              .coverImagePath!,
                                          errorWidget: (_, __, ___) => Center(
                                            child: Icon(Icons.error),
                                          ),
                                          placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      title: Text(uploaderResult![index].name!),
                                      subtitle: Text(
                                          uploaderResult![index].uploadedBy!),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        moreUploaderLoading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              )
                            : Container()
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: BlocBuilder<GetAllGenreCubit, GetAllGenreState>(
                      builder: (context, state) {
                        if (state is GetAllGenreSuccess) {
                          return ListView.builder(
                            itemCount: state.genreList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  onTap: () {
                                    print(state.genreList[index].id);
                                    Navigator.pushNamed(
                                        context, SearchWithGenre.routeName,
                                        arguments: [
                                          state.genreList[index].id,
                                          state.genreList[index].name,
                                        ]);
                                  },
                                  title: Text(state.genreList[index].name));
                            },
                          );
                        } else if (state is GetAllGenreFail) {
                          return Center(
                            child: Text(state.error),
                          );
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(),
                            //icon: Icon(Icons.person),
                            labelText: "Search uploader by name",
                            labelStyle: TextStyle(color: Colors.black),
                            suffixIcon: Icon(Icons.search),
                          ),
                          onFieldSubmitted: (String? data) {
                            if (data == null) {
                              setState(() {
                                adminName = '';
                                adminPage = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchUploaderByName(adminName, adminPage);
                              });
                            } else {
                              setState(() {
                                adminName = data;
                                adminPage = 0;
                                BlocProvider.of<SearchMangaByNameCubit>(context)
                                    .searchUploaderByName(adminName, adminPage);
                              });
                            }
                          },
                          textInputAction: TextInputAction.search,
                          keyboardType: TextInputType.name,
                          onChanged: (data) {},
                        ),
                        Expanded(
                          child: BlocConsumer<SearchMangaByNameCubit,
                              SearchMangaByNameState>(
                            listener: (context, state) {
                              if (state is SearchMangaByNameSuccess) {
                                if (mounted) {
                                  setState(() {
                                    moreAdminLoading = false;
                                  });
                                }
                              } else if (state is SearchMangaByNameLoading &&
                                  adminPage != 0) {
                                if (mounted) {
                                  setState(() {
                                    moreAdminLoading = true;
                                  });
                                }
                              }
                            },
                            builder: (context, state) {
                              if (state is SearchMangaByNameFail) {
                                return Center(
                                  child: Text(state.error),
                                );
                              } else if (state is SearchMangaByNameLoading &&
                                  adminPage == 0) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return ListView.builder(
                                  controller: _adminController,
                                  itemCount: adminResult!.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => UploaderInfo(
                                              uploader: adminResult![index],
                                              id: null,
                                            ),
                                          ),
                                        );
                                      },
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5.0)),
                                        child: adminResult![index].profileUrl ==
                                                    null ||
                                                adminResult![index]
                                                        .profileUrl ==
                                                    ''
                                            ? Container(
                                                width: 50,
                                                color: Colors.grey[100],
                                              )
                                            : CachedNetworkImage(
                                                width: 50,
                                                imageUrl: adminResult![index]
                                                    .profileUrl!,
                                                errorWidget: (_, __, ___) =>
                                                    Center(
                                                  child: Icon(Icons.error),
                                                ),
                                                placeholder: (_, __) => Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      title: Text(adminResult![index].username),
                                      subtitle: Text(adminResult![index].role!),
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                        moreAdminLoading
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              )
                            : Container()
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
