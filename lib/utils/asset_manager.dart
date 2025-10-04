class AssetManager {
  // Base paths
  static const String _basePath = 'assets';
  static const String _imagesPath = '$_basePath/images';

  // App Icons & Logos
  static const String appIcon = '$_imagesPath/app_icon.png';
  static const String appLogo = '$_imagesPath/app_logo.png';
  static const String quranicareLogo = '$_imagesPath/Logo Quranicare.png';

  // Feature Icons for Homepage (sesuai dengan file yang ada)
  static const String heartIcon = '$_imagesPath/Asset Hati.png';           // Jurnal Refleksi
  static const String quranIcon = '$_imagesPath/Asset Alquran.png';        // Al-Quran & Bottom Nav
  static const String headphoneIcon = '$_imagesPath/Asset Headphone.png';  // Audio Relax
  static const String tasbihIcon = '$_imagesPath/Asset Tasbih.png';        // Doa & Dzikir
  static const String breathingIcon = '$_imagesPath/breathing.png';        // Breathing Exercise (fallback)

  // Mood Emotes (sesuai dengan emote yang ada)
  static const String moodHappy = '$_imagesPath/Emote Kacamata Senang.png';     // Bahagia/Senang
  static const String moodNeutral = '$_imagesPath/Emote Datar.png';             // Biasa/Neutral
  static const String moodSad = '$_imagesPath/Emote Sedih.png';                 // Sedih
  static const String moodDown = '$_imagesPath/Emote Sedih Kecewa.png';         // Down/Kecewa
  static const String moodAngry = '$_imagesPath/Emote Marah.png';               // Marah
  static const String moodAnxious = '$_imagesPath/Spin Emote.png';              // Cemas (using Spin Emote)

  // Chat Bot Avatar (sesuai dengan chatbot yang ada)
  static const String chatBotAvatar = '$_imagesPath/Chatbot.png';               // Chat bot avatar
  static const String qalbuChatAvatar = '$_imagesPath/Chatbot.png';             // Same as chatbot

  // User Avatar
  static const String defaultProfile = '$_imagesPath/default_profile.png';
  static const String userAvatar = '$_imagesPath/user_avatar.png';

  // Backgrounds
  static const String splashBackground = '$_imagesPath/splash_bg.png';
  static const String onboardingBackground = '$_imagesPath/onboarding_bg.png';
  static const String homeBackground = '$_imagesPath/home_bg.png';
  static const String islamicPattern = '$_imagesPath/islamic_pattern.png';

  // Illustrations
  static const String breathingIllustration = '$_imagesPath/breathing_illustration.png';
  static const String meditationIllustration = '$_imagesPath/meditation_illustration.png';
  static const String journalIllustration = '$_imagesPath/journal_illustration.png';
  static const String quranReadingIllustration = '$_imagesPath/quran_reading.png';
  static const String psychologyIllustration = '$_imagesPath/psychology_illustration.png';

  // Prayer & Dzikir
  static const String prayingIllustration = '$_imagesPath/praying_illustration.png';
  static const String dzikirIllustration = '$_imagesPath/dzikir_illustration.png';
  static const String islamicCalligraphy = '$_imagesPath/islamic_calligraphy.png';

  // Helper method to check if asset exists
  static bool assetExists(String assetPath) {
    // This would need to be implemented with proper asset checking
    // For now, we'll assume all assets exist
    return true;
  }

  // Get mood emote based on mood type
  static String getMoodEmote(String moodType) {
    switch (moodType.toLowerCase()) {
      case 'happy':
      case 'bahagia':
      case 'senang':
        return moodHappy;
      case 'neutral':
      case 'biasa':
        return moodNeutral;
      case 'sad':
      case 'sedih':
        return moodSad;
      case 'down':
        return moodDown;
      case 'angry':
      case 'marah':
        return moodAngry;
      case 'anxious':
      case 'cemas':
        return moodAnxious;
      default:
        return moodNeutral;
    }
  }

  // Get feature icon based on feature name
  static String getFeatureIcon(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'jurnal refleksi':
      case 'journal':
        return heartIcon;
      case 'al-quran':
      case 'quran':
        return quranIcon;
      case 'audio relax':
      case 'audio':
        return headphoneIcon;
      case 'doa & dzikir':
      case 'dzikir':
        return tasbihIcon;
      case 'breathing exercise':
      case 'breathing':
        return breathingIcon;
      default:
        return heartIcon;
    }
  }
}
