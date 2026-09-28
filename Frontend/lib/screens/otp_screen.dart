import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_state.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/localization.dart';
import 'dashboard_screen.dart';
import 'buyer_screen.dart';
import 'register_screen.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String? demoOtp;
  const OtpScreen({super.key, this.demoOtp});

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
  String? _activeDemoOtp;

  @override
  void initState() {
    super.initState();
    _activeDemoOtp = widget.demoOtp;
    _startCooldownTimer();

    // Auto-focus the OTP input after build
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
    setState(() {
      _isResending = false;
    });

    if (result["success"] == true) {
      _startCooldownTimer();
      final newDemoOtp = result["otp"] as String?;
      if (newDemoOtp != null) {
        setState(() {
          _activeDemoOtp = newDemoOtp;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result["sms_delivered"] == true
                ? L10n.get(
                    "New OTP sent to your phone",
                    "പുതിയ OTP നിങ്ങളുടെ ഫോണിലേക്ക് അയച്ചു",
                    "नया OTP आपके फोन पर भेजा गया",
                    "புதிய OTP உங்கள் தொலைபேசிக்கு அனுப்பப்பட்டது",
                  )
                : "New OTP generated (Logged to console: ${newDemoOtp ?? ''})",
          ),
          backgroundColor: Colors.green.shade700,
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
      final userExists = result["user_exists"] == true;

      if (userExists) {
        // Existing user: Save session and proceed to Dashboard / BuyerScreen
        final accessToken = result["access_token"] as String? ?? "";
        final refreshToken = result["refresh_token"] as String? ?? "";
        final userData = result["user"] as Map<String, dynamic>? ?? {};

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
              L10n.get(
                "Welcome back! Login Successful.",
                "സ്വാഗതം! ലോഗിൻ വിജയകരം.",
                "वापसी पर स्वागत है! लॉगिन सफल रहा।",
                "மீண்டும் வருக! உள்நுழைவு வெற்றிகரமாக முடிந்தது.",
              ),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );

        if (role == "BUYER") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BuyerScreen()),
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
        // New user: phone verified, route to registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              L10n.get(
                "Phone verified! Please complete registration.",
                "ഫോൺ നമ്പർ സ്ഥിരീകരിച്ചു! ദയവായി രജിസ്ട്രേഷൻ പൂർത്തിയാക്കുക.",
                "फोन सत्यापित हुआ! कृपया पंजीकरण पूरा करें।",
                "தொலைபேசி சரிபார்க்கப்பட்டது! பதிவை முடிக்கவும்.",
              ),
            ),
            backgroundColor: Colors.green.shade700,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Invalid or expired OTP"),
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
            "OTP Verification",
            "OTP സ്ഥിരീകരണം",
            "OTP सत्यापन",
            "OTP சரிபார்ப்பு",
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Top Shield Icon
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
                "Enter Verification Code",
                "പരിശോധന കോഡ് നൽകുക",
                "सत्यापन कोड दर्ज करें",
                "சரிபார்ப்பு குறியீட்டை உள்ளிடவும்",
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              L10n.get(
                "We sent a 6-digit verification code to",
                "ഞങ്ങൾ 6 അക്ക കോഡ് അയച്ച നമ്പർ",
                "हमने 6 अंकों का सत्यापन कोड भेजा है",
                "நாங்கள் 6 இலக்க சரிபார்ப்பு குறியீட்டை அனுப்பியுள்ளோம்",
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

            // Demo OTP auto-fill helper (if present in mock mode)
            if (_activeDemoOtp != null && _activeDemoOtp!.isNotEmpty) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _otpController.text = _activeDemoOtp!;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    border: Border.all(color: Colors.amber.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.key, size: 18, color: Colors.amber.shade900),
                      const SizedBox(width: 8),
                      Text(
                        "Demo Code: $_activeDemoOtp (Tap to auto-fill)",
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 35),

            // 6-digit PIN Box Visual Display with Hidden Input
            Stack(
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

                // Transparent underlying TextField covering the boxes
                Opacity(
                  opacity: 0.0,
                  child: TextField(
                    controller: _otpController,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
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
                    "Didn't receive the code? ",
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
    );
  }
}