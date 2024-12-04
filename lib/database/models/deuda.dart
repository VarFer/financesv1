class Deuda {
  final int id;
  final double monto;
  final String descripcion;
  final String fecha;
  final String estado; // Nueva propiedad

  Deuda({
    required this.id,
    required this.monto,
    required this.descripcion,
    required this.fecha,
    required this.estado,
  });

  factory Deuda.fromMap(Map<String, dynamic> map) {
    return Deuda(
      id: map['id'],
      monto: map['monto'],
      descripcion: map['descripcion'],
      fecha: map['fecha'],
      estado: map['estado'],
    );
  }
}
