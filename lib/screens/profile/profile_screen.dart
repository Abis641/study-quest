// lib/screens/profile/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../config/app_theme.dart';
import '../../models/lesson_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/stats_bar.dart';
import '../../widgets/tv_focusable_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: userAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No profile found'));
          }

          return Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  _ProfileHeader(user: user, ref: ref),

                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        StatsBar(user: user),
                        const SizedBox(height: 32),

                        // Subject progress
                        Text(
                          'Subject Progress',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: SubjectData.all.map((subject) {
                            final progressAsync =
                                ref.watch(progressProvider(subject.id));
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: _SubjectProgressCard(
                                  subject: subject,
                                  progressAsync: progressAsync,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),

                        // Info cards
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _InfoCard(
                                title: 'About Me',
                                items: [
                                  _InfoItem(
                                      icon: '👤', label: 'Name', value: user.name),
                                  _InfoItem(
                                      icon: '🎂',
                                      label: 'Age',
                                      value: '${user.age} years old'),
                                  _InfoItem(
                                      icon: '📚',
                                      label: 'Grade',
                                      value: 'Grade ${user.grade}'),
                                  _InfoItem(
                                      icon: '❤️',
                                      label: 'Favorite Subject',
                                      value: user.favoriteSubject),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InfoCard(
                                title: 'My Records',
                                items: [
                                  _InfoItem(
                                      icon: '⚡',
                                      label: 'Level',
                                      value: '${user.level}'),
                                  _InfoItem(
                                      icon: '✨',
                                      label: 'Total XP',
                                      value: '${user.xp} / ${user.xpForNextLevel}'),
                                  _InfoItem(
                                      icon: '🔥',
                                      label: 'Best Streak',
                                      value: '${user.longestStreak} days'),
                                  _InfoItem(
                                      icon: '🪙',
                                      label: 'Coins',
                                      value: '${user.coins}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final WidgetRef ref;

  const _ProfileHeader({required this.user, required this.ref});

  Future<void> _pickImage(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 400,
      );
      if (picked == null) return;

      final uid = ref.read(currentUserIdProvider);
      if (uid == null) return;

      final file = File(picked.path);
      final storageService = ref.read(storageServiceProvider);
      final userService = ref.read(userServiceProvider);

      final url = await storageService.uploadProfileImage(uid, file);
      if (url != null) {
        await userService.updateUser(uid, {'avatarUrl': url});
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update photo')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 32),
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: Row(
        children: [
          TVFocusableCard(
            onTap: () => Navigator.of(context).pop(),
            backgroundColor: Colors.white.withOpacity(0.15),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.arrow_back_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 24),
          Stack(
            children: [
             UserAvatar(
                networkUrl: user.avatarUrl,
                size: 100,
                name: user.name,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _pickImage(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Level ${user.level} • Grade ${user.grade}',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _HeaderBadge(emoji: '🔥', label: '${user.currentStreak}d streak'),
                  const SizedBox(width: 8),
                  _HeaderBadge(emoji: '⭐', label: '${user.stars} stars'),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

class _HeaderBadge extends StatelessWidget {
  final String emoji;
  final String label;

  const _HeaderBadge({required this.emoji, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$emoji $label',
        style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SubjectProgressCard extends StatelessWidget {
  final SubjectModel subject;
  final AsyncValue progressAsync;

  const _SubjectProgressCard({
    required this.subject,
    required this.progressAsync,
  });

  @override
  Widget build(BuildContext context) {
    return TVFocusableCard(
      onTap: () {},
      backgroundColor: AppTheme.cardBase,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(subject.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          Text(
            subject.name,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          progressAsync.when(
            loading: () =>
                const SizedBox(height: 6, child: LinearProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
            data: (progress) {
              final xp = progress?.totalXpEarned ?? 0;
              final accuracy = progress?.accuracy ?? 0;
              return Column(
                children: [
                  Text(
                    '$xp XP',
                    style: const TextStyle(
                      color: AppTheme.tertiary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${accuracy.round()}% acc',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;

  const _InfoCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBase,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(item.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.label,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 11),
                        ),
                        Text(
                          item.value,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String icon;
  final String label;
  final String value;

  const _InfoItem(
      {required this.icon, required this.label, required this.value});
}
