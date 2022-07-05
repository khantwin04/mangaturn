import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';

Future<dynamic> versionAlertBox(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) {
      return BlocBuilder<VersionCubit, VersionState>(
        builder: (context, state) {
          if (state is VersionSuccess) {
            return AlertDialog(
              title: Text('Checking Finished'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/icon/icon.png'),
                  state.version.update == null
                      ? Text('Your app is up to data.')
                      : Text(state.version.update!),
                ],
              ),
              actions: state.version.update == "UP TO DATE"
                  ? []
                  : [
                      TextButton(
                          onPressed: () {
                            Utility.launchURL(state.version.appLink!);
                          },
                          child: Text('Download Now')),
                      state.version.isForce == null || !state.version.isForce!
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Later'))
                          : Container(),
                    ],
            );
          } else if (state is VersionFail) {
            return AlertDialog(
              title: Text('Oops'),
              content: Text('Some Error Occured'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Okay'))
              ],
            );
          } else {
            return AlertDialog(
              title: Text('Checking new verion'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 10),
                  Center(child: Text('Loading')),
                ],
              ),
            );
          }
        },
      );
    },
  );
}
