import 'package:flutter/material.dart';

class KycFormScreen extends StatefulWidget {
  final Function(Map<String, String>) onKycSubmit;
  const KycFormScreen({Key? key, required this.onKycSubmit}) : super(key: key);

  @override
  State<KycFormScreen> createState() => _KycFormScreenState();
}

class _KycFormScreenState extends State<KycFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _documentType = 'Aadhar';
  final _documentNumberController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onKycSubmit({
        'document_type': _documentType,
        'document_number': _documentNumberController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Verification (Step 2/3)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Provide your KYC details to continue as a host.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _documentType,
                decoration: const InputDecoration(labelText: 'Document Type'),
                items: ['Aadhar', 'PAN Card', 'Voter ID']
                    .map((label) => DropdownMenuItem(child: Text(label), value: label))
                    .toList(),
                onChanged: (value) => setState(() => _documentType = value!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentNumberController,
                decoration: const InputDecoration(labelText: 'Document Number'),
                validator: (value) => value!.isEmpty ? 'Please enter the document number' : null,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 