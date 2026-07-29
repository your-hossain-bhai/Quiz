import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import 'package:go_router/go_router.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubscriptionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: _buildBody(provider),
        ),
      ),
    );
  }

  Widget _buildBody(SubscriptionProvider provider) {
    if (provider.isLoading) {
      return const CircularProgressIndicator();
    }

    if (provider.state == SubscriptionState.subscribed) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text(
            'You are subscribed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Go to Home'),
          )
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (provider.errorMessage.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 24),
            color: Colors.red.shade100,
            child: Text(
              provider.errorMessage,
              style: TextStyle(color: Colors.red.shade900),
            ),
          ),
        if (provider.state == SubscriptionState.inputPhone || provider.state == SubscriptionState.error) ...[
          const Text(
            'Enter your mobile number to subscribe',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: '018XXXXXXXX',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_phoneController.text.isNotEmpty) {
                provider.sendOtp(_phoneController.text);
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Send OTP', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
        if (provider.state == SubscriptionState.inputOtp) ...[
          const Text(
            'Enter the OTP sent to your phone',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              if (_otpController.text.isNotEmpty) {
                provider.verifyOtp(_otpController.text);
              }
            },
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Verify & Subscribe', style: TextStyle(fontSize: 16)),
            ),
          ),
          TextButton(
            onPressed: () => provider.reset(),
            child: const Text('Change Phone Number'),
          )
        ],
      ],
    );
  }
}
