// Dummy services untuk compilation
class AuthService {}
class AdminService {}
class DoaDzikirService {}
class ChatService {}
class DailyRecapService {}
class SakinahTrackerService {}

// Dummy models
class AyahData {
  final String text;
  final int number;
  AyahData({required this.text, required this.number});
}

class SurahData {
  final int number;
  final String nameIndonesian;
  final String nameArabic;
  final String nameLatin;
  SurahData({
    required this.number,
    required this.nameIndonesian,
    required this.nameArabic,
    required this.nameLatin,
  });
}

// Dummy QuranService
class QuranService {
  static Future<List<SurahData>> getSurahs() async => [];
  static Future<List<AyahData>> getAyahs(int surahNumber) async => [];
}