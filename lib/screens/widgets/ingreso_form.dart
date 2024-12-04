import 'package:flutter/material.dart';

class IngresoForm extends StatelessWidget {
  final Function(String, double) onSave;
  final TextEditingController descripcionController;
  final TextEditingController montoController;

  // Constructor con parámetros opcionales para descripcion y monto
  IngresoForm({
    super.key,
    required this.onSave,
    String? descripcion,  // Descripción opcional
    double? monto,        // Monto opcional
  })  : descripcionController = TextEditingController(text: descripcion),
        montoController = TextEditingController(text: monto?.toString() ?? '');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Ingreso'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descripcionController,
            decoration: const InputDecoration(labelText: 'Descripción'),
            onSubmitted: (_) => _saveIngreso(), // Detecta cuando presionan Enter
          ),
          TextField(
            controller: montoController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Monto'),
            onSubmitted: (_) => _saveIngreso(), // Detecta cuando presionan Enter
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
          onPressed: _saveIngreso, // Guardar cuando se presiona el botón
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  // Función para guardar el ingreso
  void _saveIngreso() {
    final descripcion = descripcionController.text;
    final monto = double.tryParse(montoController.text) ?? 0.0;
    if (descripcion.isNotEmpty && monto > 0) {
      onSave(descripcion, monto); // Llama a la función onSave
    }
  }
}
