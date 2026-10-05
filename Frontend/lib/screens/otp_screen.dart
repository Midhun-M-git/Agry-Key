import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/localization.dart';
import 'dashboard_screen.dart';
import 'buyer_screen.dart';
import 'farmer_onboarding_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? autoFilledCode;
  const OtpScreen({super.key, this.autoFilledCode});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isVerifying = false;
  bool _isResending = false;
  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;
  String? _displayedOtpCode; // Code shown on-screen when SMS isn't available

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();

    if (widget.autoFilledCode != null && widget.autoFilledCode!.length == 6) {
      _otpController.text = widget.autoFilledCode!;
      _displayedOtpCode = widget.autoFilledCode;
    }

    // Auto-focus the OTP input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });

    _otpController.addListener(() {
      setState(() {});
      if (_otpController.text.length == 6 && !_isVerifying) {
        _verifyOtp();
      }
    });
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    setState(() {
      _cooldownSeconds = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds > 0) {
        setState(() {
          _cooldownSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _resendOtp() async {
    if (_cooldownSeconds > 0 || _isResending) return;

    final phone = ref.read(authProvider).phoneNumber.isNotEmpty
        ? ref.read(authProvider).phoneNumber
        : AppState.phoneNumber;

    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile number not found. Please log in again.")),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isResending = true;
    });

    final result = await ApiService.sendOtp(phone);

    if (!mounted) return;

    // Auto-fill and display the new OTP code (since SMS delivery via Twilio trial is unavailable)
    final newOtpCode = result["otp_code"] as String?;
    setState(() {
      _isResending = false;
      if (newOtpCode != null && newOtpCode.length == 6) {
        _otpController.text = newOtpCode;
        _displayedOtpCode = newOtpCode;
      }
    });

    if (result["success"] == true) {
      _startCooldownTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newOtpCode != null && newOtpCode.isNotEmpty
                ? "🔐 New code: $newOtpCode (auto-filled)"
                : L10n.get(
                    "New verification code sent to your phone",
                    "പുതിയ പരിശോധന കോഡ് അയച്ചു",
                    "नया सत्यापन कोड भेजा गया",
                    "புதிய சரிபார்ப்பு குறியீடு அனுப்பப்பட்டது",
                  ),
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Failed to resend OTP"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            L10n.get(
              "Please enter the complete 6-digit OTP",
              "ദയവായി 6 അക്ക OTP പൂർണ്ണമായി നൽകുക",
              "कृपया 6 अंकों का पूरा OTP दर्ज करें",
              "முழுமையான 6 இலக்க OTP-ஐ உள்ளிடவும்",
            ),
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    final phone = ref.read(authProvider).phoneNumber.isNotEmpty
        ? ref.read(authProvider).phoneNumber
        : AppState.phoneNumber;

    setState(() {
      _isVerifying = true;
    });

    final result = await ApiService.verifyOtp(
      phoneNumber: phone,
      otpCode: code,
    );

    if (!mounted) return;
    setState(() {
      _isVerifying = false;
    });

    if (result["success"] == true) {
      final isNewUser = result["is_new_user"] == true;
      final accessToken = result["access_token"] as String? ?? "";
      final refreshToken = result["refresh_token"] as String? ?? "";
      final userData = result["user"] as Map<String, dynamic>? ?? {};

      // 1. Save tokens securely for persistent login
      if (accessToken.isNotEmpty) {
        await TokenService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        ref.read(authProvider.notifier).setTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      final userName = userData["full_name"] as String? ?? "";
      final role = userData["role"] as String? ?? AppState.selectedRole;
      if (userName.isNotEmpty) {
        ref.read(userProvider.notifier).update(userName: userName);
      }
      if (role.isNotEmpty) {
        ref.read(authProvider.notifier).setRole(role);
      }

      await TokenService.saveUserDetails(
        userName: userName,
        phoneNumber: phone,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNewUser
                ? L10n.get(
                    "Welcome to Agry-Key! Account verified.",
                    "Agry-Key-ലേക്ക് സ്വാഗതം! അക്കൗണ്ട് സ്ഥിരീകരിച്ചു.",
                    "Agry-Key में आपका स्वागत है! खाता सत्यापित हुआ।",
                    "Agry-Key-க்கு வரவேற்கிறோம்! கணக்கு சரிபார்க்கப்பட்டது.",
                  )
                : L10n.get(
                    "Welcome back! Login Successful.",
                    "സ്വാഗതം! ലോഗിൻ വിജയകരം.",
                    "वापसी पर स्वागत है! लॉगिन सफल रहा।",
                    "மீண்டும் வருக! உள்நுழைவு வெற்றிகரமாக முடிந்தது.",
                  ),
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      // 2. Route seamlessly based on role and new farmer status
      if (role == "BUYER") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const BuyerScreen()),
          (route) => false,
        );
      } else if (isNewUser) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const FarmerOnboardingScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Invalid or expired verification code"),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppState.watchAll(ref);
    final phone = ref.watch(authProvider).phoneNumber.isNotEmpty
        ? ref.watch(authProvider).phoneNumber
        : AppState.phoneNumber;

    final currentCode = _otpController.text;

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text(
          L10n.get(
            "Verify your mobile number",
            "മൊബൈൽ നമ്പർ സ്ഥിരീകരിക്കുക",
            "अपना मोबाइल नंबर सत्यापित करें",
            "உங்கள் மொபைல் எண்ணை சரிபார்க்கவும்",
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Shield Icon
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 72,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                L10n.get(
                  "Verify your mobile number",
                  "പരിശോധന കോഡ് നൽകുക",
                  "सत्यापन कोड दर्ज करें",
                  "சரிபார்ப்பு குறியீட்டை உள்ளிடவும்",
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                L10n.get(
                  "We sent a 6-digit OTP to",
                  "ഞങ്ങൾ 6 അക്ക OTP അയച്ച നമ്പർ",
                  "हमने 6 अंकों का OTP भेजा है",
                  "நாங்கள் 6 இலக்க OTP அனுப்பியுள்ளோம்",
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 8),

              // Mobile number badge with edit action
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        phone.isNotEmpty ? phone : "+91 ----------",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // ── OTP Display Banner (shown when SMS is not available) ──────────
              if (_displayedOtpCode != null && _displayedOtpCode!.length == 6)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.lock_open_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Your verification code',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _displayedOtpCode!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Auto-filled below • Valid for 5 minutes',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // 6-digit PIN Box Visual Display with Android OTP Autofill
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _focusNode.requestFocus(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 6 Styled visual boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final isFilled = index < currentCode.length;
                        final isCurrent = index == currentCode.length;
                        final digit = isFilled ? currentCode[index] : "";

                        return Container(
                          width: 46,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrent
                                  ? Colors.green
                                  : (isFilled ? Colors.green.shade600 : Colors.grey.shade300),
                              width: isCurrent || isFilled ? 2 : 1.2,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            digit,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }),
                    ),

                    // Full-width touch-receptive TextField with Android SMS oneTimeCode autofill
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.0,
                        child: TextField(
                          controller: _otpController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          maxLength: 6,
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (_isVerifying || currentCode.length != 6)
                      ? null
                      : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.green.shade200,
                    disabledForegroundColor: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get(
                                "Verify & Continue",
                                "സ്ഥിരീകരിച്ച് തുടരുക",
                                "सत्यापित करें और आगे बढ़ें",
                                "சரிபார்த்து தொடரவும்",
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend OTP Section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    L10n.get(
                      "Didn't receive it? ",
                      "കോഡ് ലഭിച്ചില്ലേ? ",
                      "कोड नहीं मिला? ",
                      "குறியீடு கிடைக்கவில்லையா? ",
                    ),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: (_cooldownSeconds == 0 && !_isResending)
                        ? _resendOtp
                        : null,
                    child: _isResending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _cooldownSeconds > 0
                                ? "${L10n.get("Resend in", "വീണ്ടും അയയ്ക്കാൻ", "पुनः भेजें", "மீண்டும்")} ${_cooldownSeconds}s"
                                : L10n.get(
                                    "Resend OTP",
                                    "OTP വീണ്ടും അയയ്ക്കുക",
                                    "OTP पुनः भेजें",
                                    "OTP மீண்டும் அனுப்பு",
                                  ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _cooldownSeconds > 0
                                  ? Colors.grey
                                  : Colors.green,
                            ),
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
}