import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/artisan.dart';
import '../data/mock_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Artisan get artisan => MockData.currentArtisan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB85C38), Color(0xFFD4A017)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        artisan.avatarEmoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    artisan.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white70, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${artisan.location}, ${artisan.state}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    artisan.craftSpecialization,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        value: '${artisan.totalProducts}',
                        label: 'Products',
                      ),
                      _Divider(),
                      _StatItem(
                        value: '${artisan.totalOrders}',
                        label: 'Orders',
                      ),
                      _Divider(),
                      _StatItem(
                        value: '₹${(artisan.totalSales / 1000).toStringAsFixed(1)}K',
                        label: 'Sales',
                      ),
                      _Divider(),
                      _StatItem(
                        value: '${artisan.rating}⭐',
                        label: 'Rating',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bio
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.divider),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About Me',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          artisan.bio,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(height: 1.6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Craft specializations
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.divider),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crafts Offered',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: artisan.craftsOffered.map((craft) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.08),
                                borderRadius: AppTheme.chipRadius,
                                border: Border.all(
                                    color:
                                        AppTheme.primary.withOpacity(0.25)),
                              ),
                              child: Text(
                                craft,
                                style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Language preference
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: AppTheme.cardRadius,
                      border: Border.all(color: AppTheme.divider),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Text('🌐', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Preferred Language',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium),
                            Text(
                              artisan.preferredLanguage,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _showLanguagePicker(context),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Actions
                  Text('Account',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Edit profile — coming in full version!'),
                        ),
                      );
                    },
                  ),
                  _ActionTile(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {},
                  ),
                  _ActionTile(
                    icon: Icons.info_outline,
                    label: 'About KalaSaathi',
                    onTap: () => _showAbout(context),
                  ),
                  _ActionTile(
                    icon: Icons.logout,
                    label: 'Logout',
                    color: AppTheme.error,
                    onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                      '/onboarding',
                      (route) => false,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // SIH badge
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            borderRadius: AppTheme.cardRadius,
                            border: Border.all(
                                color: AppTheme.primary.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              const Text('🏆',
                                  style: TextStyle(fontSize: 28)),
                              const SizedBox(height: 6),
                              Text(
                                'Smart India Hackathon 2026',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppTheme.primary),
                              ),
                              Text(
                                'SIH26090 — Heritage & Culture',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: AppTheme.cardRadius),
        title: Row(
          children: [
            const Text('🎨'),
            const SizedBox(width: 8),
            Text('KalaSaathi',
                style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empowering Artisans, Connecting Crafts to the World.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Problem Statement: SIH26090\nTheme: Heritage & Culture\nCategory: Software',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version: 1.0.0 Prototype',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Preferred Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...MockData.supportedLanguages.map((lang) {
              final isCurrent = lang['name'] == artisan.preferredLanguage;
              return ListTile(
                leading: Text(lang['flag'] ?? '🇮🇳', style: const TextStyle(fontSize: 24)),
                title: Text(
                  lang['name'] ?? '',
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isCurrent
                    ? const Icon(Icons.check_circle, color: AppTheme.secondary)
                    : null,
                onTap: () {
                  setState(() {
                    MockData.currentArtisan = MockData.currentArtisan.copyWith(
                      preferredLanguage: lang['name']!,
                    );
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withOpacity(0.3),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: AppTheme.divider),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? AppTheme.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: color ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: color ?? AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
