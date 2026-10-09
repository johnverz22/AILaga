import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../services/auth/auth_providers.dart';

// ---------------------------------------------------------------------------
// Brand palette tokens (mirrors UI_PROMPT.md / theme.dart)
// ---------------------------------------------------------------------------
const _kTeal = Color(0xFF0B6B6B);
const _kBg = Color(0xFFFFFDF8);
const _kCard = Color(0xFFF3EFE6);
const _kBorder = Color(0xFFD9D2C3);
const _kText = Color(0xFF1A1A1A);
const _kError = Color(0xFFB3261E);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _setError(String? message) {
    if (mounted) setState(() => _errorMessage = message);
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => _isLoading = value);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _signInWithEmail() async {
    _setError(null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    try {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Sign in failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signInWithGoogle() async {
    _setError(null);
    _setLoading(true);
    try {
      final credential = await ref.read(authServiceProvider).signInWithGoogle();
      // null means user cancelled the account picker — stay on screen
      if (credential != null && mounted) context.go('/');
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Google sign in failed. Please try again.');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _setError('Enter your email first, then tap Forgot Password.');
      return;
    }
    if (_validateEmail(email) != null) {
      _setError('Enter a valid email address first.');
      return;
    }
    _setError(null);
    _setLoading(true);
    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset email sent. Check your inbox.'),
            backgroundColor: Color(0xFF1B7F3B),
          ),
        );
      }
    } on AuthException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('Could not send reset email. Check your connection.');
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 16),
              if (_errorMessage != null) _buildErrorBanner(),
              const SizedBox(height: 8),
              _buildForgotPassword(),
              const SizedBox(height: 24),
              _buildSignInButton(),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildGoogleButton(),
              const SizedBox(height: 24),
              _buildCreateAccountRow(),
              const SizedBox(height: 32),
              _buildContinueWithoutAccount(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Sub-widgets
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _kTeal,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Icon(Icons.health_and_safety, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text(
          'AILaga',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _kText,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to back up your data',
          style: TextStyle(fontSize: 16, color: Color(0xFF555555)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            enabled: !_isLoading,
            validator: _validateEmail,
            decoration: _inputDecoration(
              label: 'Email',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 16),
          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _signInWithEmail(),
            decoration: _inputDecoration(
              label: 'Password',
              icon: Icons.lock_outline,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: const Color(0xFF777777),
                ),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _kTeal),
      filled: true,
      fillColor: _kCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kError),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE8E8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kError),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: _kError, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: _kError, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _forgotPassword,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(color: _kTeal),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: _kTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.login),
        label: Text(
          _isLoading ? 'Signing in…' : 'Sign In',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _kBorder)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Color(0xFF888888))),
        ),
        Expanded(child: Divider(color: _kBorder)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _kText,
          side: const BorderSide(color: _kBorder, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google 'G' logo using coloured segments
            _GoogleLogo(size: 20),
            const SizedBox(width: 12),
            const Text(
              'Sign in with Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateAccountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'No account yet? ',
          style: TextStyle(color: Color(0xFF555555)),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => context.push('/auth/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(
              color: _kTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWithoutAccount() {
    return Center(
      child: TextButton.icon(
        onPressed: _isLoading ? null : () => context.go('/'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF888888),
        ),
        icon: const Icon(Icons.arrow_forward, size: 16),
        label: const Text('Continue without account'),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Simple Google 'G' logo painted with brand colours (no image asset needed)
// ---------------------------------------------------------------------------
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);

    // Background circle clipping
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: r)));

    // Blue top-right
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -1.57, 3.14, true,
      Paint()..color = const Color(0xFF4285F4),
    );
    // Red top-left
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      1.57, 1.57, true,
      Paint()..color = const Color(0xFFEA4335),
    );
    // Yellow bottom-left
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.14, 0.785, true,
      Paint()..color = const Color(0xFFFBBC04),
    );
    // Green bottom-right
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      3.925, 0.785, true,
      Paint()..color = const Color(0xFF34A853),
    );

    // White centre circle to simulate the cut-out
    canvas.drawCircle(center, r * 0.6, Paint()..color = Colors.white);

    // 'G' arm (blue rectangle pointing right)
    final arm = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(r, r - r * 0.22, r, r * 0.44),
      arm,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
