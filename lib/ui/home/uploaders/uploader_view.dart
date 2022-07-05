import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/custom_widgets/bottom_sheet/more_uploaders_bt_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mangaturn/services/bloc/get/manga/get_all_user_bloc.dart';
import 'package:mangaturn/ui/all_comic/all_admin_list.dart';

class UploaderView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<GetAllUserBloc>(context).setPage = 0;
          BlocProvider.of<GetAllUserBloc>(context).add(GetAllUserReload());
        },
        child: AllAdminList());
  }
}
