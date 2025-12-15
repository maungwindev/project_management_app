import 'package:flutter/material.dart';

/// TO SHOW WHEN THERE IS NO INTERNET CONNECTION
class InternetErrorWidget extends StatelessWidget {
  const InternetErrorWidget({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor, // Adapts to both light and dark
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wifi_off_sharp,
              size: 64,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 20),
            Text(
              "No Internet Connection",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Please check your connection and try again.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}
