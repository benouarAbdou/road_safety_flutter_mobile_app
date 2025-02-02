import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  // Show a success toast message
  static void showSuccessToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  // Show an error toast message
  static void showErrorToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 5),
    );
  }

  // Show a warning toast message
  static void showWarningToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  // Show an info toast message
  static void showInfoToast(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flat,
      title: Text(message),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }
}
