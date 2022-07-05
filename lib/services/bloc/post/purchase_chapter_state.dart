part of 'purchase_chapter_cubit.dart';

abstract class PurchaseChapterState extends Equatable {
  const PurchaseChapterState();
  @override
  List<Object> get props => [];
}

class PurchaseChapterInitial extends PurchaseChapterState {}

class PurchaseChapterFail extends PurchaseChapterState {
  final String error;
  PurchaseChapterFail(this.error);

  @override
  List<Object> get props => [error];
}

class PurchaseChapterLoading extends PurchaseChapterState {}

class PurchaseChapterSuccess extends PurchaseChapterState {}
