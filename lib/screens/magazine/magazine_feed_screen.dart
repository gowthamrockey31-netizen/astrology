import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/file_picker_helper.dart' as filePicker;
import '../../core/theme/app_colors.dart';
import '../../models/magazine_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/cosmic_background.dart';

class MagazineFeedScreen extends StatefulWidget {
  const MagazineFeedScreen({super.key});

  @override
  State<MagazineFeedScreen> createState() => _MagazineFeedScreenState();
}

class _MagazineFeedScreenState extends State<MagazineFeedScreen> {
  final List<MagazineArticleModel> _articles = MockDataService.magazineArticles;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Vedic Predictions', 'Kundli Deep Dive', 'Vastu Shastra', 'Remedies'];

  void _pickImageFile(Function(String photoDataUrl) onPicked) {
    if (kIsWeb) {
      filePicker.pickImageFile(onPicked);
    }
  }

  void _showArticleFormDialog({MagazineArticleModel? articleToEdit}) async {
    final isEditing = articleToEdit != null;
    final titleCtrl = TextEditingController(text: isEditing ? articleToEdit.title : '');
    final authorCtrl = TextEditingController(text: isEditing ? articleToEdit.author : 'Astrocare Editorial');
    final summaryCtrl = TextEditingController(text: isEditing ? articleToEdit.summary : '');
    final contentCtrl = TextEditingController(text: isEditing ? articleToEdit.content : '');
    String selectedCategory = isEditing ? articleToEdit.category : 'Vedic Predictions';
    String selectedImageUrl = isEditing
        ? articleToEdit.imageUrl
        : 'https://images.unsplash.com/photo-1532968961962-8a0cb3a2d4f5?auto=format&fit=crop&w=600&q=80';

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.backgroundMid,
              insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.borderGold, width: 1.5),
              ),
              title: Row(
                children: [
                  Icon(
                    isEditing ? Icons.edit_note_rounded : Icons.post_add_rounded,
                    color: AppColors.lightGold,
                    size: 26,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEditing ? "Edit Article" : "Create New Article",
                      style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Upload / Dropzone
                      Text("Cover Image", style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () {
                          _pickImageFile((dataUrl) {
                            setModalState(() {
                              selectedImageUrl = dataUrl;
                            });
                          });
                        },
                        child: Container(
                          width: double.infinity,
                          height: 110,
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryGold, width: 1.2),
                            image: DecorationImage(
                              image: NetworkImage(selectedImageUrl),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_rounded, color: AppColors.lightGold, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                "Tap to Pick / Upload Photo File",
                                style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category Selector
                      Text("Category", style: GoogleFonts.outfit(color: AppColors.lightGold, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        dropdownColor: AppColors.backgroundMid,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(),
                        ),
                        items: ['Vedic Predictions', 'Kundli Deep Dive', 'Vastu Shastra', 'Remedies'].map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: titleCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Article Title", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: authorCtrl,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Author Name", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: summaryCtrl,
                        maxLines: 2,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Summary / Teaser", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: contentCtrl,
                        maxLines: 4,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(labelText: "Article Body Content", labelStyle: TextStyle(color: AppColors.lightGold)),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGold),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty) return;
                    Navigator.of(ctx).pop(true);
                  },
                  child: Text(
                    isEditing ? "Save Changes" : "Publish Article",
                    style: GoogleFonts.poppins(color: AppColors.textDark, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final newArticle = MagazineArticleModel(
        id: isEditing ? articleToEdit.id : 'art_${DateTime.now().millisecondsSinceEpoch}',
        title: titleCtrl.text.trim(),
        category: selectedCategory,
        summary: summaryCtrl.text.trim(),
        content: contentCtrl.text.trim().isNotEmpty ? contentCtrl.text.trim() : summaryCtrl.text.trim(),
        imageUrl: selectedImageUrl,
        author: authorCtrl.text.trim(),
        publishedAt: isEditing ? articleToEdit.publishedAt : DateTime.now(),
        likesCount: isEditing ? articleToEdit.likesCount : 0,
        commentsCount: isEditing ? articleToEdit.commentsCount : 0,
      );

      if (isEditing) {
        await FirestoreService.editMagazineArticle(newArticle);
      } else {
        await FirestoreService.addMagazineArticle(newArticle);
      }

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing ? "Article updated successfully!" : "New article published successfully!",
              style: GoogleFonts.poppins(color: AppColors.lightGold),
            ),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  void _confirmDeleteArticle(MagazineArticleModel article) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        title: Text("Delete Article", style: GoogleFonts.cinzel(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete '${article.title}'?", style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text("Delete", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirestoreService.deleteMagazineArticle(article.id);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'${article.title}' has been deleted.", style: GoogleFonts.poppins(color: AppColors.lightGold)),
            backgroundColor: AppColors.backgroundMid,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = AuthService.activeRole == 'Admin';
    final filtered = _selectedCategory == 'All'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMid,
        title: Text('Astrocare Magazine', style: GoogleFonts.cinzel(color: AppColors.lightGold, fontWeight: FontWeight.bold)),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.post_add_rounded, color: AppColors.lightGold, size: 28),
              onPressed: () => _showArticleFormDialog(),
            ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryGold,
              onPressed: () => _showArticleFormDialog(),
              icon: const Icon(Icons.add_rounded, color: AppColors.textDark),
              label: Text("Add Article", style: GoogleFonts.outfit(color: AppColors.textDark, fontWeight: FontWeight.bold)),
            )
          : null,
      body: CosmicBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Category Filter Bar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _categories.map((cat) {
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
                        child: Text(
                          cat,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSel ? AppColors.lightGold : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Articles Feed List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          "No articles in this category",
                          style: GoogleFonts.poppins(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final article = filtered[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderGold.withOpacity(0.4)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      child: Image.network(
                                        article.imageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: AppColors.backgroundMid,
                                          child: const Icon(Icons.auto_stories, color: AppColors.lightGold, size: 48),
                                        ),
                                      ),
                                    ),
                                    if (isAdmin)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: AppColors.backgroundMid.withOpacity(0.85),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.edit_outlined, color: AppColors.lightGold, size: 18),
                                                onPressed: () => _showArticleFormDialog(articleToEdit: article),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor: AppColors.backgroundMid.withOpacity(0.85),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                                                onPressed: () => _confirmDeleteArticle(article),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryGold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          article.category,
                                          style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.lightGold),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        article.title,
                                        style: GoogleFonts.cinzel(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article.summary,
                                        style: GoogleFonts.outfit(fontSize: 13, color: AppColors.textSecondary),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('By ${article.author}', style: GoogleFonts.outfit(fontSize: 11, color: AppColors.lightGold)),
                                          Row(
                                            children: [
                                              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16),
                                              Text(' ${article.likesCount}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                              const SizedBox(width: 12),
                                              const Icon(Icons.comment_rounded, color: AppColors.lightGold, size: 16),
                                              Text(' ${article.commentsCount}', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
