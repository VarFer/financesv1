import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/database/database_service.dart';
import '/database/models/ingreso.dart';
import 'widgets/ingreso_form.dart';

class IngresosScreen extends StatefulWidget {
  const IngresosScreen({super.key});

  @override
  _IngresosScreenState createState() => _IngresosScreenState();
}

class _IngresosScreenState extends State<IngresosScreen> {
  late List<Ingreso> _ingresos;
  late Database _db;
  double _totalIngresos = 0.0; // Variable para almacenar el total de ingresos

  @override
  void initState() {
    super.initState();
    _ingresos = [];
    _loadIngresos();
  }

  // Cargar los ingresos desde la base de datos
  Future<void> _loadIngresos() async {
    try {
      _db = await DatabaseService.getDatabase();
      final List<Map<String, dynamic>> ingresosData = await _db.query('ingresos');
      setState(() {
        _ingresos = ingresosData.map((map) => Ingreso.fromMap(map)).toList();
        _totalIngresos = _ingresos.fold(0.0, (sum, ingreso) => sum + ingreso.monto); // Calcular el total
      });
    } catch (e) {
      // Si ocurre un error al cargar los ingresos, se muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los ingresos: $e')),
      );
    }
  }

  // Mostrar el formulario para agregar un nuevo ingreso
  void _showAddIngresoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IngresoForm(
          onSave: (descripcion, monto) async {
            try {
              await _db.insert('ingresos', {
                'descripcion': descripcion,
                'monto': monto,
                'fecha': DateTime.now().toString(),
              });
              _loadIngresos();
              Navigator.pop(context);
            } catch (e) {
              // Manejar el error en caso de que ocurra
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al agregar el ingreso: $e')),
              );
            }
          },
        );
      },
    );
  }

  // Mostrar el formulario para editar un ingreso
  void _showEditIngresoDialog(Ingreso ingreso) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return IngresoForm(
          onSave: (descripcion, monto) async {
            try {
              await _db.update(
                'ingresos',
                {
                  'descripcion': descripcion,
                  'monto': monto,
                  'fecha': DateTime.now().toString(),
                },
                where: 'id = ?',
                whereArgs: [ingreso.id],
              );
              _loadIngresos();
              Navigator.pop(context);
            } catch (e) {
              // Manejar el error en caso de que ocurra
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al editar el ingreso: $e')),
              );
            }
          },
          descripcion: ingreso.descripcion, // Pasando la descripción
          monto: ingreso.monto, // Pasando el monto
        );
      },
    );
  }

  // Mostrar el popup para eliminar o editar un ingreso
  void _showPopupMenu(BuildContext context, Ingreso ingreso) async {
    final action = await showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        const PopupMenuItem<int>(value: 1, child: Text('Editar')),
        const PopupMenuItem<int>(value: 2, child: Text('Eliminar')),
      ],
    );

    if (action == 1) {
      // Editar el ingreso
      _showEditIngresoDialog(ingreso);
    } else if (action == 2) {
      // Eliminar el ingreso
      try {
        await _db.delete('ingresos', where: 'id = ?', whereArgs: [ingreso.id]);
        _loadIngresos();
      } catch (e) {
        // Manejar el error en caso de que ocurra
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el ingreso: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Ingresos'),
        backgroundColor: Colors.greenAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent.shade100, Colors.green.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Mostrar el total de ingresos
            Text(
              'Total de Ingresos: \$${_totalIngresos.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showAddIngresoDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                'Agregar Ingreso',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _ingresos.length,
                itemBuilder: (context, index) {
                  final ingreso = _ingresos[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        ingreso.descripcion,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Monto: \$${ingreso.monto.toStringAsFixed(2)}\nFecha: ${ingreso.fecha}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (action) {
                          if (action == 1) {
                            _showEditIngresoDialog(ingreso); // Editar
                          } else if (action == 2) {
                            _db.delete('ingresos', where: 'id = ?', whereArgs: [ingreso.id]); // Eliminar
                            _loadIngresos();
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<int>(value: 1, child: Text('Editar')),
                          const PopupMenuItem<int>(value: 2, child: Text('Eliminar')),
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
}
