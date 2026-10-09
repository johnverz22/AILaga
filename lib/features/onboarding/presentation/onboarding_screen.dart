import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utilities/uuid_generator.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../care_recipient/domain/care_recipient_entity.dart';
import '../../family_contacts/data/family_contact_providers.dart';
import '../../family_contacts/domain/family_contact_entity.dart';
import '../../medications/data/medication_providers.dart';
import '../../medications/domain/medication_entity.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Care Recipient Data
  String? _careRecipientId;
  final _nameController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _notesController = TextEditingController();

  // Emergency Contact Data
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactRelationController = TextEditingController();

  // Medication Data
  final _medNameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactRelationController.dispose();
    _medNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _createCareRecipient() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(careRecipientRepositoryProvider);
      final id = UuidGenerator.generate();
      final now = DateTime.now();

      final entity = CareRecipientEntity(
        id: id,
        displayName: _nameController.text.trim(),
        allergies: _allergiesController.text.trim().isEmpty
            ? null
            : _allergiesController.text.trim(),
        importantNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await repo.create(entity);
      _careRecipientId = id;

      // Refresh provider
      ref.invalidate(primaryCareRecipientProvider);

      _nextPage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEmergencyContact() async {
    final name = _contactNameController.text.trim();
    final phone = _contactPhoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and phone')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(familyContactRepositoryProvider);
      final now = DateTime.now();

      final entity = FamilyContactEntity(
        id: UuidGenerator.generate(),
        careRecipientId: _careRecipientId!,
        displayName: name,
        phoneNumber: phone,
        relationship: _contactRelationController.text.trim(),
        isEmergencyContact: true,
        sortOrder: 0,
        createdAt: now,
        updatedAt: now,
      );

      await repo.create(entity);
      _nextPage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMedication() async {
    final name = _medNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medication name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(medicationRepositoryProvider);
      final now = DateTime.now();

      final entity = MedicationScheduleEntity(
        id: UuidGenerator.generate(),
        careRecipientId: _careRecipientId!,
        medicationName: name,
        scheduleTimes: jsonEncode(['08:00']), // default morning time
        startDate: now,
        isActive: true,
        createdAt: now,
        updatedAt: now,
      );

      await repo.createSchedule(entity);
      _nextPage();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted || status.isDenied || status.isPermanentlyDenied) {
      _nextPage();
    }
  }

  void _completeOnboarding() {
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 7,
              backgroundColor: Colors.grey[200],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1Welcome(),
                  _buildStep2CareRecipient(),
                  _buildStep3EmergencyContact(),
                  _buildStep4Medication(),
                  _buildStep5Notifications(),
                  _buildStep6Ready(),
                  _buildStep7CloudBackup(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Welcome() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.health_and_safety, size: 80, color: Colors.teal),
          const SizedBox(height: 24),
          Text('Welcome to AILaga',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text('Your personal caregiving assistant',
              textAlign: TextAlign.center),
          const SizedBox(height: 48),
          _buildInfoBox(
            icon: Icons.privacy_tip,
            title: 'Privacy First',
            description:
                'Your data stays on this device. No account needed. No internet required.',
          ),
          const SizedBox(height: 16),
          _buildInfoBox(
            icon: Icons.warning,
            title: 'Safety Notice',
            description: 'AILaga is not a medical device or diagnostic tool.',
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2CareRecipient() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Who are you caring for?',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'Let\'s set up their basic profile. You can change this later.'),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
                labelText: 'Display Name *', hintText: 'e.g., Mom, Lola Maria'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _allergiesController,
            decoration:
                const InputDecoration(labelText: 'Allergies (Optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration:
                const InputDecoration(labelText: 'Important Notes (Optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createCareRecipient,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3EmergencyContact() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add an Emergency Contact',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text(
              'This contact will be easily accessible via the SOS button.'),
          const SizedBox(height: 24),
          TextField(
            controller: _contactNameController,
            decoration: const InputDecoration(
                labelText: 'Name *', hintText: 'e.g., Ana'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactPhoneController,
            decoration: const InputDecoration(labelText: 'Phone Number *'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contactRelationController,
            decoration: const InputDecoration(
                labelText: 'Relationship', hintText: 'e.g., Daughter'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addEmergencyContact,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Add Contact'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : _nextPage,
              child: const Text('Skip for now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4Medication() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('First Medication',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Let\'s add a daily medication to get started.'),
          const SizedBox(height: 24),
          TextField(
            controller: _medNameController,
            decoration: const InputDecoration(
                labelText: 'Medication Name *',
                hintText: 'e.g., Metformin 500mg'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addMedication,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Add Medication'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _isLoading ? null : _nextPage,
              child: const Text('Skip for now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep5Notifications() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_active, size: 80, color: Colors.teal),
          const SizedBox(height: 24),
          Text('Stay on Track',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Text(
            'AILaga can remind you when it\'s time for medications or upcoming appointments.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestNotificationPermission,
              child: const Text('Enable Notifications'),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _nextPage,
              child: const Text('Maybe later'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('You can enable this later in Settings',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStep6Ready() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text('You\'re All Set!',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          const Text(
            'Your care recipient profile is ready. You can now start using AILaga.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _completeOnboarding,
              child: const Text('Start Using AILaga'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 7: Optional cloud backup (Developer D)
  // "Skip" → home, "Sign Up" → /auth/register.
  // Auth is NEVER a hard gate — the app is fully usable without an account.
  // ---------------------------------------------------------------------------
  Widget _buildStep7CloudBackup() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFE6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD9D2C3)),
            ),
            child: const Icon(Icons.cloud_upload_outlined,
                size: 44, color: Color(0xFF0B6B6B)),
          ),
          const SizedBox(height: 24),
          Text(
            'Back Up Your Data',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a free account to keep a copy of your data in the cloud and '
            'access it from multiple devices.\n\nNo account needed — your data '
            'is already safe on this phone.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/auth/register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text(
                'Sign Up for Cloud Backup',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: _completeOnboarding,
              child: const Text('Skip — use offline only'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
      {required IconData icon,
      required String title,
      required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
