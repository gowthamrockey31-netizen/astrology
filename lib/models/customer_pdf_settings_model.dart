import 'pdf_fixed_content_config.dart';

/// Customer / Astrologer Company Details for PDF Generation.
/// Only authorized customer/company information is editable.
/// Software Footer and Slokam are permanent application-controlled fixed content.
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

  /// Permanent application-defined software footer (Not user-editable)
  String get softwareFooter => PdfFixedContentConfig.softwareFooter;

  /// Permanent application-defined slokam (Not user-editable)
  String get slokaFooter => PdfFixedContentConfig.slokaFooter;

  const CustomerPdfSettings({
    this.astrologerName = 'R.செந்தில்குமார் (ஜோதிஷ ஆதித்யா)',
    this.companyName = 'ஸ்ரீ கல்யாண விநாயகர் ஜோதிட நிலையம்',
    this.titleSubtitle = 'வேத ஜோதிடம், ஜாதகம், திருமண பொருத்தம் & பிரசன்னம்',
    this.address = '12/5-24b பெத்தல் சுப்பையன் தெரு, மேட்டுப்பட்டி, சின்னாளபட்டி-624301',
    this.phone = '+91 9500813709',
    this.email = 'astrogowtham@gmail.com',
    this.website = 'www.astrodashacare.in',
    this.gstNumber = '',
    this.invocationText = 'ஸ்ரீ பொம்மமையசுவாமி துணை',
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
      };

  factory CustomerPdfSettings.fromJson(Map<String, dynamic> json) => CustomerPdfSettings(
        astrologerName: json['astrologerName'] as String? ?? 'R.செந்தில்குமார் (ஜோதிஷ ஆதித்யா)',
        companyName: json['companyName'] as String? ?? 'ஸ்ரீ கல்யாண விநாயகர் ஜோதிட நிலையம்',
        titleSubtitle: json['titleSubtitle'] as String? ?? 'வேத ஜோதிடம், ஜாதகம், திருமண பொருத்தம் & பிரசன்னம்',
        address: json['address'] as String? ?? '12/5-24b பெத்தல் சுப்பையன் தெரு, மேட்டுப்பட்டி, சின்னாளபட்டி-624301',
        phone: json['phone'] as String? ?? '+91 9500813709',
        email: json['email'] as String? ?? 'astrogowtham@gmail.com',
        website: json['website'] as String? ?? 'www.astrodashacare.in',
        gstNumber: json['gstNumber'] as String? ?? '',
        invocationText: json['invocationText'] as String? ?? 'ஸ்ரீ பொம்மமையசுவாமி துணை',
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
    );
  }
}
