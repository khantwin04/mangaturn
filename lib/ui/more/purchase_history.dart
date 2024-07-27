import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/point_purchase_card.dart';
import 'package:mangaturn/models/user_models/point_purchase_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class PurchaseHistory extends StatefulWidget {
  @override
  _PurchaseHistoryState createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  String url = 'http://146.190.80.28:8080/mt/api';
  late ApiRepository _apiRepository;
  late String token;

  Future<void> getToken() async {
    var data = AuthFunction.getToken();
    setState(() {
      token = data!;
    });
    getData();
  }

  Future<List<PointPurchaseModel>> getPointPurchaseList(
      @required String token, int page) async {
    final response = await http.get(
      Uri.parse('${url}/all-point-purchase?page=$page'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: '${token}',
      },
    );

    print(response.body);
    if (response.statusCode == 200) {
      final parsed = json
          .decode(response.body)['pointPurchaseList']
          .cast<Map<String, dynamic>>();

      return parsed
          .map<PointPurchaseModel>((json) => PointPurchaseModel.fromJson(json))
          .toList();
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  List<PointPurchaseModel> pointPurchaseList = [];
  int page = -1;
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noManga = false;

  void getData() {
    if (!isLoading) {
      setState(() {
        page++;
        isLoading = true;
      });

      getPointPurchaseList(token, page).then((_point) {
        setState(() {
          isLoading = false;
          pointPurchaseList.addAll(_point);
        });
      });
    }
  }

  @override
  void initState() {
    getToken();
    _apiRepository = new ApiRepository(getIt.call());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getData();
      }
    });
    super.initState();
  }

  Widget pointWidget(BuildContext context, int index) {
    if (index == pointPurchaseList.length) {
      return _buildProgressIndicator();
    } else {
      return PointPurchaseCard(context, pointPurchaseList[index], index + 1);
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Visibility(
          visible: isLoading,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemBuilder: pointWidget,
      itemCount: pointPurchaseList.length + 1,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
    );
  }
}
