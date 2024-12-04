import 'package:flutter/material.dart';
import 'ingresos_screen.dart';
import 'gastos_screen.dart';
import 'deudas_screen.dart';
import 'estadisticas_screen.dart';
import '/database/database_service.dart';

class EscritorioScreen extends StatefulWidget {
  const EscritorioScreen({super.key});

  @override
  _EscritorioScreenState createState() => _EscritorioScreenState();
}

class _EscritorioScreenState extends State<EscritorioScreen> {
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
  }

  // Método para calcular el total (ingresos - gastos + deudas pagadas)
  Future<void> _calculateTotal() async {
    final db = await DatabaseService.getDatabase();
    
    // Obtener los ingresos
    final ingresosData = await db.query('ingresos');
    double ingresosTotal = 0.0;
    for (var ingreso in ingresosData) {
      ingresosTotal += ingreso['monto'] as double;
    }
    
    // Obtener los gastos
    final gastosData = await db.query('gastos');
    double gastosTotal = 0.0;
    for (var gasto in gastosData) {
      gastosTotal += gasto['monto'] as double;
    }
    
    // Obtener las deudas pagadas
    final deudasData = await db.query('deudas', where: 'estado = ?', whereArgs: ['pagada']);
    double deudasPagadasTotal = 0.0;
    for (var deuda in deudasData) {
      deudasPagadasTotal += deuda['monto'] as double;
    }
    
    // Calcular el total (ingresos - gastos + deudas pagadas)
    setState(() {
      _total = ingresosTotal - gastosTotal + deudasPagadasTotal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FINANCES'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 6, // Sombra del app bar
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://as2.ftcdn.net/v2/jpg/02/29/88/75/1000_F_229887520_Lg7Iy2ot7TlidRsuV1qNtmZZDq3pXoUi.jpg',
              fit: BoxFit.cover, // Asegura que la imagen se cubra toda la pantalla
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Fondo semitransparente
              backgroundBlendMode: BlendMode.darken,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tu Gestión Financiera',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Selecciona tu opción',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Text(
                  'Total: \$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // GridView para organizar las Cards en dos filas y dos columnas
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,  // Número de columnas
                      crossAxisSpacing: 20.0,  // Espaciado entre columnas
                      mainAxisSpacing: 20.0,  // Espaciado entre filas
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _buildCardButton(
                            context,
                            'Gestionar Ingresos',
                            Colors.green,
                            const IngresosScreen(),
                          );
                        case 1:
                          return _buildCardButton(
                            context,
                            'Gestionar Gastos',
                            Colors.orange,
                            const GastosScreen(),
                          );
                        case 2:
                          return _buildCardButton(
                            context,
                            'Gestionar Deudas',
                            Colors.red,
                            const DeudasScreen(),
                          );
                        case 3:
                          return _buildCardButton(
                            context,
                            'Ver Estadísticas',
                            Colors.blue,
                            const EstadisticasScreen(),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para crear el botón dentro de una Card
  Widget _buildCardButton(
    BuildContext context,
    String text,
    Color color,
    Widget screen,
  ) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(seconds: 1),
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadowColor: color.withOpacity(0.5),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => screen,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Deslizar de derecha a izquierda
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(position: offsetAnimation, child: child);
                  },
                ),
              ).then((_) {
                _calculateTotal(); // Actualizar el total después de regresar
              });
            },
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
