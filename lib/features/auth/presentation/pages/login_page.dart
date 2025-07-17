// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSavedCredentials();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _loadSavedCredentials() {
    // TODO: Load saved credentials from shared preferences
    // For now, leave empty
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _phoneFocusNode.unfocus();
    _passwordFocusNode.unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (success && mounted) {
      _navigateToDashboard();
    } else if (mounted) {
      _showErrorSnackBar(authProvider.errorMessage ?? 'Login failed');
    }
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const DashboardPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Logo and Title
                  _buildHeader(),

                  const SizedBox(height: 60),

                  // Login Form
                  _buildLoginForm(),

                  const SizedBox(height: 40),

                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(Icons.local_taxi, size: 50, color: Colors.white),
        ),

        const SizedBox(height: 20),

        // Title
        Text(
          'Welcome Driver',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Sign in to start your journey',
          style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phone Number Field
          CustomTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            labelText: 'Phone Number',
            hintText: '+255 712 345 678',
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: Validators.validatePhone,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
            ],
          ),

          const SizedBox(height: 20),

          // Password Field
          CustomTextField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            onFieldSubmitted: (_) => _login(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondaryColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Remember Me
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              Text(
                'Remember me',
                style: TextStyle(color: AppTheme.textSecondaryColor),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to forgot password
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Login Button
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return CustomButton(
                text: 'Sign In',
                onPressed: authProvider.isLoading ? null : _login,
                isLoading: authProvider.isLoading,
                type: ButtonType.primary,
                isFullWidth: true,
                height: 56,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.textTertiaryColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Need Help?',
                style: TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.textTertiaryColor)),
          ],
        ),

        const SizedBox(height: 20),

        // Support Button
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Open support/contact
          },
          icon: Icon(Icons.support_agent, color: AppTheme.primaryColor),
          label: Text(
            'Contact Support',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // App Version
        Text(
          'Daladala Smart Driver v1.0.0',
          style: TextStyle(color: AppTheme.textTertiaryColor, fontSize: 12),
        ),
      ],
    );
  }
}
