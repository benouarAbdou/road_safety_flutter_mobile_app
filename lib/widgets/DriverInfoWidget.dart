import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_pfe/controllers/FirebaseController.dart';

class DriverInfoWidget extends StatelessWidget {
  final FirebaseController firebaseController;

  const DriverInfoWidget({
    super.key,
    required this.firebaseController,
  });

  Widget _buildInfoCard(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(value.isNotEmpty == true ? value : "N/A"),
    );
  }

  // Function to show the change password dialog
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      debugPrint(
          'Building DriverInfo: isLoading=${firebaseController.isLoadingDriverInfo.value}, '
          'driverInfo=${firebaseController.driverInfo.value}, '
          'vehicleInfo=${firebaseController.vehicleInfo.value}');

      if (firebaseController.isLoadingDriverInfo.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (firebaseController.driverInfo.value.isEmpty &&
          firebaseController.vehicleInfo.value.isEmpty) {
        debugPrint('No driver or vehicle data available');
        return const Center(
          child: Text(
            'Failed to load driver or vehicle information. Please try again.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        );
      }

      final driverInfo = firebaseController.driverInfo.value;
      final vehicleInfo = firebaseController.vehicleInfo.value;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Driver Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoCard('Full Name', driverInfo['fullName'] ?? 'N/A'),
              _buildInfoCard(
                  'Phone Number', driverInfo['phoneNumber'] ?? 'N/A'),
              _buildInfoCard('Address', driverInfo['address'] ?? 'N/A'),
              const SizedBox(height: 24),
              const Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard('Model', vehicleInfo['model'] ?? 'N/A'),
              _buildInfoCard(
                  'Registration', vehicleInfo['registration'] ?? 'N/A'),
              _buildInfoCard('Type', vehicleInfo['type'] ?? 'N/A'),
            ],
          ),
        ),
      );
    });
  }
}

// Dialog widget for changing password
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  // Function to handle password change
  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is signed in.')),
        );
        return;
      }

      // Re-authenticate the user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);

      // Update the password
      await user.updatePassword(_newPasswordController.text.trim());

      // Show success message and close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'wrong-password':
          message = 'The current password is incorrect.';
          break;
        case 'weak-password':
          message = 'The new password is too weak (minimum 6 characters).';
          break;
        case 'requires-recent-login':
          message = 'Please sign in again to update your password.';
          break;
        default:
          message = 'Failed to update password: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your current password.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a new password.';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm your new password.';
                  }
                  if (value.trim() != _newPasswordController.text.trim()) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Icon(Icons.save),
          ),
        ),
      ],
    );
  }
}
