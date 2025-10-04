import 'package:flutter/material.dart';

class QuranicPsychologyScreen extends StatelessWidget {
  const QuranicPsychologyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Psikologi Qurani',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header yang lebih sederhana dan menarik
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8FA68E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      size: 32,
                      color: const Color(0xFF8FA68E),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Psikologi dalam Al-Quran',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Temukan ketenangan jiwa',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: psychologyArticles.length,
                itemBuilder: (context, index) {
                  final article = psychologyArticles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PsychologyArticleDetailScreen(article: article),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2D5A5A).withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nomor artikel kecil di kiri atas
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8FA68E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF8FA68E),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Judul artikel
                            Text(
                              article.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D5A5A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Preview dengan spacing yang baik
                            Text(
                              article.preview,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF64748B),
                                height: 1.5,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            
                            // Indikator baca lebih lanjut
                            Row(
                              children: [
                                Text(
                                  'Baca Selengkapnya',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8FA68E),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(0xFF8FA68E),
                                  size: 12,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Tombol muat lebih banyak yang sederhana
            Container(
              margin: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () {
                  // Action untuk load more articles
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Muat Artikel Lainnya',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF8FA68E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF8FA68E),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class PsychologyArticleDetailScreen extends StatelessWidget {
  final PsychologyArticle article;

  const PsychologyArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A5A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Psikologi Qurani',
          style: TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title card yang sederhana dan clean
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D5A5A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(article.contentSections.join(' ').length / 200).ceil()} menit baca',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8FA68E),
                      ),
                    ),
                  ],
                ),
              ),

              // Content sections yang lebih bersih
              ...article.contentSections.map((section) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2D5A5A).withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    section,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2D5A5A),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                );
              }).toList(),

              const SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D5A5A).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, Icons.home, 'Home', false),
                _buildNavItem(1, Icons.book, 'Al Quran', false),
                _buildNavItem(2, Icons.chat_bubble, 'Qalbu Chat', false),
                _buildNavItem(3, Icons.person, 'Profil', false),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8FA68E) : const Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

// Data model
class PsychologyArticle {
  final String title;
  final String preview;
  final List<String> contentSections;

  PsychologyArticle({
    required this.title,
    required this.preview,
    required this.contentSections,
  });
}

// Sample data based on the mockups
final List<PsychologyArticle> psychologyArticles = [
  PsychologyArticle(
    title: 'Pentingnya Ketenangan Batin dalam Islam',
    preview: 'Materi ini akan mendalami bagaimana Islam memandang ketenangan batin sebagai bagian integral dari kehidupan. Akan dijelaskan bahwa Al-Quran dan hadis menekankan ketentraman hati sebagai buah dari iman dan kedekatan kepada Allah SWT.',
    contentSections: [
      'Islam memandang ketenangan batin sebagai bagian integral dari kehidupan. Konsep ini bukan sekadar kondisi emosional biasa, melainkan merupakan spiritualitas yang mendalam yang mempengaruhi seluruh aspek kehidupan seorang Muslim. Al-Quran dan hadis secara eksplisit menekankan bahwa ketentraman hati adalah buah dari iman dan kedekatan yang hakiki kepada Allah SWT.',
      'Dalam ajaran Islam, ketenangan batin (sakinah atau thuma\'ninah) merupakan indikator keimanan seseorang. Semakin mendalam iman dan kedekatan seorang hamba kepada Penciptanya, semakin besar pula ketenangan yang dirasakan dalam hati. Ini adalah hadiah dari Allah kepada orang-orang yang beriman.',
      'Al-Quran secara gamblang menjelaskan hubungan antara mengingat Allah (zikir) dengan rasa tenteram hati. QS Ar Ra\'d ayat 28 secara tegas menyatakan bahwa ketentraman hati adalah hasil langsung dari mengingat Allah (bidzikrullah). Mengingat Allah di sini tidak hanya terbatas pada dzikir lisan, tetapi juga melakukan segala bentuk ketaatan, perenungan akan keagungan-Nya, dan kesadaran akan keberadaan-Nya dalam setiap langkah kehidupan. Ketika seseorang senantiasa mengingat dan mengingat Allah, hatinya akan dipenuhi rasa aman dan damai, jauh dari kegelisahan duniawi.',
      'Dengan demikian, ketenangan batin dalam Islam bukanlah sekadar aspirasi, melainkan sebuah hasil yang dapat dicapai melalui penguatan iman dan praktik spiritual yang konsisten, sebagaimana yang diajarkan dalam Al-Quran dan Sunnah Nabi.'
    ],
  ),
  PsychologyArticle(
    title: 'Peran Hati (Qalb) sebagai Pusat Pemahaman dan Emosi',
    preview: 'Menjelaskan qalb bukan hanya sebagai organ fisik, tetapi sebagai pusat kesadaran, emosi, dan pemahaman spiritual dalam perspektif Al-Quran. Akan dibahas bagaimana "hati menjadi tenteram dengan mengingat Allah" (QS Ar Ra\'d: 28) sebagai fondasi ketenangan batin.',
    contentSections: [
      'Dalam perspektif Islam, qalb atau hati tidak hanya dipahami sebagai organ fisik semata, tetapi sebagai pusat kesadaran, emosi, dan pemahaman spiritual. Al-Quran secara konsisten menggunakan istilah "qalb" untuk menunjukkan dimensi batin manusia yang menjadi tempat bertemunya akal, perasaan, dan spiritualitas.',
      'Hati dalam Islam berfungsi sebagai pusat kendali kehidupan manusia. Ia tidak hanya memompa darah, tetapi juga menjadi tempat bermuara segala keputusan, perasaan, dan pemahaman. Rasulullah SAW bersabda bahwa dalam tubuh manusia terdapat segumpal daging, jika ia baik maka baik pula seluruh tubuh, dan jika ia rusak maka rusak pula seluruh tubuh, yaitu hati.',
      'Al-Quran menyebutkan berbagai kondisi hati: hati yang beriman, hati yang kafir, hati yang keras, hati yang lembut, dan hati yang sakit. Kondisi-kondisi ini menggambarkan spectrum kesehatan spiritual dan psikologis manusia. Hati yang sehat adalah hati yang selalu terhubung dengan Allah, sementara hati yang sakit adalah hati yang jauh dari-Nya.',
      'Pemahaman tentang hati ini memberikan landasan yang kuat untuk pengembangan kesehatan mental dalam Islam. Dengan menjaga kesehatan hati melalui ibadah, dzikir, dan amal saleh, seseorang dapat mencapai keseimbangan emosional dan spiritual yang optimal.'
    ],
  ),
  PsychologyArticle(
    title: 'Wahyu sebagai Penyembuh Psikis dan Spiritual',
    preview: 'Mendalami makna QS Yunus ayat 57, "Hai manusia, sesungguhnya telah datang kepadamu pelajaran dari Tuhanmu dan penyembuh bagi penyakit-penyakit (yang berada) dalam dada dan petunjuk serta rahmat bagi orang-orang yang beriman". Materi ini akan menjelaskan bagaimana Al-Quran menawarkan solusi bagi "penyakit-penyakit dalam dada" yang merujuk pada gangguan psikologis dan spiritual.',
    contentSections: [
      'QS Yunus ayat 57 memberikan pemahaman mendalam tentang fungsi Al-Quran sebagai penyembuh psikis dan spiritual. Ayat ini menyatakan bahwa Al-Quran adalah "syifa\' lima fi shudurin" - penyembuh bagi penyakit-penyakit yang ada dalam dada. Istilah "dalam dada" di sini merujuk pada berbagai gangguan psikologis, emosional, dan spiritual yang dapat menimpa manusia.',
      'Dalam konteks psikologi modern, "penyakit dalam dada" dapat dipahami sebagai berbagai kondisi mental seperti kecemasan, depresi, trauma, kebingungan identitas, dan krisis spiritual. Al-Quran menawarkan pendekatan holistik untuk mengatasi masalah-masalah ini melalui nilai-nilai, prinsip-prinsip, dan pandangan hidup yang terkandung dalam ayat-ayatnya.',
      'Proses penyembuhan melalui Al-Quran tidak hanya bersifat kognitif (melalui pemahaman dan perenungan), tetapi juga spiritual (melalui hubungan dengan Allah) dan praktis (melalui implementasi nilai-nilai Qurani dalam kehidupan sehari-hari). Ketika seseorang membaca, memahami, dan mengamalkan ajaran Al-Quran, terjadi transformasi internal yang menyembuhkan luka-luka batin dan memberikan ketenangan jiwa.',
      'Pendekatan Quranic psychology ini menekankan pentingnya integrasi antara pemahaman tekstual Al-Quran dengan aplikasi praktisnya dalam kehidupan nyata. Dengan demikian, Al-Quran bukan hanya sebagai kitab bacaan, tetapi sebagai panduan komprehensif untuk kesehatan mental dan spiritual.'
    ],
  ),
];
