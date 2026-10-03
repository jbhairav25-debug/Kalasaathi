import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../services/mock_translation_service.dart';
import '../services/mock_ai_service.dart';
import '../models/product.dart';

enum _VoiceState { idle, listening, processing, done }

class VoiceCatalogueScreen extends StatefulWidget {
  const VoiceCatalogueScreen({super.key});

  @override
  State<VoiceCatalogueScreen> createState() => _VoiceCatalogueScreenState();
}

class _VoiceCatalogueScreenState extends State<VoiceCatalogueScreen>
    with TickerProviderStateMixin {
  _VoiceState _voiceState = _VoiceState.idle;
  String _selectedLanguage = 'te';
  String _originalText = '';
  String _translatedText = '';
  Map<String, dynamic>? _catalogue;

  String _craftKey = 'basket';
  String _craftEmoji = '🧺';
  String _craftName = 'Traditional Bamboo Basket';
  bool _initializedArgs = false;

  late AnimationController _pulseController;
  late Animation<double> _pulse;
  late AnimationController _waveController;

  // Editable catalogue fields
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _nameController = TextEditingController();
    _descController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      _initializedArgs = true;
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _craftKey = (args['craftKey'] as String?) ?? 'basket';
        _craftEmoji = (args['craftEmoji'] as String?) ?? '🧺';
        _craftName = (args['craftName'] as String?) ?? 'Traditional Bamboo Basket';
        if (_craftKey == 'pot') {
          _selectedLanguage = 'hi';
        } else if (_craftKey == 'toy') {
          _selectedLanguage = 'kn';
        } else {
          _selectedLanguage = 'te';
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() => _voiceState = _VoiceState.listening);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _voiceState = _VoiceState.processing);

    // Simulate recognition
    final result = await MockTranslationService.recognizeVoice(
      languageCode: _selectedLanguage,
      craftKey: _craftKey,
    );
    final translation = await MockTranslationService.translateToEnglish(
      text: result['original']!,
      fromLanguageCode: _selectedLanguage,
      craftKey: _craftKey,
    );

    // Generate catalogue
    final catalogue = await MockAiService.generateCatalogue(
      productKey: _craftKey,
      imageContext: _craftName,
      voiceContext: '$translation $_craftKey',
    );

    setState(() {
      _originalText = result['original']!;
      _translatedText = translation;
      _catalogue = catalogue;
      _voiceState = _VoiceState.done;
      _nameController.text =
          (catalogue['name'] as String?) ?? _craftName;
      _descController.text =
          (catalogue['description'] as String?) ?? '';
    });
  }

  Future<void> _regenerate() async {
    setState(() {
      _voiceState = _VoiceState.processing;
      _catalogue = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    final catalogue = await MockAiService.generateCatalogue(
      productKey: _craftKey,
      imageContext: _craftName,
      voiceContext: '$_translatedText $_craftKey',
    );
    setState(() {
      _catalogue = catalogue;
      _voiceState = _VoiceState.done;
      _nameController.text = (catalogue['name'] as String?) ?? _craftName;
      _descController.text = (catalogue['description'] as String?) ?? '';
    });
  }

  void _continueToPricing() {
    Navigator.of(context).pushNamed(
      '/pricing',
      arguments: {
        'catalogue': _catalogue,
        'productName': _nameController.text.isNotEmpty ? _nameController.text : _craftName,
        'description': _descController.text,
        'craftKey': _craftKey,
        'craftEmoji': _craftEmoji,
      },
    );
  }

  String get _languageName =>
      MockTranslationService.getLanguageName(_selectedLanguage);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Create Your Catalogue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected craft tag
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: AppTheme.chipRadius,
                border: Border.all(color: AppTheme.border),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_craftEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    'Craft: $_craftName',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondary.withOpacity(0.08),
                borderRadius: AppTheme.cardRadius,
                border: Border.all(
                    color: AppTheme.secondary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('🎤', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Multilingual Auto-Cataloguer',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Describe your craft in your own language.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Language selector
            Text(
              'Select Your Language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MockData.supportedLanguages.map((lang) {
                  final isSelected = lang['code'] == _selectedLanguage;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedLanguage = lang['code']!;
                      _voiceState = _VoiceState.idle;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.secondary
                            : AppTheme.surfaceVariant,
                        borderRadius: AppTheme.chipRadius,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.secondary
                              : AppTheme.border,
                        ),
                      ),
                      child: Text(
                        '${lang['flag']} ${lang['name']}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // Mic button
            Center(
              child: Column(
                children: [
                  if (_voiceState == _VoiceState.idle ||
                      _voiceState == _VoiceState.listening) ...[
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _voiceState == _VoiceState.listening
                              ? _pulse.value
                              : 1.0,
                          child: child,
                        );
                      },
                      child: GestureDetector(
                        onTap: _voiceState == _VoiceState.idle
                            ? _startListening
                            : null,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: _voiceState == _VoiceState.listening
                                ? AppTheme.greenGradient
                                : AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_voiceState == _VoiceState.listening
                                        ? AppTheme.secondary
                                        : AppTheme.primary)
                                    .withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _voiceState == _VoiceState.listening
                                  ? Icons.mic
                                  : Icons.mic_none,
                              color: Colors.white,
                              size: 52,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _voiceState == _VoiceState.listening
                          ? '🔴 Listening in $_languageName...'
                          : '🎤  Tap & Speak',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _voiceState == _VoiceState.listening
                            ? AppTheme.secondary
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_voiceState == _VoiceState.idle)
                      Text(
                        'Speak in $_languageName',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    if (_voiceState == _VoiceState.listening)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: _buildWaveform(),
                      ),
                  ],

                  if (_voiceState == _VoiceState.processing) ...[
                    const SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🤖 AI is generating catalogue...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.secondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Results
            if (_voiceState == _VoiceState.done && _catalogue != null) ...[
              const SizedBox(height: 28),
              _buildTranscriptionCard(context),
              const SizedBox(height: 16),
              _buildCatalogueCard(context),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _continueToPricing,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continue to Pricing →'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _regenerate,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Regenerate'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _voiceState = _VoiceState.idle;
                        _catalogue = null;
                      }),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Re-record'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildWaveform() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            9,
            (i) {
              final phase = (_waveController.value + i * 0.11) % 1.0;
              final height = 8.0 + (24.0 * (0.5 + 0.5 * _sineWave(phase)));
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: height,
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: AppTheme.chipRadius,
                ),
              );
            },
          ),
        );
      },
    );
  }

  double _sineWave(double t) =>
      0.5 + 0.5 * (t < 0.5 ? 4 * t * t * t : 1 - 4 * (1 - t) * (1 - t) * (1 - t));

  Widget _buildTranscriptionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.1),
                  borderRadius: AppTheme.chipRadius,
                ),
                child: Text(
                  '🌐 $_languageName Detected',
                  style: TextStyle(
                    color: AppTheme.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Original Voice / Transcription',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Text(
              _originalText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('English Translation',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.05),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              border: Border.all(
                  color: AppTheme.secondary.withOpacity(0.2)),
            ),
            child: Text(
              _translatedText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalogueCard(BuildContext context) {
    if (_catalogue == null) return const SizedBox.shrink();

    final tags = (_catalogue!['tags'] as List?)?.cast<String>() ?? [];
    final category = _catalogue!['category'] as ProductCategory?;
    final material = _catalogue!['material'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.primary.withOpacity(0.3), width: 2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.chipRadius,
                ),
                child: const Text(
                  '🤖 AI Generated Catalogue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _catalogueField(context, 'Product Name', _nameController),
          const SizedBox(height: 12),

          _catalogueInfoRow(context, 'Category', category?.displayName ?? ''),
          const SizedBox(height: 8),
          _catalogueInfoRow(context, 'Material', material),
          const SizedBox(height: 12),

          _catalogueField(context, 'Description', _descController,
              maxLines: 4),
          const SizedBox(height: 12),

          Text('Tags', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: AppTheme.chipRadius,
                  border: Border.all(
                      color: AppTheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  '# $tag',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _catalogueField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppTheme.primary, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _catalogueInfoRow(
      BuildContext context, String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label,
              style: Theme.of(context).textTheme.labelMedium),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
