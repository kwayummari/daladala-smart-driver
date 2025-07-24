// lib/features/auth/presentation/pages/driver_registration_page.dart
import 'package:daladala_smart_driver/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/custom_text_field.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() => _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _vehiclePlateController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleCapacityController = TextEditingController();

  DateTime? _licenseExpiryDate;
  String _selectedVehicleType = 'Daladala';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final List<String> _vehicleTypes = ['Daladala', 'Minibus', 'Bus', 'Coaster'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _idNumberController.dispose();
    _vehiclePlateController.dispose();
    _vehicleModelController.dispose();
    _vehicleCapacityController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Driver Registration'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildPersonalInfoStep(),
                _buildLicenseInfoStep(),
                _buildVehicleInfoStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: List.generate(4, (index) {
          bool isActive = index <= _currentStep;
          bool isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isCompleted
                            ? AppTheme.successColor
                            : isActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                            : Text(
                              '${index + 1}',
                              style: TextStyle(
                                color:
                                    isActive
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color:
                          index < _currentStep
                              ? AppTheme.successColor
                              : Colors.white.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide your personal details',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 30),

            CustomTextField(
              controller: _firstNameController,
              labelText: 'First Name',
              prefixIcon: Icons.person_outline,
              validator: Validators.validateRequired,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _lastNameController,
              labelText: 'Last Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _phoneController,
              labelText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: Validators.validatePhone,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _emailController,
              labelText: 'Email (Optional)',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return Validators().validateEmail(value);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              isPasswordVisible: _isPasswordVisible,
              onTogglePasswordVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              validator: Validators.validatePassword,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _confirmPasswordController,
              labelText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              obscureText: _isConfirmPasswordVisible,
              onTogglePasswordVisibility: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return Validators.validatePassword(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'License Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your driving license details',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 30),

          CustomTextField(
            controller: _licenseNumberController,
            labelText: 'Driving License Number',
            prefixIcon: Icons.credit_card_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'License number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _selectLicenseExpiryDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _licenseExpiryDate != null
                          ? DateFormat('dd/MM/yyyy').format(_licenseExpiryDate!)
                          : 'License Expiry Date',
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _licenseExpiryDate != null
                                ? AppTheme.textPrimaryColor
                                : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppTheme.textSecondaryColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _idNumberController,
            labelText: 'National ID Number',
            prefixIcon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'ID number is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide your vehicle details',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 30),

          CustomTextField(
            controller: _vehiclePlateController,
            labelText: 'Vehicle Plate Number',
            prefixIcon: Icons.directions_car_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Plate number is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Vehicle Type Dropdown
          DropdownButtonFormField<String>(
            value: _selectedVehicleType,
            decoration: InputDecoration(
              labelText: 'Vehicle Type',
              prefixIcon: Icon(Icons.directions_bus_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items:
                _vehicleTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVehicleType = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _vehicleModelController,
            labelText: 'Vehicle Model',
            prefixIcon: Icons.car_rental_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vehicle model is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _vehicleCapacityController,
            labelText: 'Seating Capacity',
            prefixIcon: Icons.event_seat_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Capacity is required';
              }
              final capacity = int.tryParse(value);
              if (capacity == null || capacity < 1) {
                return 'Enter a valid capacity';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Registration',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your information before submitting',
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondaryColor),
          ),
          const SizedBox(height: 30),

          _buildSummaryCard(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryItem(
              'Name',
              '${_firstNameController.text} ${_lastNameController.text}',
            ),
            _buildSummaryItem('Phone', _phoneController.text),
            if (_emailController.text.isNotEmpty)
              _buildSummaryItem('Email', _emailController.text),
            _buildSummaryItem('License Number', _licenseNumberController.text),
            _buildSummaryItem(
              'License Expiry',
              _licenseExpiryDate != null
                  ? DateFormat('dd/MM/yyyy').format(_licenseExpiryDate!)
                  : 'Not set',
            ),
            _buildSummaryItem('ID Number', _idNumberController.text),
            _buildSummaryItem('Vehicle Plate', _vehiclePlateController.text),
            _buildSummaryItem('Vehicle Type', _selectedVehicleType),
            _buildSummaryItem('Vehicle Model', _vehicleModelController.text),
            _buildSummaryItem(
              'Capacity',
              '${_vehicleCapacityController.text} seats',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: AppTheme.textPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CustomButton(
                text: 'Previous',
                onPressed: _previousStep,
                type: ButtonType.secondary,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return CustomButton(
                  text: _currentStep < 3 ? 'Next' : 'Register',
                  onPressed: authProvider.isLoading ? null : _nextStep,
                  isLoading: authProvider.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _submitRegistration();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (_licenseNumberController.text.isEmpty) {
          _showSnackBar('License number is required');
          return false;
        }
        if (_licenseExpiryDate == null) {
          _showSnackBar('License expiry date is required');
          return false;
        }
        if (_licenseExpiryDate!.isBefore(DateTime.now())) {
          _showSnackBar('License has expired');
          return false;
        }
        if (_idNumberController.text.isEmpty) {
          _showSnackBar('ID number is required');
          return false;
        }
        return true;
      case 2:
        if (_vehiclePlateController.text.isEmpty) {
          _showSnackBar('Vehicle plate number is required');
          return false;
        }
        if (_vehicleModelController.text.isEmpty) {
          _showSnackBar('Vehicle model is required');
          return false;
        }
        if (_vehicleCapacityController.text.isEmpty) {
          _showSnackBar('Vehicle capacity is required');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _selectLicenseExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );

    if (picked != null) {
      setState(() {
        _licenseExpiryDate = picked;
      });
    }
  }

  Future<void> _submitRegistration() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final registrationData = {
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email':
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      'password': _passwordController.text,
      'license_number': _licenseNumberController.text.trim(),
      'license_expiry': _licenseExpiryDate!.toIso8601String(),
      'id_number': _idNumberController.text.trim(),
      'vehicle_plate_number': _vehiclePlateController.text.trim(),
      'vehicle_model': _vehicleModelController.text.trim(),
      'vehicle_type': _selectedVehicleType,
      'vehicle_capacity': int.parse(_vehicleCapacityController.text),
    };

    final success = await authProvider.registerDriver(registrationData);

    if (success) {
      _showSuccessDialog();
    } else {
      _showSnackBar(authProvider.errorMessage ?? 'Registration failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 48,
            ),
            title: const Text('Registration Successful!'),
            content: const Text(
              'Your driver registration has been submitted. Please wait for admin approval before you can start using the app.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
}
