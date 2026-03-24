class DuaCategory {
  final int id;
  final String titleEn;
  final String titleFr;
  final String titleAr;
  final List<Dua> duas;

  const DuaCategory({
    required this.id,
    required this.titleEn,
    required this.titleFr,
    required this.titleAr,
    required this.duas,
  });

  /// Returns the title in the appropriate language.
  String title(String locale) {
    if (locale == 'ar') return titleAr.isNotEmpty ? titleAr : titleEn;
    if (locale == 'fr') return titleFr.isNotEmpty ? titleFr : titleEn;
    return titleEn;
  }

  factory DuaCategory.fromJson(Map<String, dynamic> json) {
    return DuaCategory(
      id: json['id'] as int,
      titleEn: json['title_en'] as String,
      titleFr: json['title_fr'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? '',
      duas: (json['duas'] as List)
          .map((d) => Dua.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Dua {
  final int id;
  final String arabic;
  final String phonetic;
  final String translationEn;
  final String translationFr;
  final String reference;

  const Dua({
    required this.id,
    required this.arabic,
    required this.phonetic,
    required this.translationEn,
    required this.translationFr,
    required this.reference,
  });

  /// Returns translation for the given locale.
  /// Arabic users see no translation (they read the arabic text directly).
  String? translation(String locale) {
    if (locale == 'ar') return null;
    if (locale == 'fr' && translationFr.isNotEmpty) return translationFr;
    return translationEn.isNotEmpty ? translationEn : null;
  }

  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as int,
      arabic: json['arabic'] as String,
      phonetic: json['phonetic'] as String? ?? '',
      translationEn: json['translation_en'] as String,
      translationFr: json['translation_fr'] as String? ?? '',
      reference: json['reference'] as String,
    );
  }
}
