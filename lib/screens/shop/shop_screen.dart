import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/cosmic_background.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Gemstones', 'Yantras', 'Books', 'Puja Kits', 'Reports'];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'Natural Ruby (Manik)',
      'subtitle': 'Sun Gemstone • 5 Ratti',
      'price': '₹4,500',
      'originalPrice': '₹6,000',
      'rating': '4.8',
      'icon': Icons.diamond_rounded,
      'color': const Color(0xFFE53935),
      'category': 'Gemstones',
      'badge': 'Best Seller',
    },
    {
      'name': 'Yellow Sapphire (Pukhraj)',
      'subtitle': 'Jupiter Gemstone • 6 Ratti',
      'price': '₹8,200',
      'originalPrice': '₹11,000',
      'rating': '4.9',
      'icon': Icons.hexagon_rounded,
      'color': const Color(0xFFFDD835),
      'category': 'Gemstones',
      'badge': 'Top Rated',
    },
    {
      'name': 'Sri Yantra (Gold Plated)',
      'subtitle': 'Wealth & Prosperity Yantra',
      'price': '₹1,200',
      'originalPrice': '₹1,800',
      'rating': '4.7',
      'icon': Icons.brightness_6_rounded,
      'color': const Color(0xFFFFD700),
      'category': 'Yantras',
      'badge': 'Popular',
    },
    {
      'name': 'Brihat Parashara Hora',
      'subtitle': 'Classic Vedic Astrology Book',
      'price': '₹650',
      'originalPrice': '₹900',
      'rating': '4.9',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFF7B1FA2),
      'category': 'Books',
      'badge': null,
    },
    {
      'name': 'Navagrah Puja Kit',
      'subtitle': 'Complete 9 Planet Puja Set',
      'price': '₹2,100',
      'originalPrice': '₹2,800',
      'rating': '4.6',
      'icon': Icons.spa_rounded,
      'color': const Color(0xFF00897B),
      'category': 'Puja Kits',
      'badge': 'Premium',
    },
    {
      'name': 'Personal Kundali Report',
      'subtitle': 'Detailed 40-Page PDF Report',
      'price': '₹999',
      'originalPrice': '₹1,500',
      'rating': '5.0',
      'icon': Icons.description_rounded,
      'color': const Color(0xFF1565C0),
      'category': 'Reports',
      'badge': 'Digital',
    },
    {
      'name': 'Blue Sapphire (Neelam)',
      'subtitle': 'Saturn Gemstone • 4 Ratti',
      'price': '₹12,000',
      'originalPrice': '₹16,000',
      'rating': '4.8',
      'icon': Icons.diamond_rounded,
      'color': const Color(0xFF1976D2),
      'category': 'Gemstones',
      'badge': null,
    },
    {
      'name': 'Vastu Shastra Guide',
      'subtitle': 'Home & Office Harmony Book',
      'price': '₹480',
      'originalPrice': '₹750',
      'rating': '4.5',
      'icon': Icons.menu_book_rounded,
      'color': const Color(0xFFE65100),
      'category': 'Books',
      'badge': 'New',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGold),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Astrocare Shop', style: GoogleFonts.cinzel(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.lightGold, letterSpacing: 1.2)),
                        Text('கடை • Sacred Cosmic Store', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGold.withOpacity(0.5)),
                      ),
                      child: const Icon(Icons.shopping_cart_outlined, color: AppColors.lightGold, size: 22),
                    ),
                  ],
                ).animate().fade(duration: 500.ms),
              ),

              // Coming Soon Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [AppColors.primaryGold.withOpacity(0.25), AppColors.purpleAccent.withOpacity(0.2)]),
                    border: Border.all(color: AppColors.primaryGold.withOpacity(0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.rocket_launch_rounded, color: AppColors.lightGold, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Launching Soon!', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 13)),
                            Text('Pre-register for exclusive early access offers', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('Notify Me', style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ).animate().fade(delay: 100.ms),
              ),

              const SizedBox(height: 14),

              // Category Filter
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSel = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primaryGold.withOpacity(0.2) : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSel ? AppColors.lightGold : Colors.white12),
                        ),
                        child: Text(cat, style: GoogleFonts.poppins(
                            color: isSel ? AppColors.lightGold : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.normal)),
                      ),
                    );
                  },
                ),
              ).animate().fade(delay: 150.ms),

              const SizedBox(height: 14),

              // Product Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final p = _filteredProducts[index];
                    return _buildProductCard(context, p, index);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> p, int index) {
    final color = p['color'] as Color;
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${p["name"]} — Coming Soon!', style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.cardSurface,
          border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 12, spreadRadius: 1)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Area
            Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.25), AppColors.backgroundMid],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(p['icon'] as IconData, color: color, size: 52)),
                  if (p['badge'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(p['badge'] as String, style: GoogleFonts.poppins(color: AppColors.textDark, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cinzel(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(p['subtitle'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 9.5)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 13),
                            const SizedBox(width: 2),
                            Text(p['rating'] as String, style: GoogleFonts.poppins(color: AppColors.lightGold, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(p['price'] as String, style: GoogleFonts.cinzel(color: AppColors.lightGold, fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 4),
                            Text(p['originalPrice'] as String,
                                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 9, decoration: TextDecoration.lineThrough)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 60 * index)).fade().slideY(begin: 0.1, end: 0),
    );
  }
}
