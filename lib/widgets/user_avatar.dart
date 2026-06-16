// lib/widgets/user_avatar.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/app_theme.dart';

class UserAvatar extends StatelessWidget {
  final String? networkUrl;
  final String? localAssetPath;
  final double size;
  final String name;

  const UserAvatar({
    super.key,
    this.networkUrl,
    this.localAssetPath,
    required this.size,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.secondary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(child: _buildImage()),
    );
  }

  Widget _buildImage() {
    // 1. Try network URL
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: networkUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildInitials(),
        errorWidget: (_, __, ___) =>
            localAssetPath != null ? _buildLocalAsset() : _buildInitials(),
      );
    }

    // 2. Try local asset path (parent-placed photo)
    if (localAssetPath != null && localAssetPath!.isNotEmpty) {
      return _buildLocalAsset();
    }

    // 3. Fallback to initials avatar
    return _buildInitials();
  }

  Widget _buildLocalAsset() {
    // Check if it's a file path or flutter asset
    if (localAssetPath!.startsWith('/')) {
      final file = File(localAssetPath!);
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    return Image.asset(
      localAssetPath!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildInitials(),
    );
  }

  Widget _buildInitials() {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
