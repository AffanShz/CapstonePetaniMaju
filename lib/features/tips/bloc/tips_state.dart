part of 'tips_bloc.dart';

/// States untuk TipsBloc
abstract class TipsState extends Equatable {
  const TipsState();

  @override
  List<Object?> get props => [];
}

/// State awal
class TipsInitial extends TipsState {}

/// State saat sedang memuat data
class TipsLoading extends TipsState {}

/// State saat data berhasil dimuat
class TipsLoaded extends TipsState {
  final List<Map<String, dynamic>> tips;

  const TipsLoaded({required this.tips});

  @override
  List<Object?> get props => [tips];
}

/// State saat terjadi error
class TipsError extends TipsState {
  final String message;

  const TipsError({required this.message});

  @override
  List<Object?> get props => [message];
}
