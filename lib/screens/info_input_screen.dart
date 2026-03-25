import 'package:flutter/material.dart';
import '../core/app_assets.dart';
import '../core/theme.dart';
import '../core/soul_card.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'soul_card_screen.dart';

class InfoInputScreen extends StatefulWidget {
  const InfoInputScreen({super.key});

  @override
  State<InfoInputScreen> createState() => _InfoInputScreenState();
}

class _InfoInputScreenState extends State<InfoInputScreen> {
  final _nicknameController = TextEditingController();
  final _mbtiController = TextEditingController();

  String _birthdate = ''; // YYYYMMDD
  String _gender = ''; // 'female' | 'male'
  int? _soulCardNumber;

  bool get _isValid =>
      _birthdate.isNotEmpty &&
      _gender.isNotEmpty &&
      _mbtiController.text.length == 4 &&
      _nicknameController.text.isNotEmpty;

  @override
  void dispose() {
    _nicknameController.dispose();
    _mbtiController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.gold,
                onPrimary: AppTheme.backgroundDark,
                surface: AppTheme.backgroundCard,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.year}${picked.month.toString().padLeft(2, '0')}${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _birthdate = formatted;
        _soulCardNumber = calcSoulCard(formatted);
      });
    }
  }

  Future<void> _submit() async {
    if (!_isValid) return;
    final user = UserModel.fromBirthdate(
      nickname: _nicknameController.text.trim(),
      gender: _gender,
      mbti: _mbtiController.text.toUpperCase().trim(),
      birthdate: _birthdate,
    );
    await StorageService.instance.saveUser(user);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SoulCardScreen(user: user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.bgInfoInput,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2D1B4E), Color(0xFF1A1028)],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.backgroundDark.withValues(alpha: 0.25),
                  AppTheme.backgroundDark.withValues(alpha: 0.72),
                  AppTheme.backgroundDark.withValues(alpha: 0.92),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    '당신을 알려주세요',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '소울카드를 찾아드릴게요',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),

                  // ── 생년월일 ───────────────────────────────────
                  _SectionLabel('생년월일'),
                  const SizedBox(height: 8),
                  _BirthdatePicker(
                    birthdate: _birthdate,
                    soulCardNumber: _soulCardNumber,
                    onTap: _pickBirthdate,
                  ),
                  const SizedBox(height: 20),

                  // ── 성별 ───────────────────────────────────────
                  _SectionLabel('성별'),
                  const SizedBox(height: 8),
                  _GenderToggle(
                    selected: _gender,
                    onChanged: (v) => setState(() => _gender = v),
                  ),
                  const SizedBox(height: 20),

                  // ── MBTI ───────────────────────────────────────
                  _SectionLabel('MBTI'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _mbtiController,
                    hint: 'INFP, ESTJ...',
                    maxLength: 4,
                    onChanged: (_) => setState(() {}),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 20),

                  // ── 닉네임 ─────────────────────────────────────
                  _SectionLabel('닉네임'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _nicknameController,
                    hint: '앱에서 사용할 이름',
                    maxLength: 12,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 36),

                  // ── 시작 버튼 ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isValid ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isValid ? AppTheme.gold : AppTheme.divider,
                        foregroundColor: _isValid
                            ? AppTheme.backgroundDark
                            : AppTheme.textMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '시작하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _isValid
                              ? AppTheme.backgroundDark
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 서브 위젯들 ────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _BirthdatePicker extends StatelessWidget {
  final String birthdate;
  final int? soulCardNumber;
  final VoidCallback onTap;

  const _BirthdatePicker({
    required this.birthdate,
    required this.soulCardNumber,
    required this.onTap,
  });

  String get _displayText {
    if (birthdate.isEmpty) return '날짜를 선택하세요';
    return '${birthdate.substring(0, 4)}.${birthdate.substring(4, 6)}.${birthdate.substring(6, 8)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: birthdate.isNotEmpty ? AppTheme.gold : AppTheme.divider,
            width: birthdate.isNotEmpty ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: birthdate.isNotEmpty
                  ? AppTheme.gold
                  : AppTheme.textMuted,
            ),
            const SizedBox(width: 10),
            Text(
              _displayText,
              style: TextStyle(
                color: birthdate.isNotEmpty
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (soulCardNumber != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${soulCardNames[soulCardNumber]}',
                  style: const TextStyle(
                    color: AppTheme.gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GenderToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _GenderChip(
          label: '여',
          value: 'female',
          selected: selected == 'female',
          onTap: () => onChanged('female'),
        ),
        const SizedBox(width: 12),
        _GenderChip(
          label: '남',
          value: 'male',
          selected: selected == 'male',
          onTap: () => onChanged('male'),
        ),
      ],
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 80,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.gold.withValues(alpha: 0.15)
              : AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.gold : AppTheme.divider,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppTheme.gold : AppTheme.textSecondary,
              fontSize: 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final TextCapitalization textCapitalization;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    required this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = controller.text.isNotEmpty;
    return TextField(
      controller: controller,
      maxLength: maxLength,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
        counterText: '',
        filled: true,
        fillColor: AppTheme.backgroundCard,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasValue ? AppTheme.gold : AppTheme.divider,
            width: hasValue ? 1.5 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.gold, width: 1.5),
        ),
      ),
    );
  }
}
