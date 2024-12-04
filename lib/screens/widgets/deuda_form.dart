import 'package:flutter/material.dart';

class DeudaForm extends StatelessWidget {
  final Function(String, double) onSave;
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  final String? descripcion;
  final double? monto;

  DeudaForm({super.key, required this.onSave, this.descripcion, this.monto}) {
    if (descripcion != null) {
      descripcionController.text = descripcion!;
    }
    if (monto != null) {
      montoController.text = monto.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Deuda'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
            onSubmitted: (_) => _saveDeuda(), // Detecta cuando presionan Enter
          ),
          TextField(
            controller: montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto'),
            onSubmitted: (_) => _saveDeuda(), // Detecta cuando presionan Enter
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _saveDeuda, // Guarda cuando se presiona el botón
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // Función para guardar la deuda
  void _saveDeuda() {
    final descripcion = descripcionController.text;
    final monto = double.tryParse(montoController.text) ?? 0.0;
    if (descripcion.isNotEmpty && monto > 0) {
      onSave(descripcion, monto); // Llama a la función onSave
    }
  }
}
