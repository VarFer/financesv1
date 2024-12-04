class Gasto {
  final int id;
  final double monto;
  final String descripcion;
  final String fecha;

  Gasto({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  factory Gasto.fromMap(Map<String, dynamic> map) {
    return Gasto(
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
