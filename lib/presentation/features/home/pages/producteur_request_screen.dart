import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:agri_marketplace/presentation/features/home/provider/profile_provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:agri_marketplace/presentation/features/auth/provider/auth_provider.dart';
import 'package:agri_marketplace/data/models/auth_model.dart';

class ProducteurRequestScreen extends StatefulWidget {
  @override
  State<ProducteurRequestScreen> createState() =>
      _ProducteurRequestScreenState();
}

class _ProducteurRequestScreenState extends State<ProducteurRequestScreen> {
  int _step = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  // Pièces jointes
  PlatformFile? _identityFile;
  PlatformFile? _addressFile;
  PlatformFile? _bioFile;
  List<PlatformFile> _otherFiles = [];

  bool _isSubmitting = false;

  void _nextStep() {
    if (_step == 0 && _formKey.currentState!.validate()) {
      setState(() => _step = 1);
    }
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final request = EvolutionProducteurRequest(
      nomExploitation: _nameController.text,
      descriptionExploitation: _descController.text,
      adresseExploitation: _addressController.text,
      telephoneExploitation: _phoneController.text,
      identityFile: _identityFile,
      addressFile: _addressFile,
      bioFile: _bioFile,
      otherFiles: _otherFiles,
    );
    final success = await profileProvider.demandeEvolutionProducteur(request);
    setState(() => _isSubmitting = false);
    if (success) {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text(
                'Demande envoyée',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Votre demande pour devenir producteur a été envoyée avec succès. Vous recevrez une confirmation après vérification.',
                style: GoogleFonts.montserrat(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('OK', style: GoogleFonts.montserrat()),
                ),
              ],
            ),
      );
    } else {
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: Text(
                'Erreur',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Échec de l\'envoi de la demande. Veuillez réessayer.',
                style: GoogleFonts.montserrat(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('OK', style: GoogleFonts.montserrat()),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Demande Producteur', style: GoogleFonts.montserrat()),
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _step == 0 ? _nextStep : _submit,
        onStepCancel: _step == 1 ? () => setState(() => _step = 0) : null,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              ElevatedButton(
                onPressed: details.onStepContinue,
                child:
                    _step == 0
                        ? Text('Suivant')
                        : (_isSubmitting
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Envoyer')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  textStyle: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (_step == 1)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text('Précédent', style: GoogleFonts.montserrat()),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: Text('Informations', style: GoogleFonts.montserrat()),
            isActive: _step == 0,
            state: _step > 0 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informations sur l\'exploitation',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: "Nom de l'exploitation *",
                    ),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: "Description de l'exploitation *",
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator:
                        (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(labelText: "Adresse *"),
                    validator:
                        (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(labelText: "Téléphone *"),
                          keyboardType: TextInputType.phone,
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Champ requis'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text('Pièces jointes', style: GoogleFonts.montserrat()),
            isActive: _step == 1,
            state: StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajout des pièces jointes',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 16),
                _buildFilePicker(
                  'Document d\'identité (PDF/JPG/PNG) *',
                  _identityFile,
                  (f) => setState(() => _identityFile = f),
                  required: true,
                ),
                SizedBox(height: 12),
                _buildFilePicker(
                  'Justificatif d\'adresse (PDF/JPG/PNG) *',
                  _addressFile,
                  (f) => setState(() => _addressFile = f),
                  required: true,
                ),
                SizedBox(height: 12),
                _buildFilePicker(
                  'Certificat Bio (optionnel)',
                  _bioFile,
                  (f) => setState(() => _bioFile = f),
                ),
                SizedBox(height: 12),
                _buildFilePicker(
                  'Autres documents (optionnel, multiple)',
                  null,
                  (f) => setState(() => _otherFiles.add(f!)),
                ),
                SizedBox(height: 8),
                Text(
                  'Vous pouvez ajouter plusieurs fichiers.',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(Function(PlatformFile?) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      onPicked(result.files.single);
    }
  }

  Widget _buildFilePicker(
    String label,
    PlatformFile? file,
    Function(PlatformFile?) onPicked, {
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: required ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(height: 4),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _pickFile(onPicked),
              child: Text(file == null ? 'Choisir un fichier' : 'Modifier'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF4CAF50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                file?.name ?? 'Aucun fichier choisi',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: file == null ? Colors.grey : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (required && file == null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Fichier requis. Format accepté : PDF, JPG, PNG.',
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.red),
            ),
          ),
        if (!required)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Fichier optionnel. Format accepté : PDF, JPG, PNG.',
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }
}
