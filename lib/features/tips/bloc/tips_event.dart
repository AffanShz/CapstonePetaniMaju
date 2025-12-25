part of 'tips_bloc.dart';

/// Events untuk TipsBloc
abstract class TipsEvent extends Equatable {
  const TipsEvent();

  @override
  List<Object?> get props => [];
}

/// Event untuk memuat data tips (saat init)
class LoadTips extends TipsEvent {}

/// Event untuk refresh data (pull-to-refresh)
class RefreshTips extends TipsEvent {}
