import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Your complete template stored as a clean Markdown string
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Markdown(
          data: _privacyPolicyMarkdown,
          selectable: true, // Allows users to highlight and copy text like the email
          padding: const EdgeInsets.all(16.0),
          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
            h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
            h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                ),
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.5, // Improves readability line-spacing
                ),
            listBullet: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.blueAccent,
                ),
          ),
        ),
      ),
    );
  }
}
