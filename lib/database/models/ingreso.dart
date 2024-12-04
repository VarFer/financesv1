class Ingreso {
  final int id;
  final double monto;
  final String descripcion;
  final String fecha;

  Ingreso({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  factory Ingreso.fromMap(Map<String, dynamic> map) {
    return Ingreso(
      id: map['id'],
      monto: map['monto'],
      descripcion: map['descripcion'],
      fecha: map['fecha'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monto': monto,
      'descripcion': descripcion,
      'fecha': fecha,
    };
  }
}
