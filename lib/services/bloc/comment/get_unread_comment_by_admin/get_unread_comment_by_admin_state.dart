part of 'get_unread_comment_by_admin_cubit.dart';

abstract class GetUnreadCommentByAdminState extends Equatable {
  const GetUnreadCommentByAdminState();

  @override
  List<Object> get props => [];
}

class GetUnreadCommentByAdminInitial extends GetUnreadCommentByAdminState {}

class GetUnreadCommentByAdminLoading extends GetUnreadCommentByAdminState {}

class GetUnreadCommentByAdminSuccess extends GetUnreadCommentByAdminState {
  final List<GetUnreadCommentByAdmin> cmtList;
  GetUnreadCommentByAdminSuccess(this.cmtList);

  @override
  List<Object> get props => [cmtList];
}

class GetUnreadCommentByAdminFail extends GetUnreadCommentByAdminState {
  final String error;
  GetUnreadCommentByAdminFail(this.error);

  @override
  List<Object> get props => [error];
}
