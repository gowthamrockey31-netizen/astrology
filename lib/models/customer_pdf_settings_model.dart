import 'pdf_fixed_content_config.dart';

/// Customer / Astrologer Company Details for PDF Generation.
/// Software Footer and Slokam are admin-customizable with default fallback.
class CustomerPdfSettings {
  final String astrologerName;
  final String companyName;
  final String titleSubtitle;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String gstNumber;
  final String invocationText;
  final String? customSoftwareFooter;
  final String? customSlokaFooter;

  /// Application-defined software footer (Admin-customizable with default fallback)
  String get softwareFooter =>
      (customSoftwareFooter != null && customSoftwareFooter!.trim().isNotEmpty)
          ? customSoftwareFooter!
          : PdfFixedContentConfig.softwareFooter;

  /// Application-defined slokam (Admin-customizable with default fallback)
  String get slokaFooter =>
      (customSlokaFooter != null && customSlokaFooter!.trim().isNotEmpty)
          ? customSlokaFooter!
          : PdfFixedContentConfig.slokaFooter;

  const CustomerPdfSettings({
    this.astrologerName = 'R.செந்தில்குமார்(ஜோதிஷ ஆதித்யா)',
    this.companyName = 'ஸ்ரீகல்யாணவிநாயகர்ஜோதிட நிலையம்',
    this.titleSubtitle = 'வேத ஜோதிடம், ஜாதகம், திருமணபொருத்தம் & பிரசன்ன',
    this.address = '12/5-24b பெத்தல் சுப்பையன் தெரு, மேட்டுப்பட்டி, சின்னாளபட்டி-624301',
    this.phone = '+91 9500813709',
    this.email = 'astrogowtham@gmail.com',
    this.website = 'www.astrodashacare.in',
    this.gstNumber = '',
    this.invocationText = 'ஸ்ரீபொம்மமையசுவாமி துணை',
    this.customSoftwareFooter,
    this.customSlokaFooter,
  });

  Map<String, dynamic> toJson() => {
        'astrologerName': astrologerName,
        'companyName': companyName,
        'titleSubtitle': titleSubtitle,
        'address': address,
        'phone': phone,
        'email': email,
        'website': website,
        'gstNumber': gstNumber,
        'invocationText': invocationText,
        'customSoftwareFooter': customSoftwareFooter,
        'customSlokaFooter': customSlokaFooter,
      };

  factory CustomerPdfSettings.fromJson(Map<String, dynamic> json) => CustomerPdfSettings(
        astrologerName: json['astrologerName'] as String? ?? 'R.செந்தில்குமார்(ஜோதிஷ ஆதித்யா)',
        companyName: json['companyName'] as String? ?? 'ஸ்ரீகல்யாணவிநாயகர்ஜோதிட நிலையம்',
        titleSubtitle: json['titleSubtitle'] as String? ?? 'வேத ஜோதிடம், ஜாதகம், திருமணபொருத்தம் & பிரசன்ன',
        address: json['address'] as String? ?? '12/5-24b பெத்தல் சுப்பையன் தெரு, மேட்டுப்பட்டி, சின்னாளபட்டி-624301',
        phone: json['phone'] as String? ?? '+91 9500813709',
        email: json['email'] as String? ?? 'astrogowtham@gmail.com',
        website: json['website'] as String? ?? 'www.astrodashacare.in',
        gstNumber: json['gstNumber'] as String? ?? '',
        invocationText: json['invocationText'] as String? ?? 'ஸ்ரீபொம்மமையசுவாமி துணை',
        customSoftwareFooter: json['customSoftwareFooter'] as String?,
        customSlokaFooter: json['customSlokaFooter'] as String?,
      );

  CustomerPdfSettings copyWith({
    String? astrologerName,
    String? companyName,
    String? titleSubtitle,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? gstNumber,
    String? invocationText,
    String? customSoftwareFooter,
    String? customSlokaFooter,
  }) {
    return CustomerPdfSettings(
      astrologerName: astrologerName ?? this.astrologerName,
      companyName: companyName ?? this.companyName,
      titleSubtitle: titleSubtitle ?? this.titleSubtitle,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      gstNumber: gstNumber ?? this.gstNumber,
      invocationText: invocationText ?? this.invocationText,
      customSoftwareFooter: customSoftwareFooter ?? this.customSoftwareFooter,
      customSlokaFooter: customSlokaFooter ?? this.customSlokaFooter,
    );
  }
}
