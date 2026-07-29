import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/app_route.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/profile_provider.dart';
import 'package:quiz_app/widgets/edit_profile_dialogue.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quiz_app/widgets/profile_image_widget.dart';
import 'package:quiz_app/widgets/score_card_widget.dart';
import 'package:quiz_app/models/user.dart';

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final User? profile;
  final bool isUploadingImage;
  final VoidCallback onEditImage;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;
  final double minHeight;

  _ProfileHeaderDelegate({
    required this.expandedHeight,
    required this.profile,
    required this.isUploadingImage,
    required this.onEditImage,
    required this.onEditProfile,
    required this.onLogout,
    required this.minHeight,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double safeAreaTop = MediaQuery.of(context).padding.top;
    final double maxExtent = this.maxExtent;

    final double progress = (shrinkOffset / (maxExtent - minHeight)).clamp(
      0.0,
      1.0,
    );

    final double maxAvatarRadius = 46.0;
    final double minAvatarRadius = 18.0;
    final double currentAvatarRadius =
        maxAvatarRadius - ((maxAvatarRadius - minAvatarRadius) * progress);
    final double currentAvatarSize = currentAvatarRadius * 2;

    final double screenWidth = MediaQuery.of(context).size.width;
    final double avatarLeftExpanded = (screenWidth - currentAvatarSize) / 2;
    final double avatarLeftCollapsed = 16.0;
    final double currentAvatarLeft =
        avatarLeftExpanded -
        ((avatarLeftExpanded - avatarLeftCollapsed) * progress);

    final double avatarTopExpanded = maxExtent - currentAvatarRadius;
    final double avatarTopCollapsed =
        safeAreaTop + (kToolbarHeight - currentAvatarSize) / 2;
    final double currentAvatarTop =
        avatarTopExpanded +
        ((avatarTopCollapsed - avatarTopExpanded) * progress);

    final double titleLeftExpanded = 16.0;
    final double titleLeftCollapsed = 16.0 + (minAvatarRadius * 2) + 16.0;
    final double currentTitleLeft =
        titleLeftExpanded +
        ((titleLeftCollapsed - titleLeftExpanded) * progress);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(color: const Color(0xFF6B58E9)),
        Positioned(
          top: safeAreaTop,
          left: 0,
          right: 0,
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              Row(
                children: [
                  if (profile != null)
                    Semantics(
                      label: 'Edit Profile',
                      child: IconButton(
                        tooltip: 'Edit Profile',
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          onEditProfile();
                        },
                      ),
                    ),
                  Semantics(
                    label: 'Logout',
                    child: IconButton(
                      tooltip: 'Logout',
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onLogout();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: safeAreaTop + (kToolbarHeight - 24) / 2,
          left: currentTitleLeft,
          child: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          top: currentAvatarTop,
          left: currentAvatarLeft,
          child: GestureDetector(
            onTap: progress < 0.5 ? onEditImage : null,
            child: SizedBox(
              width: currentAvatarSize,
              height: currentAvatarSize,
              child: ProfileImageWidget(
                currentImageUrl: profile?.avatarUrl,
                isLoading: isUploadingImage,
                onEditTap: progress < 0.5 ? onEditImage : null,
                radius: currentAvatarRadius,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        profile != oldDelegate.profile ||
        isUploadingImage != oldDelegate.isUploadingImage ||
        minHeight != oldDelegate.minHeight;
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadCurrentUserProfile();
      context.read<ProfileProvider>().loadPersonalResults();
    });
  }

  Future<void> _updateProfileImage(ImageSource source) async {
    try {
      await context.read<ProfileProvider>().updateProfileImage(source);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated successfully.')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                _updateProfileImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _updateProfileImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.userProfile;

    return Scaffold(
      // backgroundColor: const Color(0xFF6B58E9),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _ProfileHeaderDelegate(
              expandedHeight: 200,
              minHeight: MediaQuery.of(context).padding.top + kToolbarHeight,
              profile: profile,
              isUploadingImage: profileProvider.isUploadingImage,
              onEditImage: _showImageSourceDialog,
              onEditProfile: () {
                if (profile != null) {
                  showDialog(
                    context: context,
                    builder: (context) =>
                        EditProfileDialog(currentProfile: profile),
                  );
                }
              },
              onLogout: () {
                context.read<AuthProvider>().logout();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    Text(
                      profile?.displayName ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    if (profile?.bio != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        profile!.bio!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B58E9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            Icons.star_border,
                            'POINTS',
                            profile?.score.toString() ?? '0',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildStatItem(
                            Icons.public,
                            'WORLD RANK',
                            profile?.rank ?? '-',
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildStatItem(
                            Icons.local_police_outlined,
                            'LOCAL RANK',
                            '#56',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text(
                          'Badge',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Stats',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Column(
                          children: [
                            const Text(
                              'Details',
                              style: TextStyle(
                                color: Color(0xFF6B58E9),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const CircleAvatar(
                              radius: 3,
                              backgroundColor: Color(0xFF6B58E9),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent matches',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Selector<ProfileProvider, String>(
                            selector: (_, provider) =>
                                provider.selectedProfileFilter,
                            builder: (context, value, child) {
                              return PopupMenuButton<String>(
                                initialValue: value,
                                child: Row(
                                  children: [
                                    Text(
                                      value,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                    ),
                                  ],
                                ),
                                onSelected: (value) {
                                  context
                                          .read<ProfileProvider>()
                                          .selectedProfileFilter =
                                      value;
                                },
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'Daily',
                                    child: Text('Daily'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Monthly',
                                    child: Text('Monthly'),
                                  ),
                                  PopupMenuItem(
                                    value: 'Yearly',
                                    child: Text('Yearly'),
                                  ),
                                  PopupMenuItem(
                                    value: 'All',
                                    child: Text('All'),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingPersonalHistory) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final history = provider.personalHistory;

              if (history.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        const Text(
                          'No recent matches found.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProfileProvider>()
                                .loadPersonalResults();
                          },
                          child: const Text('refresh'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final score = history[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: Colors.white,
                    child: ScoreCardWidget(entry: score),
                  );
                }, childCount: history.length),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Semantics(
        label: 'AI Chat',
        child: FloatingActionButton(
          tooltip: 'AI Chat',
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push(AppRoute.ai);
          },
          child: const Icon(Icons.bolt, color: Color(0xFF6B58E9)),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
