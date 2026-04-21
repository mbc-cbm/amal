import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/calculation_methods.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/prayer_times_model.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/utils/app_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // ── Local state ──────────────────────────────────────────────────────────
  String _tradition = 'sunni';
  int _calculationMethodId = 2;
  String _azanAudio = 'makkah';
  String _themeMode = 'system';
  bool _hapticEnabled = true;
  bool _soundEnabled = true;
  bool _biometricEnabled = false;

  // Soul Stack reminders
  bool _riseEnabled = true;
  TimeOfDay _riseTime = const TimeOfDay(hour: 6, minute: 0);
  bool _shineEnabled = true;
  TimeOfDay _shineTime = const TimeOfDay(hour: 13, minute: 0);
  bool _glowEnabled = true;
  TimeOfDay _glowTime = const TimeOfDay(hour: 20, minute: 0);

  // YWTL reminder
  bool _ywtlEnabled = true;
  TimeOfDay _ywtlTime = const TimeOfDay(hour: 9, minute: 0);

  // Other notifications
  bool _streakAtRiskEnabled = true;
  bool _assetFadingEnabled = true;

  // Location display
  String _locationDisplay = '';

  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = AppPreferences.instance;

    // Load from SharedPreferences
    _themeMode = prefs.themeMode;
    _hapticEnabled = prefs.hapticEnabled;
    _soundEnabled = prefs.soundEnabled;
    _biometricEnabled = prefs.biometricEnabled;
    _azanAudio = prefs.azanAudio;

    _riseEnabled = prefs.soulStackRiseEnabled;
    _riseTime = TimeOfDay(
        hour: prefs.soulStackRiseHour, minute: prefs.soulStackRiseMinute);
    _shineEnabled = prefs.soulStackShineEnabled;
    _shineTime = TimeOfDay(
        hour: prefs.soulStackShineHour, minute: prefs.soulStackShineMinute);
    _glowEnabled = prefs.soulStackGlowEnabled;
    _glowTime = TimeOfDay(
        hour: prefs.soulStackGlowHour, minute: prefs.soulStackGlowMinute);

    _ywtlEnabled = prefs.ywtlReminderEnabled;
    _ywtlTime = TimeOfDay(
        hour: prefs.ywtlReminderHour, minute: prefs.ywtlReminderMinute);
    _streakAtRiskEnabled = prefs.streakAtRiskEnabled;
    _assetFadingEnabled = prefs.assetFadingEnabled;

    // Location display
    if (prefs.prayerUseGps) {
      _locationDisplay = 'GPS';
    } else {
      final city = prefs.prayerCity;
      final country = prefs.prayerCountry;
      if (city != null && country != null) {
        _locationDisplay = '$city, $country';
      }
    }

    // Load from Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();
        final data = doc.data();
        if (data != null) {
          _tradition = data['prayerTradition'] as String? ?? 'sunni';
          final rawMethod = data['calculationMethod'] as String?;
          _calculationMethodId = int.tryParse(rawMethod ?? '') ?? 2;

          // Load notification prefs from Firestore
          final notifPrefs =
              data['notificationPrefs'] as Map<String, dynamic>?;
          if (notifPrefs != null) {
            _riseEnabled = notifPrefs['soulStackRise'] as bool? ?? true;
            _shineEnabled = notifPrefs['soulStackShine'] as bool? ?? true;
            _glowEnabled = notifPrefs['soulStackGlow'] as bool? ?? true;
            _ywtlEnabled = notifPrefs['ywtlVideo'] as bool? ?? true;
            _streakAtRiskEnabled =
                notifPrefs['streakAtRisk'] as bool? ?? true;
            _assetFadingEnabled =
                notifPrefs['assetFading'] as bool? ?? true;

            if (notifPrefs['riseHour'] != null) {
              _riseTime = TimeOfDay(
                hour: notifPrefs['riseHour'] as int,
                minute: notifPrefs['riseMinute'] as int? ?? 0,
              );
            }
            if (notifPrefs['shineHour'] != null) {
              _shineTime = TimeOfDay(
                hour: notifPrefs['shineHour'] as int,
                minute: notifPrefs['shineMinute'] as int? ?? 0,
              );
            }
            if (notifPrefs['glowHour'] != null) {
              _glowTime = TimeOfDay(
                hour: notifPrefs['glowHour'] as int,
                minute: notifPrefs['glowMinute'] as int? ?? 0,
              );
            }
            if (notifPrefs['ywtlHour'] != null) {
              _ywtlTime = TimeOfDay(
                hour: notifPrefs['ywtlHour'] as int,
                minute: notifPrefs['ywtlMinute'] as int? ?? 0,
              );
            }
          }
        }
      } catch (_) {
        // Silently handle Firestore errors
      }
    }

    if (mounted) setState(() => _loaded = true);
  }

  // ── Firestore notification prefs save ───────────────────────────────────
  Future<void> _saveNotificationPrefs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'notificationPrefs': {
        'soulStackRise': _riseEnabled,
        'riseHour': _riseTime.hour,
        'riseMinute': _riseTime.minute,
        'soulStackShine': _shineEnabled,
        'shineHour': _shineTime.hour,
        'shineMinute': _shineTime.minute,
        'soulStackGlow': _glowEnabled,
        'glowHour': _glowTime.hour,
        'glowMinute': _glowTime.minute,
        'ywtlVideo': _ywtlEnabled,
        'ywtlHour': _ywtlTime.hour,
        'ywtlMinute': _ywtlTime.minute,
        'streakAtRisk': _streakAtRiskEnabled,
        'assetFading': _assetFadingEnabled,
      },
    }, SetOptions(merge: true));
  }

  // ── Tradition save ──────────────────────────────────────────────────────
  Future<void> _saveTradition(String tradition) async {
    setState(() => _tradition = tradition);
    // Update calculation method to first available for new tradition
    final methods = methodsForTradition(tradition);
    if (methods.isNotEmpty) {
      setState(() => _calculationMethodId = methods.first.id);
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'prayerTradition': tradition,
      'calculationMethod': _calculationMethodId.toString(),
    }, SetOptions(merge: true));
    await AppPreferences.instance.clearPrayerTimesCache();
    ref.invalidate(userTraditionProvider);
    ref.invalidate(userCalculationMethodProvider);
    ref.invalidate(todayPrayerTimesProvider);
  }

  // ── Calculation method save ─────────────────────────────────────────────
  Future<void> _saveCalculationMethod(int methodId) async {
    setState(() => _calculationMethodId = methodId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'calculationMethod': methodId.toString(),
    }, SetOptions(merge: true));
    await AppPreferences.instance.clearPrayerTimesCache();
    ref.invalidate(userCalculationMethodProvider);
    ref.invalidate(todayPrayerTimesProvider);
  }

  // ── Location update ─────────────────────────────────────────────────────
  Future<void> _updateLocation() async {
    await AppPreferences.instance.setPrayerUseGps(true);
    await AppPreferences.instance.clearPrayerTimesCache();
    ref.invalidate(currentPositionProvider);
    ref.invalidate(todayPrayerTimesProvider);
    if (mounted) setState(() => _locationDisplay = 'GPS');
  }

  // ── Time picker helper ──────────────────────────────────────────────────
  Future<TimeOfDay?> _pickTime(TimeOfDay initial) async {
    return showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(primary: AppColors.primaryGreen),
          ),
          child: child!,
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  // ── Prayer label helper ─────────────────────────────────────────────────
  String _prayerLabel(PrayerName prayer, AppLocalizations l10n) {
    switch (prayer) {
      case PrayerName.fajr:
        return l10n.fajr;
      case PrayerName.dhuhr:
        return l10n.dhuhr;
      case PrayerName.asr:
        return l10n.asr;
      case PrayerName.maghrib:
        return l10n.maghrib;
      case PrayerName.isha:
        return l10n.isha;
    }
  }

  String _modeLabelFor(PrayerNotificationMode mode, AppLocalizations l10n) {
    switch (mode) {
      case PrayerNotificationMode.silent:
        return l10n.modeSilent;
      case PrayerNotificationMode.notification:
        return l10n.modeNotification;
      case PrayerNotificationMode.azan:
        return l10n.modeAzan;
    }
  }

  // ── Azan audio label ────────────────────────────────────────────────────
  String _azanLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'makkah':
        return l10n.settingsAzanMakkah;
      case 'madinah':
        return l10n.settingsAzanMadinah;
      case 'alaqsa':
        return l10n.settingsAzanAlAqsa;
      case 'mishary':
        return l10n.settingsAzanMishary;
      default:
        return key;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    if (!_loaded) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          title: Text(l10n.settings,
              style: AppTypography.titleLarge.copyWith(color: cs.onSurface)),
          backgroundColor: cs.surface,
          surfaceTintColor: AppColors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.settings,
            style: AppTypography.titleLarge.copyWith(color: cs.onSurface)),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        children: [
          const SizedBox(height: AppSpacing.sm),

          // ── 1. Notifications ──────────────────────────────────────────
          _SectionHeader(title: l10n.settingsNotifications),
          const SizedBox(height: AppSpacing.sm),

          // 1a. Prayer Reminders
          _SubSectionHeader(title: l10n.settingsPrayerReminders),
          const SizedBox(height: AppSpacing.xs),
          _buildPrayerReminders(l10n, cs),
          const SizedBox(height: AppSpacing.md),

          // 1b. Soul Stack Reminders
          _SubSectionHeader(title: l10n.settingsSoulStackReminders),
          const SizedBox(height: AppSpacing.xs),
          _buildSoulStackReminders(l10n, cs),
          const SizedBox(height: AppSpacing.md),

          // 1c. YWTL New Video
          _buildTimeSwitch(
            title: l10n.settingsYwtlVideo,
            enabled: _ywtlEnabled,
            time: _ywtlTime,
            cs: cs,
            onToggle: (v) {
              setState(() => _ywtlEnabled = v);
              AppPreferences.instance.setYwtlReminderEnabled(v);
              _saveNotificationPrefs();
            },
            onTimePick: () async {
              final t = await _pickTime(_ywtlTime);
              if (t != null) {
                setState(() => _ywtlTime = t);
                AppPreferences.instance.setYwtlReminderTime(t.hour, t.minute);
                _saveNotificationPrefs();
              }
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // 1d. Streak At Risk
          _buildSettingsTile(
            title: l10n.settingsStreakAtRisk,
            subtitle: l10n.settingsStreakAtRiskDesc,
            cs: cs,
            trailing: Switch.adaptive(
              value: _streakAtRiskEnabled,
              activeTrackColor: AppColors.primaryGreen,
              onChanged: (v) {
                setState(() => _streakAtRiskEnabled = v);
                AppPreferences.instance.setStreakAtRiskEnabled(v);
                _saveNotificationPrefs();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // 1e. Asset Fading Warning
          _buildSettingsTile(
            title: l10n.settingsAssetFading,
            subtitle: l10n.settingsAssetFadingDesc,
            cs: cs,
            trailing: Switch.adaptive(
              value: _assetFadingEnabled,
              activeTrackColor: AppColors.primaryGreen,
              onChanged: (v) {
                setState(() => _assetFadingEnabled = v);
                AppPreferences.instance.setAssetFadingEnabled(v);
                _saveNotificationPrefs();
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // ── 2. Prayer Settings ────────────────────────────────────────
          _SectionHeader(title: l10n.settingsPrayerSettings),
          const SizedBox(height: AppSpacing.sm),
          _buildPrayerSettings(l10n, cs),
          const SizedBox(height: AppSpacing.xl),

          // ── 3. App Settings ───────────────────────────────────────────
          _SectionHeader(title: l10n.settingsAppSettings),
          const SizedBox(height: AppSpacing.sm),
          _buildAppSettings(l10n, cs),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // ── Prayer reminders (5 rows with 3-way toggle) ─────────────────────────

  Widget _buildPrayerReminders(AppLocalizations l10n, ColorScheme cs) {
    final notifAsync = ref.watch(prayerNotificationSettingsProvider);
    final settings =
        notifAsync.valueOrNull ?? PrayerNotificationSettings.defaults;

    return Column(
      children: PrayerName.values.map((prayer) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_prayerLabel(prayer, l10n),
                      style: AppTypography.bodyMedium
                          .copyWith(color: cs.onSurface)),
                ),
                _ModeToggle(
                  currentMode: settings.modeFor(prayer),
                  onChanged: (m) => ref
                      .read(prayerNotificationSettingsProvider.notifier)
                      .setMode(prayer, m),
                  modeLabelFor: (m) => _modeLabelFor(m, l10n),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Soul Stack reminders ────────────────────────────────────────────────

  Widget _buildSoulStackReminders(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      children: [
        _buildTimeSwitch(
          title: l10n.soulStackRise.split(' — ').first,
          enabled: _riseEnabled,
          time: _riseTime,
          cs: cs,
          onToggle: (v) {
            setState(() => _riseEnabled = v);
            AppPreferences.instance.setSoulStackRiseEnabled(v);
            _saveNotificationPrefs();
          },
          onTimePick: () async {
            final t = await _pickTime(_riseTime);
            if (t != null) {
              setState(() => _riseTime = t);
              AppPreferences.instance
                  .setSoulStackRiseTime(t.hour, t.minute);
              _saveNotificationPrefs();
            }
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        _buildTimeSwitch(
          title: l10n.soulStackShine.split(' — ').first,
          enabled: _shineEnabled,
          time: _shineTime,
          cs: cs,
          onToggle: (v) {
            setState(() => _shineEnabled = v);
            AppPreferences.instance.setSoulStackShineEnabled(v);
            _saveNotificationPrefs();
          },
          onTimePick: () async {
            final t = await _pickTime(_shineTime);
            if (t != null) {
              setState(() => _shineTime = t);
              AppPreferences.instance
                  .setSoulStackShineTime(t.hour, t.minute);
              _saveNotificationPrefs();
            }
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        _buildTimeSwitch(
          title: l10n.soulStackGlow.split(' — ').first,
          enabled: _glowEnabled,
          time: _glowTime,
          cs: cs,
          onToggle: (v) {
            setState(() => _glowEnabled = v);
            AppPreferences.instance.setSoulStackGlowEnabled(v);
            _saveNotificationPrefs();
          },
          onTimePick: () async {
            final t = await _pickTime(_glowTime);
            if (t != null) {
              setState(() => _glowTime = t);
              AppPreferences.instance
                  .setSoulStackGlowTime(t.hour, t.minute);
              _saveNotificationPrefs();
            }
          },
        ),
      ],
    );
  }

  // ── Time + switch row ───────────────────────────────────────────────────

  Widget _buildTimeSwitch({
    required String title,
    required bool enabled,
    required TimeOfDay time,
    required ColorScheme cs,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTimePick,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyMedium
                        .copyWith(color: cs.onSurface)),
                if (enabled)
                  GestureDetector(
                    onTap: onTimePick,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: AppColors.primaryGreen),
                          const SizedBox(width: 4),
                          Text(
                            _formatTimeOfDay(time),
                            style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }

  // ── Generic settings tile ───────────────────────────────────────────────

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required ColorScheme cs,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyMedium
                        .copyWith(color: cs.onSurface)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(subtitle,
                        style: AppTypography.bodySmall
                            .copyWith(color: cs.onSurfaceVariant)),
                  ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // ── 2. Prayer Settings ──────────────────────────────────────────────────

  Widget _buildPrayerSettings(AppLocalizations l10n, ColorScheme cs) {
    final methods = methodsForTradition(_tradition);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prayer tradition: Sunni / Shia radio
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsPrayerTradition,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _buildTraditionChip(
                    label: l10n.sunni,
                    value: 'sunni',
                    cs: cs,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildTraditionChip(
                    label: l10n.shia,
                    value: 'shia',
                    cs: cs,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Calculation method dropdown
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsCalculationMethod,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              DropdownButton<int>(
                value: methods.any((m) => m.id == _calculationMethodId)
                    ? _calculationMethodId
                    : methods.first.id,
                isExpanded: true,
                dropdownColor: cs.surfaceContainerHighest,
                style:
                    AppTypography.bodyMedium.copyWith(color: cs.onSurface),
                underline: Container(
                    height: 1, color: cs.onSurfaceVariant.withAlpha(50)),
                items: methods.map((m) {
                  return DropdownMenuItem<int>(
                    value: m.id,
                    child: Text('${m.name} — ${m.region}',
                        style: AppTypography.bodySmall
                            .copyWith(color: cs.onSurface)),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) _saveCalculationMethod(v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Location
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 20, color: AppColors.primaryGreen),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsLocation,
                        style: AppTypography.titleSmall
                            .copyWith(color: cs.onSurface)),
                    if (_locationDisplay.isNotEmpty)
                      Text(_locationDisplay,
                          style: AppTypography.bodySmall
                              .copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _updateLocation,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                ),
                child: Text(l10n.settingsUpdateLocation,
                    style: AppTypography.labelMedium
                        .copyWith(color: AppColors.primaryGreen)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Azan audio
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsAzanAudio,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              DropdownButton<String>(
                value: _azanAudio,
                isExpanded: true,
                dropdownColor: cs.surfaceContainerHighest,
                style:
                    AppTypography.bodyMedium.copyWith(color: cs.onSurface),
                underline: Container(
                    height: 1, color: cs.onSurfaceVariant.withAlpha(50)),
                items: ['makkah', 'madinah', 'alaqsa', 'mishary']
                    .map((key) => DropdownMenuItem<String>(
                          value: key,
                          child: Text(_azanLabel(key, l10n),
                              style: AppTypography.bodyMedium
                                  .copyWith(color: cs.onSurface)),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _azanAudio = v);
                    AppPreferences.instance.setAzanAudio(v);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Radio option helper ─────────────────────────────────────────────────

  Widget _buildTraditionChip({
    required String label,
    required String value,
    required ColorScheme cs,
  }) {
    final selected = _tradition == value;
    return GestureDetector(
      onTap: () => _saveTradition(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen.withAlpha(25)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen
                : cs.onSurfaceVariant.withAlpha(30),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 18,
              color: selected
                  ? AppColors.primaryGreen
                  : cs.onSurfaceVariant,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: AppTypography.bodyMedium.copyWith(
                  color: selected
                      ? AppColors.primaryGreen
                      : cs.onSurface,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.w400,
                )),
          ],
        ),
      ),
    );
  }

  // ── 3. App Settings ─────────────────────────────────────────────────────

  Widget _buildAppSettings(AppLocalizations l10n, ColorScheme cs) {
    final currentLocale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsLanguage,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              _buildLanguageCards(cs, currentLocale),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Theme
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.settingsTheme,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface)),
              const SizedBox(height: AppSpacing.sm),
              _buildThemeSegmented(l10n, cs),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Haptic feedback
        _buildSettingsTile(
          title: l10n.settingsHaptic,
          cs: cs,
          trailing: Switch.adaptive(
            value: _hapticEnabled,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (v) {
              setState(() => _hapticEnabled = v);
              AppPreferences.instance.setHapticEnabled(v);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Sound effects
        _buildSettingsTile(
          title: l10n.settingsSound,
          cs: cs,
          trailing: Switch.adaptive(
            value: _soundEnabled,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (v) {
              setState(() => _soundEnabled = v);
              AppPreferences.instance.setSoundEnabled(v);
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Biometric login
        _buildSettingsTile(
          title: l10n.settingsBiometric,
          cs: cs,
          trailing: Switch.adaptive(
            value: _biometricEnabled,
            activeTrackColor: AppColors.primaryGreen,
            onChanged: (v) {
              setState(() => _biometricEnabled = v);
              AppPreferences.instance.setBiometricEnabled(v);
            },
          ),
        ),
      ],
    );
  }

  // ── Language cards ──────────────────────────────────────────────────────

  Widget _buildLanguageCards(ColorScheme cs, Locale currentLocale) {
    const languages = [
      {'code': 'en', 'label': 'English', 'native': 'English'},
      {'code': 'bn', 'label': 'Bengali', 'native': 'বাংলা'},
      {'code': 'ur', 'label': 'Urdu', 'native': 'اردو'},
      {'code': 'ar', 'label': 'Arabic', 'native': 'العربية'},
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: languages.map((lang) {
        final code = lang['code']!;
        final isSelected = currentLocale.languageCode == code;
        return GestureDetector(
          onTap: () async {
            ref.read(localeProvider.notifier).state = Locale(code);
            await AppPreferences.instance.setLocale(code);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryGreen.withAlpha(25)
                  : cs.surfaceContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryGreen
                    : cs.onSurfaceVariant.withAlpha(30),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang['native']!,
                    style: AppTypography.titleSmall.copyWith(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : cs.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    )),
                if (lang['native'] != lang['label'])
                  Text(lang['label']!,
                      style: AppTypography.labelSmall
                          .copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Theme segmented control ─────────────────────────────────────────────

  Widget _buildThemeSegmented(AppLocalizations l10n, ColorScheme cs) {
    final modes = [
      {'key': 'light', 'label': l10n.settingsThemeLight, 'icon': Icons.light_mode_rounded},
      {'key': 'dark', 'label': l10n.settingsThemeDark, 'icon': Icons.dark_mode_rounded},
      {'key': 'system', 'label': l10n.settingsThemeSystem, 'icon': Icons.settings_brightness_rounded},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: modes.map((m) {
          final selected = _themeMode == m['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _themeMode = m['key'] as String);
                AppPreferences.instance.setThemeMode(m['key'] as String);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primaryGreen
                      : AppColors.transparent,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      m['icon'] as IconData,
                      size: 16,
                      color: selected
                          ? AppColors.white
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m['label'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: selected
                            ? AppColors.white
                            : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(title,
        style: AppTypography.titleMedium.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ));
  }
}

class _SubSectionHeader extends StatelessWidget {
  const _SubSectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(title,
        style: AppTypography.titleSmall
            .copyWith(color: cs.onSurfaceVariant));
  }
}

// ── 3-way mode toggle (matches prayer_screen.dart pattern) ──────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.currentMode,
    required this.onChanged,
    required this.modeLabelFor,
  });

  final PrayerNotificationMode currentMode;
  final ValueChanged<PrayerNotificationMode> onChanged;
  final String Function(PrayerNotificationMode) modeLabelFor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PrayerNotificationMode.values.map((mode) {
          final selected = mode == currentMode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryGreen
                    : AppColors.transparent,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(mode),
                    size: 12,
                    color:
                        selected ? AppColors.white : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    modeLabelFor(mode),
                    style: AppTypography.labelSmall.copyWith(
                      color:
                          selected ? AppColors.white : cs.onSurfaceVariant,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(PrayerNotificationMode mode) {
    switch (mode) {
      case PrayerNotificationMode.silent:
        return Icons.volume_off_rounded;
      case PrayerNotificationMode.notification:
        return Icons.notifications_rounded;
      case PrayerNotificationMode.azan:
        return Icons.volume_up_rounded;
    }
  }
}
