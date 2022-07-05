part of 'point_purchase_status_cubit.dart';

abstract class PointPurchaseStatusState extends Equatable {
  const PointPurchaseStatusState();

  @override
  List<Object> get props => [];
}

class PointPurchaseStatusInitial extends PointPurchaseStatusState {}

class PointPurchaseStatusLoading extends PointPurchaseStatusState {}

class PointPurchaseStatusSuccess extends PointPurchaseStatusState {
  final PointPurchaseModel? purchaseModel;
  PointPurchaseStatusSuccess(this.purchaseModel);
  @override
  List<Object> get props => [purchaseModel!];
}

class PointPurchaseStatusFail extends PointPurchaseStatusState {
  final String error;
  PointPurchaseStatusFail(this.error);
  @override
  List<Object> get props => [error];
}
