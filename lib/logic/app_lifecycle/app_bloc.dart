import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:petani_maju/core/services/cache_service.dart';

part 'app_event.dart';
part 'app_state.dart';

/// Global BLoC untuk mengelola state aplikasi secara keseluruhan
/// Termasuk: inisialisasi, monitoring koneksi, dan offline mode
class AppBloc extends Bloc<AppEvent, AppState> {
  final CacheService _cacheService;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AppBloc({
    required CacheService cacheService,
    Connectivity? connectivity,
  })  : _cacheService = cacheService,
        _connectivity = connectivity ?? Connectivity(),
        super(AppInitial()) {
    on<AppStarted>(_onAppStarted);
    on<ConnectivityChanged>(_onConnectivityChanged);
    on<ToggleOfflineMode>(_onToggleOfflineMode);
    on<CompleteOnboarding>(_onCompleteOnboarding);
  }

  /// Handle aplikasi pertama kali dimulai
  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AppState> emit,
  ) async {
    emit(AppLoading());

    try {
      // Check initial connectivity
      final connectivityResult = await _connectivity.checkConnectivity();
      final isConnected = !connectivityResult.contains(ConnectivityResult.none);

      // Get saved offline mode preference
      final offlineModeEnabled = _cacheService.getOfflineMode();

      // Check for first time launch for Onboarding
      if (_cacheService.isFirstTime()) {
        emit(AppOnboarding());

        // Listen to connectivity changes even during onboarding
        _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
          (result) {
            final connected = !result.contains(ConnectivityResult.none);
            add(ConnectivityChanged(isConnected: connected));
          },
        );
        return;
      }

      // Listen to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (result) {
          final connected = !result.contains(ConnectivityResult.none);
          add(ConnectivityChanged(isConnected: connected));
        },
      );

      emit(AppReady(
        isConnected: isConnected,
        offlineModeEnabled: offlineModeEnabled,
      ));

      debugPrint(
          'AppBloc: App ready. Connected: $isConnected, Offline mode: $offlineModeEnabled');
    } catch (e) {
      debugPrint('AppBloc Error: $e');
      // Even if connectivity check fails, assume we're online
      emit(const AppReady(isConnected: true, offlineModeEnabled: false));
    }
  }

  /// Handle perubahan status koneksi
  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<AppState> emit,
  ) {
    final currentState = state;
    if (currentState is AppReady) {
      emit(currentState.copyWith(isConnected: event.isConnected));
      debugPrint('AppBloc: Connectivity changed to ${event.isConnected}');
    }
  }

  /// Handle toggle offline mode manual
  Future<void> _onToggleOfflineMode(
    ToggleOfflineMode event,
    Emitter<AppState> emit,
  ) async {
    final currentState = state;
    if (currentState is AppReady) {
      // Save preference
      await _cacheService.setOfflineMode(event.offlineMode);
      emit(currentState.copyWith(offlineModeEnabled: event.offlineMode));
      debugPrint('AppBloc: Offline mode set to ${event.offlineMode}');
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboarding event,
    Emitter<AppState> emit,
  ) async {
    await _cacheService.setFirstTime(false);

    // We can re-check connectivity or use existing state logic
    final connectivityResult = await _connectivity.checkConnectivity();
    final isConnected = !connectivityResult.contains(ConnectivityResult.none);
    final offlineModeEnabled = _cacheService.getOfflineMode();

    emit(AppReady(
      isConnected: isConnected,
      offlineModeEnabled: offlineModeEnabled,
    ));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
