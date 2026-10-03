import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/mock_data.dart';
import '../services/mock_ai_service.dart';
import '../widgets/ai_processing_widget.dart';
import '../widgets/before_after_view.dart';

enum _EnhancementState { initial, processing, done }

class ImageEnhancementScreen extends StatefulWidget {
  const ImageEnhancementScreen({super.key});

  @override
  State<ImageEnhancementScreen> createState() => _ImageEnhancementScreenState();
}

class _ImageEnhancementScreenState extends State<ImageEnhancementScreen> {
  _EnhancementState _state = _EnhancementState.initial;
  bool _hasImage = false;
  String _currentStep = '';
  double _progress = 0;
  XFile? _selectedImage;
  Future<Uint8List>? _selectedImageBytes;
  bool _isClassifying = false;
  bool _classificationUnavailable = false;
  double? _classificationConfidence;
  String _selectedCraftKey = 'basket';
  String _selectedCraftEmoji = '🧺';
  String _selectedCraftName = 'Traditional Bamboo Basket';
  final ImagePicker _picker = ImagePicker();

  void _selectSampleCraft(Map<String, dynamic> craft) {
    setState(() {
      _selectedCraftKey = craft['key'] as String;
      _selectedCraftEmoji = craft['emoji'] as String;
      _selectedCraftName = craft['name'] as String;
      _selectedImage = null;
      _selectedImageBytes = null;
      _isClassifying = false;
      _classificationUnavailable = false;
      _classificationConfidence = null;
      _hasImage = true;
      _state = _EnhancementState.initial;
      _progress = 0;
      _currentStep = '';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = image;
      _selectedImageBytes = image.readAsBytes();
      _hasImage = true;
      _state = _EnhancementState.initial;
      _selectedCraftKey = 'default';
      _selectedCraftEmoji = '🎨';
      _selectedCraftName =
          MockData.catalogueTemplates['default']!['name'] as String;
      _isClassifying = true;
      _classificationUnavailable = false;
      _classificationConfidence = null;
      _currentStep = '';
      _progress = 0;
    });
    await _classifyImage(image);
  }

  Future<void> _classifyImage(XFile image) async {
    try {
      final result = await MockAiService.identifyProduct(image);
      if (!mounted || _selectedImage?.path != image.path) return;

      final productKey = result['product_key'] as String;
      Map<String, dynamic>? sampleCraft;
      for (final craft in MockData.sampleCrafts) {
        if (craft['key'] == productKey) {
          sampleCraft = craft;
          break;
        }
      }
      final template = MockData.catalogueTemplates[productKey] ??
          MockData.catalogueTemplates['default']!;
      const otherCraftEmojis = {'cloth': '🧵', 'default': '🎨'};

      setState(() {
        _selectedCraftKey = productKey;
        _selectedCraftName = sampleCraft?['name'] as String? ??
            template['name'] as String? ??
            result['product_name'] as String;
        _selectedCraftEmoji = sampleCraft?['emoji'] as String? ??
            otherCraftEmojis[productKey] ??
            '🎨';
        _classificationConfidence =
            (result['confidence'] as num).toDouble();
        _classificationUnavailable = false;
      });
    } catch (_) {
      if (!mounted || _selectedImage?.path != image.path) return;
      setState(() {
        _selectedCraftKey = 'default';
        _selectedCraftEmoji = '🎨';
        _selectedCraftName =
            MockData.catalogueTemplates['default']!['name'] as String;
        _classificationUnavailable = true;
      });
    } finally {
      if (mounted && _selectedImage?.path == image.path) {
        setState(() => _isClassifying = false);
      }
    }
  }
  Future<void> _enhanceImage() async {
    setState(() {
      _state = _EnhancementState.processing;
      _progress = 0;
      _currentStep = 'Detecting craft boundary...';
    });

    await MockAiService.enhanceImage(
      onProgress: (step, progress) {
        if (mounted) {
          setState(() {
            _currentStep = step;
            _progress = progress;
          });
        }
      },
      onComplete: () {
        if (mounted) {
          setState(() {
            _state = _EnhancementState.done;
          });
        }
      },
    );
  }

  void _useImage() {
    Navigator.of(context).pushNamed(
      '/voice-catalogue',
      arguments: {
        'craftKey': _selectedCraftKey,
        'craftEmoji': _selectedCraftEmoji,
        'craftName': _selectedCraftName,
      },
    );
  }

  void _retake() {
    setState(() {
      _hasImage = false;
      _selectedImage = null;
      _selectedImageBytes = null;
      _state = _EnhancementState.initial;
      _isClassifying = false;
      _classificationUnavailable = false;
      _classificationConfidence = null;
      _progress = 0;
      _currentStep = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('AI Image Enhancement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: AppTheme.chipRadius,
            ),
            child: const Row(
              children: [
                Text('✨', style: TextStyle(fontSize: 12)),
                SizedBox(width: 4),
                Text(
                  'AI Powered',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // State: No image
            if (!_hasImage) ...[
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSampleCraftSection(context),
              const SizedBox(height: 20),
              _buildPickerCards(context),
              const SizedBox(height: 20),
              _buildHowItWorks(context),
            ],

            // State: Image selected, not processed
            if (_hasImage && _state == _EnhancementState.initial) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCraftName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isClassifying
                              ? 'Analyzing your craft...'
                              : _classificationUnavailable
                                        ? 'AI classification unavailable. Using the default catalogue.'
                                  : _classificationConfidence == null
                                      ? 'Ready to enhance with AI Studio'
                                      : _selectedCraftKey == 'default'
                                          ? 'Could not confidently identify this craft. Review the product details.'
                                          : 'Craft identified (${(_classificationConfidence! * 100).round()}% confidence)',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: AppTheme.chipRadius,
                    ),
                    child: const Text(
                      'Unprocessed',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOriginalImagePreview(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isClassifying
                  ? null
                  : _enhanceImage,
                icon: const Text('✨', style: TextStyle(fontSize: 18)),
                label: const Text('Enhance Photo with AI'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _retake,
                icon: const Icon(Icons.refresh),
                label: Text(_classificationUnavailable
                  ? 'Choose Craft Manually'
                  : 'Choose Different Craft'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],

            // State: Processing
            if (_hasImage && _state == _EnhancementState.processing) ...[
              Text(
                'AI is Optimizing Your Craft Photo ✨',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Removing raw background and enhancing lighting...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              AiProcessingWidget(
                steps: MockAiService.getEnhancementSteps(),
                progress: _progress,
                currentStep: _currentStep,
              ),
            ],

            // State: Done
            if (_hasImage && _state == _EnhancementState.done) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: AppTheme.chipRadius,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 14, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text(
                          'Enhancement Complete',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _selectedCraftName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BeforeAfterView(
                beforeEmoji: _selectedCraftEmoji,
                afterEmoji: _selectedCraftEmoji,
                beforeBg: const Color(0xFFEEEEEE),
                afterBg: const Color(0xFFFFF8E1),
              ),
              const SizedBox(height: 20),
              // Enhancement details
              _buildEnhancementDetails(context),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _useImage,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Use This Image → Voice Catalogue'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _retake,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake / Choose Another'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB85C38), Color(0xFFC97040)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppTheme.cardRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📸 AI Image Enhancement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Make your product photo marketplace-ready in seconds.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text('🪄', style: TextStyle(fontSize: 40)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSampleCraftSection(BuildContext context) {
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: AppTheme.chipRadius,
                ),
                child: const Text(
                  'SIH DEMO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Select Sample Indian Craft',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Instant 1-tap demo with real Indian artisan craft context:',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: MockData.sampleCrafts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (context, index) {
              final craft = MockData.sampleCrafts[index];
              return InkWell(
                onTap: () => _selectSampleCraft(craft),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      Text(craft['emoji'] as String, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              craft['name'] as String,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              craft['region'] as String,
                              style: const TextStyle(
                                fontSize: 9,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPickerCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickerOption(
            emoji: '📷',
            label: 'Take Photo',
            sublabel: 'Camera',
            color: AppTheme.primary,
            onTap: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PickerOption(
            emoji: '🖼️',
            label: 'Choose from Gallery',
            sublabel: 'Gallery',
            color: AppTheme.secondary,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginalImagePreview() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.divider),
      ),
      child: _selectedImage != null
          ? ClipRRect(
              borderRadius: AppTheme.cardRadius,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder<Uint8List>(
                    future: _selectedImageBytes,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Icon(Icons.broken_image_outlined),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: AppTheme.chipRadius,
                        ),
                        child: Text(
                          'Original Photo: $_selectedCraftName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_selectedCraftEmoji,
                    style: const TextStyle(fontSize: 80)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    borderRadius: AppTheme.chipRadius,
                  ),
                  child: Text(
                    'Original Photo: $_selectedCraftName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEnhancementDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.05),
        borderRadius: AppTheme.cardRadius,
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Enhancements Applied',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...['✅ Background Removed', '✅ Lighting Improved',
              '✅ Sharpness Enhanced', '✅ Colour Corrected',
              '✅ Marketplace Optimised'].map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(e,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  )),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Text('🛡️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Artisan Protection: Original photo remains preserved. AI assists for buyer clarity while keeping genuine handcrafted texture.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: AppTheme.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🤖 How AI Enhancement Works',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...['1. Take or upload a product photo',
              '2. AI detects and isolates your product',
              '3. Background is automatically removed',
              '4. Lighting and colour are optimised',
              '5. Image is made marketplace-ready'].map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(e, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final String emoji;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _PickerOption({
    required this.emoji,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: AppTheme.cardRadius,
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              sublabel,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
