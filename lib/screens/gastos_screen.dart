import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '/database/database_service.dart';
import '/database/models/gasto.dart';
import 'widgets/gasto_form.dart';

class GastosScreen extends StatefulWidget {
  const GastosScreen({super.key});

  @override
  _GastosScreenState createState() => _GastosScreenState();
}

class _GastosScreenState extends State<GastosScreen> {
  late List<Gasto> _gastos;
  late Database _db;
  double _totalGastos = 0.0;  // Variable para almacenar el total de los gastos

  @override
  void initState() {
    super.initState();
    _gastos = [];
    _loadGastos();
  }

  Future<void> _loadGastos() async {
    _db = await DatabaseService.getDatabase();
    final List<Map<String, dynamic>> gastosData = await _db.query('gastos');
    setState(() {
      _gastos = gastosData.map((map) => Gasto.fromMap(map)).toList();
      _totalGastos = _gastos.fold(0.0, (sum, gasto) => sum + gasto.monto);  // Calcular el total
    });
  }

  void _showAddGastoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GastoForm(
          onSave: (descripcion, monto) async {
            await _db.insert('gastos', {
              'descripcion': descripcion,
              'monto': monto,
              'fecha': DateTime.now().toString(),
            });
            _loadGastos();  // Recargar los gastos y actualizar el total
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showPopupMenu(BuildContext context, Gasto gasto) async {
    final action = await showMenu<int>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 100, 0, 0),
      items: [
        const PopupMenuItem<int>(value: 1, child: Row(children: [Icon(Icons.edit), SizedBox(width: 10), Text('Editar')])),
        const PopupMenuItem<int>(value: 2, child: Row(children: [Icon(Icons.delete), SizedBox(width: 10), Text('Eliminar')])),
        const PopupMenuItem<int>(value: 3, child: Row(children: [Icon(Icons.payment), SizedBox(width: 10), Text('Pagar')])),
      ],
    );

    if (action == 1) {
      _showEditGastoDialog(gasto);
    } else if (action == 2) {
      await _db.delete('gastos', where: 'id = ?', whereArgs: [gasto.id]);
      _loadGastos();  // Recargar los gastos y actualizar el total
    } else if (action == 3) {
      _showPayGastoDialog(gasto);
    }
  }

  void _showEditGastoDialog(Gasto gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GastoForm(
          onSave: (descripcion, monto) async {
            await _db.update(
              'gastos',
              {
                'descripcion': descripcion,
                'monto': monto,
                'fecha': DateTime.now().toString(),
              },
              where: 'id = ?',
              whereArgs: [gasto.id],
            );
            _loadGastos();  // Recargar los gastos y actualizar el total
            Navigator.pop(context);
          },
          descripcion: gasto.descripcion,
          monto: gasto.monto,
        );
      },
    );
  }

  void _showPayGastoDialog(Gasto gasto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pagar Gasto'),
          content: Text('¿Estás seguro de que deseas pagar este gasto de \$${gasto.monto.toStringAsFixed(2)}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.delete('gastos', where: 'id = ?', whereArgs: [gasto.id]);
                _loadGastos();  // Recargar los gastos y actualizar el total
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
        title: const Text('Gestionar Gastos'),
        backgroundColor: Colors.orangeAccent,  // Color personalizado
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blueAccent, Colors.lightBlueAccent],  // Fondo degradado
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _showAddGastoDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,  // Botón color
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text(
                  'Agregar Gasto',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Mostrar el total de los gastos acumulados
              Text(
                'Total de Gastos: \$${_totalGastos.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _gastos.length,
                  itemBuilder: (context, index) {
                    final gasto = _gastos[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 5,  // Sombra de tarjeta
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          gasto.descripcion,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Monto: \$${gasto.monto.toStringAsFixed(2)}\nFecha: ${gasto.fecha}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        trailing: PopupMenuButton<int>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (action) {
                            if (action == 1) {
                              _showEditGastoDialog(gasto); // Editar
                            } else if (action == 2) {
                              _db.delete('gastos', where: 'id = ?', whereArgs: [gasto.id]); // Eliminar
                              _loadGastos();  // Recargar los gastos y actualizar el total
                            } else if (action == 3) {
                              _showPayGastoDialog(gasto); // Pagar
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<int>(
                              value: 1,
                              child: Text('Editar'),
                            ),
                            const PopupMenuItem<int>(
                              value: 2,
                              child: Text('Eliminar'),
                            ),
                            const PopupMenuItem<int>(
                              value: 3,
                              child: Text('Pagar'),
                            ),
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
      ),
    );
  }
}
