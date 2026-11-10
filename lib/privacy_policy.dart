import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _privacyPolicyMarkdown = '''
# Privacy Policy for Compass

**Effective Date:** 30-10-2026  
**Company Name:** DeepIgnite™  
**Support Email:** support@deepignite.useinbox.email

---

## 1. Overview
Welcome to **Compass**. We respect your privacy and are committed to protecting any data associated with your use of our application. This Privacy Policy explains how **Compass** handles device data, hardware sensors, and user information.

---

## 2. Information We Collect
* **Personal Information:** We do not collect, store, or share any personally identifiable information (PII) such as your name, email address, phone number, or contacts.
* **Location Data:** The app uses your device’s internal hardware orientation sensors (such as the magnetometer and accelerometer) to calculate direction.
* **Network Access:** This app operates completely offline and does not connect to remote servers or third-party networks.

---

## 3. How We Use Information
* To provide and display accurate compass and orientation data on your device.
* To fix bugs and improve app stability.

---

## 4. Third-Party Services
* We do not sell, rent, or trade your personal data to any third parties.

---

## 5. Children’s Privacy
Our app does not knowingly collect or solicit personal data from children under the age of 13. If you believe a child has provided data through the app, please contact us to have it removed.

---

## 6. Data Security
Because Compass processes data locally on your device, we take reasonable measures to ensure your device data is protected against unauthorized access.

---

## 7. Changes to This Privacy Policy
We may update this Privacy Policy from time to time. Any changes will be posted on this page with a revised "Effective Date" at the top.

---

## 8. Contact Us
If you have any questions or concerns about this Privacy Policy or our data practices, please contact us at:  
* **Email:** contact@deepignite.useinbox.email  
* **Website:** https://deepignite.pages.dev
''';

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final theme = Theme.of(context);
    final baseTextStyle =
        theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: baseTextStyle.copyWith(height: 1.55),
      h1:
          theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: theme.colorScheme.primary,
          ) ??
          const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
      h2:
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ) ??
          const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      h3:
          theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ) ??
          const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      listBullet: baseTextStyle.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      listIndent: 20,
      blockSpacing: 8,
      a: baseTextStyle.copyWith(
        color: theme.colorScheme.primary,
        decoration: TextDecoration.underline,
      ),
      blockquote: baseTextStyle.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Markdown(
            data: _privacyPolicyMarkdown,
            selectable: true,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shrinkWrap: false,
            styleSheet: _buildMarkdownStyleSheet(context),
          ),
        ),
      ),
    );
  }
}
