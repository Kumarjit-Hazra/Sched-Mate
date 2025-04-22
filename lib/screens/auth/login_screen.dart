import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class GoogleGLogo extends StatelessWidget {
  final double size;

  const GoogleGLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..isAntiAlias = true;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw white background
    paint.color = Colors.white;
    canvas.drawCircle(center, radius, paint);

    // Create the main G shape using a path
    final path = Path();

    // Start from the right side
    path.moveTo(center.dx + radius * 0.4, center.dy);

    // Draw the outer circle
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 6, // Start at -30 degrees
      -4 * pi / 3, // Sweep -240 degrees clockwise
      false,
    );

    // Create the inner shape
    final innerPath = Path();
    innerPath.addArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      -pi / 6,
      4 * pi / 3,
    );

    // Create the right bar
    final barPath =
        Path()
          ..moveTo(center.dx + radius * 0.4, center.dy - radius * 0.2)
          ..lineTo(center.dx + radius, center.dy - radius * 0.2)
          ..lineTo(center.dx + radius, center.dy + radius * 0.2)
          ..lineTo(center.dx + radius * 0.4, center.dy + radius * 0.2)
          ..close();

    // Combine paths using different operations
    final combinedPath = Path.combine(
      PathOperation.difference,
      path,
      Path.combine(PathOperation.union, innerPath, barPath),
    );

    // Define the colors for each section
    final colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFFEA4335), // Red
    ];

    // Draw each colored section
    final rects = [
      Rect.fromLTWH(0, 0, size.width, size.height / 2), // Blue (top)
      Rect.fromLTWH(
        0,
        size.height / 2,
        size.width / 2,
        size.height / 2,
      ), // Green (bottom left)
      Rect.fromLTWH(
        size.width / 2,
        size.height / 2,
        size.width / 2,
        size.height / 2,
      ), // Yellow (bottom right)
      Rect.fromLTWH(
        size.width * 0.75,
        0,
        size.width * 0.25,
        size.height / 2,
      ), // Red (top right)
    ];

    for (var i = 0; i < colors.length; i++) {
      paint.color = colors[i];
      canvas.save();
      canvas.clipPath(combinedPath);
      canvas.drawRect(rects[i], paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isStudent = true; // Default to student login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final success = await context.read<AuthService>().signIn(
      _emailController.text,
      _passwordController.text,
      role: _isStudent ? 'student' : 'faculty',
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  void _handleGoogleLogin() {
    // TODO: Implement Google login
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Google login coming soon!')));
  }

  void _handleForgotPassword() {
    // TODO: Implement forgot password
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset coming soon!')),
    );
  }

  void _handleCreateAccount() {
    // TODO: Implement account creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account creation coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Hero(
                    tag: 'app_logo',
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SchedMate',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Role selection
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        label: Text('Student'),
                        icon: Icon(Icons.school),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text('Faculty'),
                        icon: Icon(Icons.person_2),
                      ),
                    ],
                    selected: {_isStudent},
                    onSelectionChanged: (Set<bool> selected) {
                      setState(() => _isStudent = selected.first);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText:
                          _isStudent
                              ? 'student@example.com'
                              : 'faculty@example.com',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.email),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _handleForgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login button
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _handleLogin,
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Icon(Icons.login),
                    label: Text(_isLoading ? 'Logging in...' : 'Login'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Google login button with logo
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeInOut,
                    builder: (context, double scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: OutlinedButton(
                          onPressed: _handleGoogleLogin,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.blue.shade200),
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/logo/googlelogo.png',
                                height: 24.0,
                              ),
                              const SizedBox(width: 12.0),
                              const Text(
                                'Sign up with Google',
                                style: TextStyle(
                                  color: Color(0xFF757575),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Create account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: _handleCreateAccount,
                        child: const Text('Create Account'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Made with love
                  const Text(
                    'Made with ❤️ by team tech tetra',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
