import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/home/search_with_genre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color/random_color.dart';
import 'package:shimmer/shimmer.dart';

class PopularGenre extends StatefulWidget {
  @override
  _PopularGenreState createState() => _PopularGenreState();
}

class _PopularGenreState extends State<PopularGenre> {
  List<String> genreList = [];
  RandomColor randomColor = RandomColor();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BlocBuilder<GetAllMangaCubit, GetAllMangaState>(
        builder: (context, state) {
          if (state is GetAllMangaSuccess) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: state.mangaList
                    .map((e) {
                      return e.genreList![0].name;
                    })
                    .toList()
                    .toSet()
                    .toList()
                    .map((e) {
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                              context, SearchWithGenre.routeName,
                              arguments: [
                                null,
                                e,
                              ]);
                        },
                        child: Container(
                          height: 50,
                          margin: EdgeInsets.only(left: 10.0),
                          width: 100,
                          decoration: BoxDecoration(
                            color: randomColor.randomColor(
                              colorBrightness: ColorBrightness.dark,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Center(
                              child: Text(
                            e,
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                        ),
                      );
                    })
                    .toList(),
              ),
            );
          } else if (state is GetAllMangaFail) {
            return Center(
              child: Text(state.error),
            );
          } else {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              enabled: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 10.0),
                      width: 100,
                      decoration: BoxDecoration(
                        color: randomColor.randomColor(
                          colorBrightness: ColorBrightness.dark,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(
                          child: Text(
                        "Loading",
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      )),
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
