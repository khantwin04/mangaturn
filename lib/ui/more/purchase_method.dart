import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/custom_widgets/loading_alert.dart';
import 'package:mangaturn/models/firestore_models/payload.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/models/user_models/requestPointModel.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/more/purchase_history.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mangaturn/services/bloc/post/buy_point_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';

class PurchaseMethod extends StatefulWidget {
  GetUserModel user;

  PurchaseMethod({required this.user});

  @override
  _PurchaseMethodState createState() => _PurchaseMethodState();
}

class _PurchaseMethodState extends State<PurchaseMethod> {
  late ApiRepository _apiRepository;
  late String token;
  RequestPointModel request = RequestPointModel();

  void getToken() {
    setState(() {
      token = AuthFunction.getToken()!;
    });
    print(token);
  }

  Uint8List? _image;
  String imgExt = "data:image/png;base64,";
  String? img64;

  Future<void> getImage() async {
    List<Asset> resultList = [];
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        // selectedAssets: images,

        androidOptions: const AndroidOptions(
          maxImages: 300,
          hasCameraInPickerPage: true,
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
          _image = value.buffer.asUint8List();
          img64 = Utility.base64String(value.buffer.asUint8List());
          request.receipt = img64;
        });
      });
    }
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    getToken();
    _apiRepository = new ApiRepository(getIt.call());
    super.initState();
  }

  void newRequetPoint() {
    BlocProvider.of<BuyPointCubit>(context).submit(request, widget.user);
    setState(() {
      img64 = null;
      _image = null;
      request = RequestPointModel();
    });
  }

  void requetPoint() {
    LoadingAlert(context);
    _apiRepository.requestPointPurchase(request, token).then((value) async {
      PayloadNotification notification = PayloadNotification(
        title: 'Filling point to account',
        body: 'From ${widget.user.username}',
        sound: 'default',
        image: '${widget.user.profileUrl}',
      );

      PayloadData data = PayloadData(
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        mangaId: widget.user.id.toString(),
        mangaName: widget.user.username,
        mangaCover: widget.user.profileUrl!,
      );

      Payload payload = Payload(
        to: '/topics/pointRequest',
        priority: "high",
        notification: notification,
        data: data,
      );
      await _apiRepository.sendNotification(payload);
      Navigator.of(context).pop();
      AlertError(
          context: context,
          content:
              'We will confirm your purchase within 24 hours and you can check your previous purchase success or not in your purchase history',
          title: 'Successfully Submitted');
      setState(() {
        img64 = null;
        _image = null;
      });
      /*_api.PointReclaimNoti(
            title: "Point Request From Reader",
            body: "Date: ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}"
        ); */
    }).catchError((e) {
      print(e.toString());
      Navigator.of(context).pop();
      AlertError(
          context: context,
          content: "Receipt can\'t be blank.",
          title: 'Sorry');
    });
  }

  int index = 0;

  List<Widget> _children = [];

  late FToast fToast;

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.greenAccent,
      ),
      child: Text(text),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                bool isInstalled =
                    await DeviceApps.isAppInstalled('mm.com.wavemoney.wavepay');
                if (isInstalled) {
                  FlutterClipboard.copy('09422924858')
                      .then((value) => print('copied'));
                  await DeviceApps.openApp('mm.com.wavemoney.wavepay');
                } else {
                  _showToast('You don\'t have Wave Pay App.');
                }
              },
              trailing: IconButton(
                  onPressed: () {
                    FlutterClipboard.copy('09422924858')
                        .then((value) => _showToast('Copied'));
                  },
                  icon: Icon(Icons.copy)),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  'https://play-lh.googleusercontent.com/rPq4GMCZy12WhwTlanEu7RzxihYCgYevQHVHLNha1VcY5SU1uLKHMd060b4VEV1r-OQ',
                ),
              ),
              title: Text('Wave Pay'),
              subtitle: Text(
                'ဖုန်းနံပါတ်အလိုအလျောက်copy ကူးပြီး ယခု appကိုသွားဖွင့်ရန် နှိပ်ပါ။ ဖုန်းနံပါတ် - 09422924858',
                style: TextStyle(fontSize: 12),
              ),
            ),
            ListTile(
              onTap: () async {
                bool isInstalled =
                    await DeviceApps.isAppInstalled('com.kbzbank.kpaycustomer');
                if (isInstalled) {
                  FlutterClipboard.copy('09422924858')
                      .then((value) => print('copied'));
                  await DeviceApps.openApp('com.kbzbank.kpaycustomer');
                } else {
                  _showToast('You don\'t have KBZ Pay App.');
                }
              },
              trailing: IconButton(
                  onPressed: () {
                    FlutterClipboard.copy('09422924858')
                        .then((value) => _showToast('Copied'));
                  },
                  icon: Icon(Icons.copy)),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                    'https://img1.wsimg.com/isteam/ip/151ba070-ac09-4cf9-8410-1643f3db331a/KBZ%20Pay%20Life%20Cover.png/:/cr=t:0%25,l:0%25,w:100%25,h:100%25/rs=w:400,cg:true'),
              ),
              title: Text('KBZ Pay'),
              subtitle: Text(
                'ဖုန်းနံပါတ်အလိုအလျောက်copy ကူးပြီး ယခု appကိုသွားဖွင့်ရန် နှိပ်ပါ။ ဖုန်းနံပါတ် - 09422924858',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Divider(
              thickness: 2,
              indent: 10.0,
              endIndent: 10.0,
            ),
            Container(
              padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 10),
              child: Text(
                'ငွေလွှဲပြီးပါက ဤနေရာမှ Screenshotနဲ့ မိမိအသိပေးချင်သော စာရေး၍ ပို့လိုက်ပါ။ Adminမှ ၂၄နာရီအတွင်း အကြောင်းပြန်ပါလိမ့်မယ်။ ပို့ထားခဲ့ဖူးသောအကြောင်းအရာများကို Historyခေါင်းစဉ်အောက်တွင် ဝင်ရောက်ကြည့်ရှုနိုင်ပါသည်။ \n[ 1 Kyat = 1 Point ]',
                style: TextStyle(fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            ),
            BlocBuilder<BuyPointCubit, BuyPointState>(
              builder: (context, state) {
                if (state is BuyPointLoading) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is BuyPointFail) {
                  return Container(
                    height: 300,
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state.error.toString()),
                          ElevatedButton(
                              onPressed: () {
                                BlocProvider.of<BuyPointCubit>(context)
                                    .emit(BuyPointInitial());
                              },
                              child: Text('Retry')),
                        ],
                      ),
                    ),
                  );
                } else if (state is BuyPointSuccess) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Successfully submitted.\n Admin will confirm your request within 24 hours.',
                            textAlign: TextAlign.center,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                BlocProvider.of<BuyPointCubit>(context)
                                    .emit(BuyPointInitial());
                              },
                              child: Text('Submit Another')),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              height: 200,
                              width: 150,
                              child: Icon(Icons.add),
                              color: _image == null ? Colors.black26 : null,
                              decoration: _image == null
                                  ? null
                                  : BoxDecoration(
                                      image: DecorationImage(
                                        image: MemoryImage(_image!),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Your message',
                                hintText: 'About your name or something.',
                              ),
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (submit) {},
                              keyboardType: TextInputType.multiline,
                              maxLines: 8,
                              onChanged: (String val) {
                                request.remark = val;
                              },
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: request.receipt == null
                              ? null
                              : () {
                                  newRequetPoint();
                                },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text(
                            'Submit ScreenShot',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      PurchaseHistory(),
    ];

    return DefaultTabController(
      initialIndex: index,
      length: 2,
      child: Scaffold(
        appBar: new AppBar(
          title: Text('Buy the point'),
          bottom: TabBar(
            onTap: (page) {
              setState(() {
                index = page;
              });
            },
            tabs: [
              Tab(
                text: 'Purchase Here',
              ),
              Tab(
                text: 'History',
              ),
            ],
          ),
        ),
        body: _children[index],
      ),
    );
  }
}
