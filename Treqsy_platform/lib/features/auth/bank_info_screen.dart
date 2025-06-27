import 'package:flutter/material.dart';

class BankInfoScreen extends StatefulWidget {
  final Function(Map<String, String>) onBankSubmit;
  const BankInfoScreen({Key? key, required this.onBankSubmit}) : super(key: key);

  @override
  State<BankInfoScreen> createState() => _BankInfoScreenState();
}

class _BankInfoScreenState extends State<BankInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _ifscCodeController = TextEditingController();
  final _bankNameController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onBankSubmit({
        'account_number': _accountNumberController.text,
        'ifsc_code': _ifscCodeController.text,
        'bank_name': _bankNameController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank Details (Step 3/3)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Provide your bank details for payouts.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _accountNumberController,
                decoration: const InputDecoration(labelText: 'Account Number'),
                validator: (value) => value!.isEmpty ? 'Please enter account number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ifscCodeController,
                decoration: const InputDecoration(labelText: 'IFSC Code'),
                validator: (value) => value!.isEmpty ? 'Please enter IFSC code' : null,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(labelText: 'Bank Name'),
                validator: (value) => value!.isEmpty ? 'Please enter bank name' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Complete Registration'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 