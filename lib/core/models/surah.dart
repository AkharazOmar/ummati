class Surah {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final String nameTranslation;
  final int versesCount;
  final String revelationType;

  const Surah({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTranslation,
    required this.versesCount,
    required this.revelationType,
  });

  bool get isMeccan => revelationType == 'Meccan';

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      nameArabic: json['name'] as String,
      nameEnglish: json['englishName'] as String,
      nameTranslation: json['englishNameTranslation'] as String,
      versesCount: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final String? phonetic;
  final String? translation;

  const Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    this.phonetic,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] as int,
      text: json['text'] as String,
      numberInSurah: json['numberInSurah'] as int,
    );
  }

  Ayah withTranslation(String translation) {
    return Ayah(
      number: number,
      text: text,
      numberInSurah: numberInSurah,
      phonetic: phonetic,
      translation: translation,
    );
  }

  Ayah withPhonetic(String phonetic) {
    return Ayah(
      number: number,
      text: text,
      numberInSurah: numberInSurah,
      phonetic: phonetic,
      translation: translation,
    );
  }
}
