import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/crafts.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/buttons/primary_bilingual_button.dart';
import '../../../data/models/artisan_model.dart';
import '../controllers/auth_controller.dart';

/// 3-Step Artisan Registration & Provenance Verification Wizard.
class ArtisanRegistrationScreen extends StatefulWidget {
  const ArtisanRegistrationScreen({super.key});

  @override
  State<ArtisanRegistrationScreen> createState() => _ArtisanRegistrationScreenState();
}

class _ArtisanRegistrationScreenState extends State<ArtisanRegistrationScreen> {
  int _currentStep = 0;

  // Step 1: Location & Cluster
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nameHiController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  String _selectedState = CraftConstants.indianStates.first;
  final TextEditingController _clusterController = TextEditingController();

  // Step 2: Craft, Identity & Tax Verification
  String _selectedCraft = CraftConstants.craftTypes.first;
  final TextEditingController _yearsController = TextEditingController(text: '10');
  final TextEditingController _giTagController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();

  // Step 3: Heritage Story
  final TextEditingController _storyController = TextEditingController();

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final _formKeyStep3 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    final phone = auth.phone ?? auth.currentUser?.phoneNumber ?? '';
    final suffix = phone.length >= 4 ? phone.substring(phone.length - 4) : '';
    _nameController.text = auth.currentUser?.displayName ?? 'Artisan $suffix';
    _nameHiController.text = 'कारीगर';
    _villageController.text = 'Chanderi';
    _districtController.text = 'Ashoknagar';
    _clusterController.text = 'Chanderi Handloom Cluster';
    _storyController.text =
        'I have practiced handloom weaving since childhood, preserving our family craft heritage.';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameHiController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _clusterController.dispose();
    _yearsController.dispose();
    _giTagController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();
    _gstinController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Artisan Registration',
          style: TextStyle(fontFamily: 'Lora', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.canvas,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'STEP ${_currentStep + 1} OF 3',
                        style: const TextStyle(
                          fontFamily: 'Pally',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppColors.action,
                        ),
                      ),
                      Text(
                        _stepTitle(_currentStep),
                        style: const TextStyle(
                          fontFamily: 'Lora',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentStep + 1) / 3.0,
                      backgroundColor: AppColors.border.withValues(alpha: 0.4),
                      color: AppColors.action,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: _buildStepContent(),
              ),
            ),

            // Bottom Navigation Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border, width: AppShape.hairline)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: auth.busy ? null : () => setState(() => _currentStep--),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: PrimaryBilingualButton(
                      label: _currentStep == 2 ? 'Submit Registration' : 'Continue',
                      onPressed: auth.busy ? null : _onContinue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    return switch (step) {
      0 => 'Location & Cluster',
      1 => 'Craft Specialization',
      2 => 'Heritage Story',
      _ => '',
    };
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Form(
          key: _formKeyStep1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Artisan Identity & Provenance', 'Your name and village will be listed on your craft provenance badges.'),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Full Name (English)', 'e.g. Kamala Devi'),
              const SizedBox(height: 14),
              _buildTextField(_nameHiController, 'Full Name (Hindi / Local)', 'e.g. कमला देवी'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildTextField(_villageController, 'Village / Town', 'e.g. Chanderi')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_districtController, 'District', 'e.g. Ashoknagar')),
                ],
              ),
              const SizedBox(height: 14),
              _buildDropdownField('State', CraftConstants.indianStates, _selectedState, (val) {
                if (val != null) setState(() => _selectedState = val);
              }),
              const SizedBox(height: 14),
              _buildTextField(_clusterController, 'Artisan Craft Cluster', 'e.g. Chanderi Handloom Cluster'),
            ],
          ),
        );

      case 1:
        final bool hasGstin = _gstinController.text.trim().isNotEmpty;
        final bool hasPan = _panController.text.trim().isNotEmpty;
        final bool hasAadhaar = _aadhaarController.text.trim().isNotEmpty;
        final bool hasAnyId = hasGstin || hasPan || hasAadhaar;

        return Form(
          key: _formKeyStep2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                'Craft & Tax Identity Verification',
                'Provide your craft details and at least one tax/identity document (GSTIN -> PAN -> Aadhaar).',
              ),
              const SizedBox(height: 20),
              _buildDropdownField('Craft Category', CraftConstants.craftTypes, _selectedCraft, (val) {
                if (val != null) setState(() => _selectedCraft = val);
              }),
              const SizedBox(height: 14),
              _buildTextField(_yearsController, 'Years of Practice', 'e.g. 15', keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _buildTextField(_giTagController, 'GI Tag / Artisan Card ID (Optional)', 'e.g. GI-CHANDERI-2010', required: false),

              const SizedBox(height: 20),
              const Divider(color: AppColors.border),
              const SizedBox(height: 10),
              Text(
                'TAX & IDENTITY PROOF HIERARCHY',
                style: TextStyle(
                  fontFamily: 'Pally',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.action,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1. GSTIN (Primary) → 2. PAN Number (If no GSTIN) → 3. Aadhaar / Pehchan Card (If no PAN)',
                style: TextStyle(fontFamily: 'Lora', fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 14),

              // 1st Priority: GSTIN
              _buildTextField(
                _gstinController,
                '1. GSTIN Number (Primary Tax ID)',
                'e.g. 22AAAAA0000A1Z5',
                required: false,
              ),
              const SizedBox(height: 14),

              // 2nd Priority: PAN Number
              _buildTextField(
                _panController,
                '2. PAN Card Number (Required if no GSTIN)',
                'e.g. ABCDE1234F',
                required: false,
              ),
              const SizedBox(height: 14),

              // 3rd Priority: Aadhaar / Pehchan Card
              _buildTextField(
                _aadhaarController,
                '3. Aadhaar / Artisan Pehchan Card (Required if no PAN)',
                'e.g. 1234 5678 9012',
                keyboardType: TextInputType.number,
                required: false,
              ),

              if (!hasAnyId) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'At least one identity document (GSTIN, PAN, or Aadhaar) is required to proceed.',
                          style: TextStyle(
                            fontFamily: AppTheme.bodyFont,
                            fontSize: 12.5,
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );

      case 2:
      default:
        return Form(
          key: _formKeyStep3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Craft Heritage Story', 'Sharing your genuine craft story helps buyers appreciate handmade art over factory goods.'),
              const SizedBox(height: 20),
              TextFormField(
                controller: _storyController,
                maxLines: 5,
                style: const TextStyle(fontFamily: 'Lora', fontSize: 15, color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Describe how you learned your craft, traditional tools used, or family heritage...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Please share a brief story' : null,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.heritage.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.heritage),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_user_outlined, color: AppColors.ink, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your profile will undergo cluster provenance verification. Once verified, a official GI / Verified Artisan badge will appear on your crafts.',
                        style: TextStyle(fontFamily: 'Lora', fontSize: 12.5, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {TextInputType keyboardType = TextInputType.text, bool required = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontFamily: AppTheme.bodyFont, fontSize: 15, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surface,
          ),
          validator: required ? (val) => (val == null || val.trim().isEmpty) ? 'Field required' : null : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String selectedValue, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Pally', fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.ink)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: selectedValue,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontFamily: AppTheme.bodyFont, fontSize: 14, color: AppColors.ink),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          ),
        ),
      ],
    );
  }

  Future<void> _onContinue() async {
    if (_currentStep == 0) {
      if (!(_formKeyStep1.currentState?.validate() ?? false)) return;
      setState(() => _currentStep = 1);
    } else if (_currentStep == 1) {
      if (!(_formKeyStep2.currentState?.validate() ?? false)) return;

      final bool hasGstin = _gstinController.text.trim().isNotEmpty;
      final bool hasPan = _panController.text.trim().isNotEmpty;
      final bool hasAadhaar = _aadhaarController.text.trim().isNotEmpty;

      if (!hasGstin && !hasPan && !hasAadhaar) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide at least one document according to hierarchy: GSTIN, PAN Number, or Aadhaar/Pehchan Card.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(() => _currentStep = 2);
    } else {
      if (!(_formKeyStep3.currentState?.validate() ?? false)) return;
      await _submitRegistration();
    }
  }

  Future<void> _submitRegistration() async {
    final auth = context.read<AuthController>();
    final navigator = Navigator.of(context);
    final user = auth.currentUser;

    if (user == null) return;

    final artisan = ArtisanModel(
      uid: user.uid,
      name: _nameController.text.trim(),
      nameHi: _nameHiController.text.trim(),
      village: _villageController.text.trim(),
      district: _districtController.text.trim(),
      state: _selectedState,
      craft: _selectedCraft,
      cluster: _clusterController.text.trim(),
      giTag: _giTagController.text.trim().isNotEmpty ? _giTagController.text.trim() : null,
      aadhaarNumber: _aadhaarController.text.trim().isNotEmpty ? _aadhaarController.text.trim() : null,
      panNumber: _panController.text.trim().isNotEmpty ? _panController.text.trim() : null,
      gstin: _gstinController.text.trim().isNotEmpty ? _gstinController.text.trim() : null,
      story: _storyController.text.trim(),
      storyHi: _storyController.text.trim(),
      yearsOfPractice: int.tryParse(_yearsController.text.trim()) ?? 5,
      verified: false, // Cluster verification pending by default
      createdAt: DateTime.now(),
    );

    await auth.registerArtisanProfile(artisan);
    if (!mounted) return;

    navigator.pushNamedAndRemoveUntil(Routes.artisanHome, (_) => false);
  }
}
