import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/database/database_service.dart';
import '/database/models/deuda.dart';
import 'widgets/deuda_form.dart';

class DeudasScreen extends StatefulWidget {
  const DeudasScreen({super.key});
  @override
  DeudasScreenState createState() => DeudasScreenState();
}

class DeudasScreenState extends State<DeudasScreen> {
  late List<Deuda> _deudas;
  late Database _db;
  int _deudaCount = 0; 
  double _totalMontoDeudas = 0.0; 
  @override
  void initState() {
    super.initState();
    _deudas = [];
    _loadDeudas();
  }

  // Método para cargar las deudas de la base de datos
  Future<void> _loadDeudas() async {
    _db = await DatabaseService.getDatabase();
    final List<Map<String, dynamic>> deudasData = await _db.query('deudas');
    
    if (mounted) {
      setState(() {
        _deudas = deudasData.map((map) => Deuda.fromMap(map)).toList();
        _deudaCount = _deudas.length; // Actualiza el contador de deudas
        _totalMontoDeudas = _deudas.fold(0.0, (sum, deuda) => sum + deuda.monto); // Calcula el total de los montos
      });
    }
  }

  // Método para agregar una deuda
  void _showAddDeudaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeudaForm(
          onSave: (descripcion, monto) async {
            await _db.insert('deudas', {
              'descripcion': descripcion,
              'monto': monto,
              'fecha': DateTime.now().toString(),
              'estado': 'pendiente', // Nueva columna de estado
            });
            if (mounted) {
              _loadDeudas();
            }
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // Método para eliminar una deuda
  Future<void> _eliminarDeuda(Deuda deuda) async {
    await _db.delete('deudas', where: 'id = ?', whereArgs: [deuda.id]);
    if (mounted) {
      _loadDeudas();
    }
  }

  // Método para pagar una deuda
  void _showPayDeudaDialog(Deuda deuda) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pagar Deuda'),
          content: Text(
              '¿Estás seguro de que deseas pagar esta deuda de \$${deuda.monto.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Actualiza la deuda a estado "pagada"
                await _db.update(
                  'deudas',
                  {'estado': 'pagada'}, // Marcamos como pagada
                  where: 'id = ?',
                  whereArgs: [deuda.id],
                );

                if (mounted) {
                  _loadDeudas();
                }
                Navigator.pop(context);
              },
              child: const Text('Pagar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Deudas'),
        backgroundColor: Colors.teal, // Color para la barra de app
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orangeAccent.withOpacity(0.7),  // Color inicial
              Colors.deepPurpleAccent.withOpacity(0.7),  // Color final
            ],
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _showAddDeudaDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrangeAccent, // Color suave para el botón
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Esquinas redondeadas
                ),
              ),
              child: const Text(
                'Agregar Deuda',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Contador de deudas
            Text(
              'Total de Deudas: $_deudaCount',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Contador de monto total de deudas
            Text(
              'Monto Total: \$${_totalMontoDeudas.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _deudas.length,
                itemBuilder: (context, index) {
                  final deuda = _deudas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white.withOpacity(0.8), // Fondo más suave
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        deuda.descripcion,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Monto: \$${deuda.monto.toStringAsFixed(2)}\nFecha: ${deuda.fecha}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert, color: Colors.teal),
                        onSelected: (action) {
                          _showPopupMenu(context, deuda);
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<int>(value: 1, child: Text('Editar')),
                          const PopupMenuItem<int>(value: 2, child: Text('Eliminar')),
                          const PopupMenuItem<int>(value: 3, child: Text('Pagar')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, Deuda deuda) async {
    final action = await showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        const PopupMenuItem<int>(value: 1, child: Text('Editar')),
        const PopupMenuItem<int>(value: 2, child: Text('Eliminar')),
        const PopupMenuItem<int>(value: 3, child: Text('Pagar')),
      ],
    );

    if (action == 1) {
      // Editar la deuda
      _showEditDeudaDialog(deuda);
    } else if (action == 2) {
      // Eliminar la deuda
      await _eliminarDeuda(deuda);
    } else if (action == 3) {
      // Pagar la deuda
      _showPayDeudaDialog(deuda);
    }
  }

  // Mostrar el formulario para editar una deuda
  void _showEditDeudaDialog(Deuda deuda) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeudaForm(
          onSave: (descripcion, monto) async {
            await _db.update(
              'deudas',
              {
                'descripcion': descripcion,
                'monto': monto,
                'fecha': DateTime.now().toString(),
              },
              where: 'id = ?',
              whereArgs: [deuda.id],
            );
            if (mounted) {
              _loadDeudas();
            }
            Navigator.pop(context);
          },
          descripcion: deuda.descripcion,
          monto: deuda.monto,
        );
      },
    );
  }
}
