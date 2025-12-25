import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petani_maju/data/repositories/tips_repository.dart';

part 'tips_event.dart';
part 'tips_state.dart';

/// BLoC untuk mengelola state halaman Tips Pertanian
class TipsBloc extends Bloc<TipsEvent, TipsState> {
  final TipsRepository _tipsRepository;

  TipsBloc({
    required TipsRepository tipsRepository,
  })  : _tipsRepository = tipsRepository,
        super(TipsInitial()) {
    on<LoadTips>(_onLoadTips);
    on<RefreshTips>(_onRefreshTips);
  }

  /// Handle load tips
  Future<void> _onLoadTips(
    LoadTips event,
    Emitter<TipsState> emit,
  ) async {
    emit(TipsLoading());

    try {
      final tips = await _tipsRepository.fetchTips();
      emit(TipsLoaded(tips: tips));
    } catch (e) {
      debugPrint('TipsBloc Error: $e');
      emit(TipsError(message: e.toString()));
    }
  }

  /// Handle refresh tips
  Future<void> _onRefreshTips(
    RefreshTips event,
    Emitter<TipsState> emit,
  ) async {
    try {
      final tips = await _tipsRepository.fetchTips(forceRefresh: true);
      emit(TipsLoaded(tips: tips));
    } catch (e) {
      debugPrint('TipsBloc Refresh Error: $e');
      // Tetap di state sekarang jika refresh gagal
    }
  }
}
