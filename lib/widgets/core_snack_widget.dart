import 'package:flutter/material.dart';
import 'package:core_tuner/colors.dart';

class CoreSnack {
  static void show(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        backgroundColor: isError ? AppColors.red.withValues(alpha: 0.8) : AppColors.lightBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
        margin: const EdgeInsets.all(20),
      ),
    );
  }
}