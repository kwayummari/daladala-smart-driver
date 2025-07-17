// lib/features/profile/presentation/pages/profile_page.dart
import 'package:daladala_smart_driver/core/ui/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/earnings_summary_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading profile...');
          }

          final driver = authProvider.driver;

          if (driver == null) {
            return const Center(
              child: Text('Driver information not available'),
            );
          }

          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(driver),
                ),
                actions: [
                  IconButton(
                    onPressed: () => _showEditProfileDialog(context),
                    icon: const Icon(Icons.edit),
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Stats Cards
                        _buildStatsSection(driver),

                        const SizedBox(height: 20),

                        // Earnings Summary
                        EarningsSummaryCard(driver: driver),

                        const SizedBox(height: 20),

                        // Profile Info
                        ProfileInfoCard(driver: driver),

                        const SizedBox(height: 20),

                        // Menu Items
                        _buildMenuSection(context),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(driver) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Profile Picture
              GestureDetector(
                onTap: () => _changeProfilePicture(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        driver.profilePicture != null
                            ? Image.network(
                              driver.profilePicture!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildDefaultAvatar(driver);
                              },
                            )
                            : _buildDefaultAvatar(driver),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Driver Name
              Text(
                driver.fullName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 4),

              // Driver Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getDriverStatusColor(
                    driver.status,
                  ).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.getDriverStatusColor(driver.status),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.getDriverStatusColor(driver.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      driver.status.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.getDriverStatusColor(driver.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < driver.rating.round()
                          ? Icons.star
                          : Icons.star_border,
                      color: AppTheme.accentColor,
                      size: 20,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${driver.rating.toStringAsFixed(1)} (${driver.totalRatings} reviews)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(driver) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppTheme.accentColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          driver.fullName.isNotEmpty ? driver.fullName[0].toUpperCase() : 'D',
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(driver) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ProfileStatCard(
              icon: Icons.star,
              title: 'Rating',
              value: driver.rating.toStringAsFixed(1),
              color: AppTheme.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.reviews,
              title: 'Reviews',
              value: driver.totalRatings.toString(),
              color: AppTheme.infoColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ProfileStatCard(
              icon: Icons.route,
              title: 'Trips',
              value: '1,234', // This would come from trip stats
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),

          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ProfileMenuItem(
                  icon: Icons.person,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () => _showEditProfileDialog(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.directions_car,
                  title: 'Vehicle Information',
                  subtitle: 'Manage your vehicle details',
                  onTap: () => _showVehicleInfo(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.account_balance_wallet,
                  title: 'Earnings',
                  subtitle: 'View your earnings history',
                  onTap: () => _showEarningsHistory(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.history,
                  title: 'Trip History',
                  subtitle: 'View your completed trips',
                  onTap: () => _showTripHistory(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage notification settings',
                  onTap: () => _showNotificationSettings(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.help,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  onTap: () => _showHelpSupport(context),
                ),
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App version and information',
                  onTap: () => _showAbout(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Logout Button
          CustomButton(
            text: 'Logout',
            onPressed: () => _showLogoutDialog(context),
            type: ButtonType.secondary,
            backgroundColor: AppTheme.errorColor,
            textColor: Colors.white,
            icon: Icons.logout,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _changeProfilePicture(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change Profile Picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImagePickerOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          // TODO: Upload image to server
                          _uploadProfilePicture(File(image.path));
                        }
                      },
                    ),
                    _buildImagePickerOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 512,
                          maxHeight: 512,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          // TODO: Upload image to server
                          _uploadProfilePicture(File(image.path));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildImagePickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadProfilePicture(File imageFile) {
    // TODO: Implement image upload to server
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile picture updated successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driver = authProvider.driver;

    if (driver == null) return;

    final firstNameController = TextEditingController(text: driver.firstName);
    final lastNameController = TextEditingController(text: driver.lastName);
    final emailController = TextEditingController(text: driver.email);
    final phoneController = TextEditingController(text: driver.phone);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Profile'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Update profile information
                  Navigator.pop(context);
                  _updateProfile(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    email: emailController.text,
                    phone: phoneController.text,
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    // TODO: Implement profile update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showVehicleInfo(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final driver = authProvider.driver;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Vehicle Information'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plate Number: Unknown'), // TODO: Get from vehicle data
                const SizedBox(height: 8),
                Text('Model: Unknown'),
                const SizedBox(height: 8),
                Text('Capacity: Unknown'),
                const SizedBox(height: 8),
                Text('Type: Unknown'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Navigate to vehicle edit page
                },
                child: const Text('Edit'),
              ),
            ],
          ),
    );
  }

  void _showEarningsHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Earnings History'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Column(
                children: [
                  Text('Total Earnings: TZS 0'), // TODO: Get from earnings data
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView(
                      children: [
                        ListTile(
                          title: const Text('Today'),
                          trailing: Text('TZS 0'),
                        ),
                        ListTile(
                          title: const Text('This Week'),
                          trailing: Text('TZS 0'),
                        ),
                        ListTile(
                          title: const Text('This Month'),
                          trailing: Text('TZS 0'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showTripHistory(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Trip History'),
            content: const Text('Your trip history will be displayed here.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Notification Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Trip Notifications'),
                  subtitle: const Text('Get notified about trip updates'),
                  value: true, // TODO: Get from settings
                  onChanged: (value) {
                    // TODO: Update setting
                  },
                ),
                SwitchListTile(
                  title: const Text('Passenger Notifications'),
                  subtitle: const Text('Get notified about passenger actions'),
                  value: true, // TODO: Get from settings
                  onChanged: (value) {
                    // TODO: Update setting
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showHelpSupport(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Call Support'),
                  subtitle: const Text('+255 123 456 789'),
                  onTap: () {
                    // TODO: Launch phone dialer
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email Support'),
                  subtitle: const Text('support@daladalasmart.com'),
                  onTap: () {
                    // TODO: Launch email client
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('FAQ'),
                  onTap: () {
                    // TODO: Open FAQ page
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('About'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daladala Smart Driver',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Version: 1.0.0'),
                const SizedBox(height: 8),
                Text('Build: 100'),
                const SizedBox(height: 16),
                Text(
                  'Daladala Smart Driver is your companion app for managing trips, passengers, and earnings efficiently.',
                  style: TextStyle(color: AppTheme.textSecondaryColor),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.logout, color: AppTheme.errorColor),
                const SizedBox(width: 8),
                const Text('Logout'),
              ],
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _performLogout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.logout();

    if (success && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Logout failed'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}
