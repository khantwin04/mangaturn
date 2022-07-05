import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/config/constants.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/post/sign_up_cubit.dart';
import 'package:mangaturn/ui/more/purchase_method.dart';
import 'package:mangaturn/ui/more/update_user_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/custom_widgets/versionAlertBox.dart';

class MoreView extends StatelessWidget {
  void logOut(BuildContext context) {
    BlocProvider.of<SignUpCubit>(context).logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'More',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                logOut(context);
                SystemNavigator.pop();
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(10.0),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  horizontalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
                    builder: (context, state) {
                      if (state is GetUserProfileSuccess) {
                        if (state.user.role == 'USER') {
                          return Column(
                            children: [
                              ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(40.0),
                                  child: state.user.profileUrl == null
                                      ? Container(
                                          color: Colors.grey,
                                          height: 50,
                                          width: 50)
                                      : CachedNetworkImage(
                                          imageUrl: state.user.profileUrl!,
                                          height: 50,
                                          width: 50,
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                          placeholder: (_, __) => Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                          errorWidget: (_, ___, ____) => Center(
                                            child: Icon(Icons.error),
                                          ),
                                        ),
                                ),
                                title: Text(state.user.username),
                                subtitle: Text('Edit your profile'),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    UpdateUserInfoModel update =
                                        UpdateUserInfoModel(
                                      id: state.user.id,
                                      username: state.user.username,
                                      payment: state.user.payment,
                                      description: state.user.description,
                                      profile: state.user.profileUrl,
                                      type: state.user.type,
                                    );
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UpdateUserInfoView(
                                                    update, false)));
                                  },
                                ),
                              ),
                              Divider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                              ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PurchaseMethod(user: state.user),
                                      ));
                                },
                                leading: Icon(
                                  Icons.account_balance_wallet,
                                  size: 30,
                                ),
                                title: Text('Your Wallet'),
                                subtitle: Text(
                                    state.user.point.toString() + " Point"),
                                trailing: IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PurchaseMethod(user: state.user),
                                        ));
                                  },
                                ),
                              ),
                              Divider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      } else if (state is GetUserProfileFail) {
                        return Center(
                          child: Text(state.error),
                        );
                      } else {
                        return Column(
                          children: [
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(40.0),
                                child: Image.asset(
                                  'assets/test_img/1.jpg',
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                ),
                              ),
                              title: Text('Loading..'),
                              subtitle: Text('Loading'),
                              trailing: IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {},
                              ),
                            ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.account_balance_wallet,
                                size: 30,
                              ),
                              title: Text('Your Wallet'),
                              subtitle: Text('0 Point'),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () {},
                              ),
                            ),
                            Divider(
                              indent: 10,
                              endIndent: 10,
                              thickness: 1,
                              color: Colors.grey,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.people,
                      color: Colors.black,
                      size: 30,
                    ),
                    title: Text('About Us'),
                    subtitle: Text(
                      'We are just normal guys and we developed this app in order to help readers, fan-sub translators and original comic creators.',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      Utility.launchURL(
                          'https://mangaturn.games/files/download.html');
                    },
                    leading: Icon(
                      Icons.web,
                      color: Colors.indigo,
                      size: 30,
                    ),
                    title: Text('Our website'),
                    subtitle:
                        Text('https://mangaturn.games/files/download.html'),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      Utility.launchURL(
                          'https://discord.com/invite/637xk6PaSx');
                    },
                    leading: FaIcon(
                      FontAwesomeIcons.discord,
                      color: Colors.blueAccent,
                      size: 35,
                    ),
                    title: Text('Want to upload yours?'),
                    subtitle: Text('Click on this tab to join'),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  ListTile(
                    leading:
                        Icon(Icons.info, size: 30, color: Colors.redAccent),
                    title: Text('Disclaimer'),
                    subtitle: Text(
                      'Every comic are owned by original authors and creators. We are just a bridge between readers and uploaders.',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  Divider(
                    indent: 10,
                    endIndent: 10,
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.app_registration,
                      size: 30,
                      color: Colors.green,
                    ),
                    title: Text('App Version'),
                    subtitle: Text(Constant.versionNumber.toString()),
                    trailing: IconButton(
                        icon: Icon(Icons.update),
                        onPressed: () {
                          BlocProvider.of<VersionCubit>(context).checkVersion();
                          versionAlertBox(context);
                        }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
