import 'package:flutter/material.dart';

/// Utility class for extracting user-friendly error messages from exceptions
class ErrorHelper {
  /// Extracts a user-friendly error message from an exception
  static String getErrorMessage(dynamic error) {
    if (error == null) {
      return 'An error occurred. Please try again.';
    }

    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception: " prefix if present
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }

    final errorString = error.toString();
    // Remove common prefixes
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    if (errorString.startsWith('Error: ')) {
      return errorString.substring(7);
    }

    return errorString;
  }

  /// Shows a SnackBar with the error message
  static void showError(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

