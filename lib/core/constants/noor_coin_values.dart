/// All confirmed Noor Coin earn/spend values.
/// Single source of truth — never inline numeric literals.
///
/// Currency: Noor Coins ONLY. No "Shining Points" exist.
abstract final class NoorCoinValues {
  /// Per individual prayer (×5 for all 5 daily prayers).
  static const int kPrayerNoorCoins = 300;

  /// Per Ramadan day fasted.
  static const int kFastNoorCoins = 500;

  /// Per completed Tasbeeh session.
  static const int kTasbeehNoorCoins = 50;

  /// Per completed Soul Stack (Rise, Shine, or Glow).
  static const int kSoulStackNoorCoins = 25000;

  /// Per YWTL video watched in full.
  static const int kYwtlNoorCoins = 15000;

  /// Garden access hours added per completed Soul Stack.
  static const int kGardenAccessHoursPerStack = 6;

  /// One-time welcome bonus awarded on first entry.
  static const int kWelcomeBonusNoorCoins = 1000;
}
