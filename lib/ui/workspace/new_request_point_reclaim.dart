import 'dart:convert';

import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/customText.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/firestore_models/payload.dart';
import 'package:mangaturn/models/point_model/request_reclaim_model.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Payment { KPay, WavePay }

class NewRequestPointReclaim extends StatefulWidget {
  final int point;
  const NewRequestPointReclaim(this.point, {Key? key}) : super(key: key);

  @override
  _NewRequestPointReclaimState createState() => _NewRequestPointReclaimState();
}

class _NewRequestPointReclaimState extends State<NewRequestPointReclaim> {
  int point = 0;
  Payment payment = Payment.KPay;
  String phoneNumber = '';
  final _formKey = GlobalKey<FormState>();
  late ApiRepository apiRepository;
  late String token;

  void getToken() {
    String? data = AuthFunction.getToken();
    setState(() {
      token = data!;
    });
  }

  @override
  void initState() {
    getToken();
    apiRepository = ApiRepository(getIt.call());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New reclaim point'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
            builder: (context, state) {
              if (state is GetUserProfileSuccess) {
                return Column(
                  children: [
                    CustomTextBox(
                        text: 'You have ${state.user.point} points',
                        color1: Colors.indigo[50]!,
                        color2: Colors.indigo[50]!,
                        align: TextAlign.center,
                        fontSize: 20),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      context: context,
                      validatorText: 'Required',
                      inputType: TextInputType.number,
                      label: 'Exchange Point Amount',
                      action: TextInputAction.done,
                      onChange: (data) {
                        point = int.parse(data);
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomTextBox(
                                text: 'Payment Method',
                                color1: Colors.indigo[50]!,
                                color2: Colors.indigo[50]!,
                                align: TextAlign.center,
                                fontSize: 20),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          DropdownButton(
                              style:
                                  TextStyle(color: Colors.indigo, fontSize: 18),
                              underline: Container(),
                              value: payment,
                              onChanged: (Payment? data) {
                                setState(() {
                                  payment = data!;
                                });
                              },
                              items: [
                                DropdownMenuItem(
                                    child: Text('KPay'), value: Payment.KPay),
                                DropdownMenuItem(
                                    child: Text('WavePay'),
                                    value: Payment.WavePay),
                              ]),
                        ]),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      context: context,
                      validatorText: 'Required',
                      inputType: TextInputType.number,
                      label: 'Your phone number',
                      action: TextInputAction.done,
                      onChange: (data) {
                        phoneNumber = data;
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Request Reclaim'),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            RequestReclaimModel request = RequestReclaimModel(
                              point: point,
                              remark: payment.toString().split('.').last +
                                  "," +
                                  phoneNumber,
                            );
                            print(request.toJson());
                            Loading(context);
                            apiRepository
                                .requestPointReclaim(request, token)
                                .then((value) async {
                              PayloadNotification notification =
                                  PayloadNotification(
                                title: 'Requesting point exchange',
                                body:
                                    'From ${state.user.username}: Point ${point}->${payment.toString()}',
                                image: state.user.profileUrl!,
                                sound: 'default',
                              );

                              PayloadData data = PayloadData(
                                click_action: "FLUTTER_NOTIFICATION_CLICK",
                                mangaId: state.user.id.toString(),
                                mangaName: state.user.username,
                                mangaCover: state.user.profileUrl ?? '',
                              );

                              Payload payload = Payload(
                                to: '/topics/pointReclaim',
                                priority: "high",
                                notification: notification,
                                data: data,
                              );
                              await apiRepository.sendNotification(payload);
                              Navigator.of(context).pop();
                              Navigator.of(context).pop('success');
                            }).catchError((obj) {
                              switch (obj.runtimeType) {
                                case DioError:
                                  final res = (obj as DioError).response;
                                  Navigator.of(context).pop();
                                  AlertError(
                                      context: context,
                                      content: res.toString(),
                                      title: 'Oops');
                                  break;
                                default:
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                );
              } else if (state is GetUserProfileFail) {
                return Center(child: Text(state.error));
              } else {
                return CustomTextBox(
                    text: '..Loading..',
                    color1: Colors.indigo[50]!,
                    color2: Colors.indigo[50]!,
                    align: TextAlign.center,
                    fontSize: 20);
              }
            },
          ),
        ),
      ),
    );
  }
}
