import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utilities/uuid_generator.dart';
import '../../../services/demo/demo_data_service.dart';
import '../../care_recipient/data/care_recipient_providers.dart';
import '../../care_recipient/domain/care_recipient_entity.dart';
import '../../family_contacts/data/family_contact_providers.dart';
import '../../family_contacts/domain/family_contact_entity.dart';
import '../../medications/data/medication_providers.dart';
import '../../medications/domain/medication_entity.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
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
        allergies: _allergiesController.text.trim().isEmpty ? null : _allergiesController.text.trim(),
        importantNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await repo.create(entity);
      _careRecipientId = id;
      
      // Refresh provider
      ref.invalidate(primaryCareRecipientProvider);
      
      _nextPage();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Try again.')),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Try again.')),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong. Try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// One-tap demo: seeds the B22 dataset and lands on the initialization
  /// screen so the Phone helper setup check runs even for demo users.
  Future<void> _loadDemoData() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(demoDataServiceProvider).seedIfEmpty();
      if (mounted) context.go('/initialization');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load demo data.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted || status.isDenied || status.isPermanentlyDenied) {
      _nextPage();
    }
  }

  void _completeOnboarding() {
    // Go to the initialization screen so the user is prompted to download
    // the Phone helper right after setting up their profile. The
    // InitializationScreen handles unsupported devices gracefully and
    // provides "Try later" if they want to skip for now.
    context.go('/initialization');
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF0B6B6B);
    // Slide 0 (brand welcome) and 5 (ready) have their own CTA buttons;
    // slides 1–4 are forms / permission with inline actions.
    final showSlideChrome = _currentPage == 0 || _currentPage == 5;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentPage + 1) / 6,
              backgroundColor: const Color(0xFFF3EFE6),
              color: teal,
              minHeight: 8,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                // Swipeable slides; form input survives swipes (controllers kept).
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildStep1Welcome(),
                  _buildStep2CareRecipient(),
                  _buildStep3EmergencyContact(),
                  _buildStep4Medication(),
                  _buildStep5Notifications(),
                  _buildStep6Ready(),
                ],
              ),
            ),
            if (showSlideChrome) _buildSlideFooter(teal),
          ],
        ),
      ),
    );
  }

  /// Dots + Skip/Next chrome for the brand slides (0 and 5).
  /// Form slides keep their own Continue/Skip buttons.
  Widget _buildSlideFooter(Color teal) {
    final isLast = _currentPage == 5;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Row(
        children: [
          // Dots — shrink-wrapped so buttons always fit on narrow screens.
          Semantics(
            label: 'Step ${_currentPage + 1} of 6',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(6, (i) {
                final active = i == _currentPage;
                return GestureDetector(
                  onTap: () {
                    // Only allow free dot-jumping on the brand slides;
                    // the profile form (slide 1) must be completed in order.
                    if (_currentPage == 0 || _currentPage == 5) {
                      _goToPage(i);
                    }
                  },
                  child: Container(
                    width: active ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: active ? teal : const Color(0xFFD9D2C3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Flexible spacer — pushes buttons to the right but can compress
          // to zero on very narrow screens so buttons never overflow.
          const Spacer(),
          TextButton(
            // Slide 0 has no profile yet — Skip advances to the form.
            // (Finishing here would just bounce back via the router guard.)
            onPressed: isLast ? _completeOnboarding : () => _goToPage(1),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: const Text('Skip'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () => _goToPage(isLast ? 5 : 1),
            style: FilledButton.styleFrom(
              backgroundColor: teal,
              minimumSize: const Size(0, 56),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: Text(isLast ? 'Done' : 'Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Welcome() {
    const teal = Color(0xFF0B6B6B);
    const indigo = Color(0xFF2F4B8A);
    return _scrollableCenter(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Brand hero — app mark in a warm card with teal ring.
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFE6),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: const Color(0xFFD9D2C3), width: 2),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: teal, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/branding/app_mark.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Symbols.health_and_safety_rounded,
                        size: 80,
                        color: teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Care for Lola',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: const Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                const Text(
                  'Talk. We write it down.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Symbols.flight_rounded, size: 20, color: teal),
                    SizedBox(width: 6),
                    Text('Works with no internet.',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoBox(
            icon: Symbols.shield_rounded,
            iconColor: teal,
            title: 'Stays on this phone',
            description:
                'No account needed. Your family data never leaves this device.',
          ),
          const SizedBox(height: 12),
          _buildInfoBox(
            icon: Symbols.favorite_rounded,
            iconColor: indigo,
            title: 'You confirm every record',
            description:
                'Nothing is saved until a person taps Confirm.',
          ),
          const SizedBox(height: 8),
          const Text(
            'AILaga is not a medical device.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextPage,
              icon: const Icon(Symbols.check_rounded),
              label: const Text('Get Started'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
                textStyle: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Instant demo — seeds sample data and skips the wizard.
          TextButton.icon(
            onPressed: _isLoading ? null : _loadDemoData,
            icon: const Icon(Symbols.play_circle_rounded),
            label: const Text('Try a demo'),
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
          Text('Who are you caring for?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Let\'s set up their basic profile. You can change this later.'),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Display Name *', hintText: 'e.g., Mom, Lola Maria'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _allergiesController,
            decoration: const InputDecoration(labelText: 'Allergies (Optional)'),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Important Notes (Optional)'),
            maxLines: 3,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createCareRecipient,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Continue'),
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
          Text('Add an Emergency Contact', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('This contact will be easily accessible via the SOS button.'),
          const SizedBox(height: 24),
          TextField(
            controller: _contactNameController,
            decoration: const InputDecoration(labelText: 'Name *', hintText: 'e.g., Ana'),
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
            decoration: const InputDecoration(labelText: 'Relationship', hintText: 'e.g., Daughter'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addEmergencyContact,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Add Contact'),
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
          Text('First Medication', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Let\'s add a daily medication to get started.'),
          const SizedBox(height: 24),
          TextField(
            controller: _medNameController,
            decoration: const InputDecoration(labelText: 'Medication Name *', hintText: 'e.g., Metformin 500mg'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addMedication,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Add Medication'),
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
    return _scrollableCenter(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.notifications_active_rounded, size: 80, color: Colors.teal),
          const SizedBox(height: 24),
          Text('Stay on Track', style: Theme.of(context).textTheme.headlineSmall),
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
          const Text('You can enable this later in Settings', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStep6Ready() {
    return _scrollableCenter(
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.check_circle_rounded, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          Text('You\'re All Set!', style: Theme.of(context).textTheme.headlineMedium),
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

  /// Centers [child] when it fits; scrolls instead of overflowing when
  /// large text or a short screen squeezes the available height.
  Widget _scrollableCenter(Widget child) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(
      {required IconData icon,
      required String title,
      required String description,
      Color iconColor = const Color(0xFF0B6B6B)}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EFE6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD9D2C3), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
