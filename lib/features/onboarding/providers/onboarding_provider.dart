import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class OnboardingState {
  const OnboardingState({
    this.language = 'en',
    this.prayerTradition,
    this.calculationMethodId,
    this.name = '',
    this.photoUrl,
    this.notificationsEnabled = false,
    this.biometricEnabled = false,
    this.isLoading = false,
    this.error,
  });

  final String language;
  final String? prayerTradition;   // 'sunni' | 'shia'
  final int? calculationMethodId;  // AlAdhan method id
  final String name;
  final String? photoUrl;
  final bool notificationsEnabled;
  final bool biometricEnabled;
  final bool isLoading;
  final String? error;

  OnboardingState copyWith({
    String? language,
    String? prayerTradition,
    int? calculationMethodId,
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
    bool? biometricEnabled,
    bool? isLoading,
    Object? error = _sentinel,
  }) =>
      OnboardingState(
        language: language ?? this.language,
        prayerTradition: prayerTradition ?? this.prayerTradition,
        calculationMethodId: calculationMethodId ?? this.calculationMethodId,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        isLoading: isLoading ?? this.isLoading,
        error: error == _sentinel ? this.error : error as String?,
      );

  static const _sentinel = Object();
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setLanguage(String language) =>
      state = state.copyWith(language: language);

  void setPrayerTradition(String tradition) =>
      state = state.copyWith(prayerTradition: tradition, calculationMethodId: null);

  void setCalculationMethod(int id) =>
      state = state.copyWith(calculationMethodId: id);

  void setName(String name) => state = state.copyWith(name: name);

  void setPhotoUrl(String? url) => state = state.copyWith(photoUrl: url);

  void setNotificationsEnabled(bool enabled) =>
      state = state.copyWith(notificationsEnabled: enabled);

  void setBiometricEnabled(bool enabled) =>
      state = state.copyWith(biometricEnabled: enabled);

  void setLoading(bool loading) =>
      state = state.copyWith(isLoading: loading, error: null);

  void setError(String? error) =>
      state = state.copyWith(isLoading: false, error: error);

  void clearError() => state = state.copyWith(error: null);
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (_) => OnboardingNotifier(),
);
