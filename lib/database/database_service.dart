import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<void> init() async {
    await getDatabase();
  }

  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    _database =
        await openDatabase('finanzas.db', version: 1, onCreate: (db, version) {
      db.execute('''CREATE TABLE deudas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descripcion TEXT,
        monto REAL,
        fecha TEXT,
        estado TEXT
      )''');

      db.execute('''CREATE TABLE ingresos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto REAL
      )''');

      db.execute('''CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        monto REAL,
        descripcion TEXT,
        fecha TEXT
      )''');
    });

    return _database!;
  }

  static Future<void> addDeuda(
      String descripcion, double monto, String fecha, String estado) async {
    final db = await getDatabase();
    await db.insert('deudas', {
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha,
      'estado': estado,
    });
  }

  static Future<void> updateDeudaEstado(int deudaId, String estado) async {
    final db = await getDatabase();

    await db.update(
      'deudas',
      {'estado': estado},
      where: 'id = ?',
      whereArgs: [deudaId],
    );

    if (estado == 'pagada') {
      await _descontarIngreso(deudaId);
    }
  }

  static Future<void> _descontarIngreso(int deudaId) async {
    final db = await getDatabase();

    final deuda =
        await db.query('deudas', where: 'id = ?', whereArgs: [deudaId]);
    if (deuda.isEmpty) return;

    final montoDeuda = deuda.first['monto'] as double;

    final totalIngresos = await getTotalIngresos();

    final nuevoTotal = totalIngresos - montoDeuda;

    await db.update(
      'ingresos',
      {'monto': nuevoTotal},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  static Future<double> getTotalIngresos() async {
    final db = await getDatabase();

    final result = await db.query('ingresos');
    if (result.isEmpty) {
      return 0.0;
    }

    return result.first['monto'] as double;
  }

  static Future<void> agregarIngreso(double monto) async {
    final db = await getDatabase();
    final totalIngresos = await getTotalIngresos();

    if (totalIngresos == 0.0) {
      await db.insert('ingresos', {'monto': monto});
    } else {
      final nuevoTotal = totalIngresos + monto;
      await db.update(
        'ingresos',
        {'monto': nuevoTotal},
        where: 'id = ?',
        whereArgs: [1],
      );
    }
  }

  static Future<void> restarIngreso(double monto) async {
    final db = await getDatabase();
    final totalIngresos = await getTotalIngresos();

    if (totalIngresos >= monto) {
      final nuevoTotal = totalIngresos - monto;
      await db.update(
        'ingresos',
        {'monto': nuevoTotal},
        where: 'id = ?',
        whereArgs: [1],
      );
    } else {
      throw Exception("No hay suficientes ingresos para realizar la resta.");
    }
  }

  static Future<double> getTotalGastos() async {
    final db = await getDatabase();

    final result = await db.query('gastos');
    if (result.isEmpty) {
      return 0.0;
    }

    double totalGastos = 0.0;
    for (var gasto in result) {
      totalGastos += gasto['monto'] as double;
    }
    return totalGastos;
  }

  static Future<void> agregarGasto(
      double monto, String descripcion, String fecha) async {
    final db = await getDatabase();
    await db.insert('gastos', {
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha,
    });
  }

  static Future<double> getTotalDeudas() async {
    final db = await getDatabase();

    final result =
        await db.query('deudas', where: 'estado = ?', whereArgs: ['pendiente']);
    if (result.isEmpty) {
      return 0.0;
    }

    double totalDeudas = 0.0;
    for (var deuda in result) {
      totalDeudas += deuda['monto'] as double;
    }
    return totalDeudas;
  }

  static Future<double> getTotalPagos() async {
    final db = await getDatabase();

    final result =
        await db.query('deudas', where: 'estado = ?', whereArgs: ['pagada']);
    if (result.isEmpty) {
      return 0.0;
    }

    double totalPagos = 0.0;
    for (var deuda in result) {
      totalPagos += deuda['monto'] as double;
    }
    return totalPagos;
  }
}
