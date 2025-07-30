import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'dart:ui' show PlatformDispatcher;

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(FlutterErrorDetails)? errorWidgetBuilder;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidgetBuilder,
  });

  @override
  ErrorBoundaryState createState() => ErrorBoundaryState();
}

class ErrorBoundaryState extends State<ErrorBoundary> {
  FlutterErrorDetails? _errorDetails;

  @override
  void initState() {
    super.initState();
    
    // Set up global error handler for errors that occur during build/rendering
    FlutterError.onError = (FlutterErrorDetails details) {
      // Log the error
      developer.log(
        'ErrorBoundary caught error',
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // Update state to show error UI
      if (mounted) {
        setState(() {
          _errorDetails = details;
        });
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_errorDetails != null) {
      return widget.errorWidgetBuilder?.call(_errorDetails!) ?? 
          _buildDefaultErrorWidget(_errorDetails!);
    }
    
    return widget.child;
  }

  Widget _buildDefaultErrorWidget(FlutterErrorDetails errorDetails) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(31, 123, 129, 1),
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ein unerwarteter Fehler ist aufgetreten',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Die App wird automatisch neu gestartet.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _errorDetails = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('App neu starten'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromRGBO(31, 123, 129, 1),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (errorDetails.exception.toString().isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Fehlerdetails:\n${errorDetails.exception}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorBoundary {
  static void setupGlobalErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      developer.log(
        'Flutter Error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };
    
    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      developer.log(
        'Platform Error',
        error: error,
        stackTrace: stack,
      );
      return true;
    };
  }
}