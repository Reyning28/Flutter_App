import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo o título
                Icon(
                  Icons.task_alt,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  'Productividad App',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                
                // Campo de nombre (solo para registro)
                if (!_isLogin) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (!_isLogin && (value == null || value.trim().isEmpty)) {
                        return 'Por favor ingresa tu nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    helperText: 'Mínimo 6 caracteres',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    if (!_isLogin && value.length < 8) {
                      return 'Para registro, usa al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Botón principal
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                ),
                const SizedBox(height: 16),
                
                // Cambiar entre login y registro
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? '¿No tienes cuenta? Regístrate'
                        : '¿Ya tienes cuenta? Inicia sesión',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final authService = ref.read(authServiceProvider);
        
        if (_isLogin) {
          // Iniciar sesión
          final user = await authService.login(
            _emailController.text.trim(),
            _passwordController.text,
          );
          
          if (user != null && mounted) {
            // Actualizar providers
            ref.read(currentUserProvider.notifier).setUser(user);
            ref.read(authStateProvider.notifier).setAuthenticated(true);
            
            // Navegar a home
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        } else {
          // Registrar usuario
          final user = await authService.register(
            _nameController.text.trim(),
            _emailController.text.trim(),
            _passwordController.text,
          );
          
          if (user != null && mounted) {
            // Actualizar providers
            ref.read(currentUserProvider.notifier).setUser(user);
            ref.read(authStateProvider.notifier).setAuthenticated(true);
            
            // Navegar a home
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}