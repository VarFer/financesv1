class Pago {
  final int id;
  final int deudaId;
  final double monto;
  final String fecha;

  Pago({
    required this.id,
    required this.deudaId,
    required this.monto,
    required this.fecha,
  });

  factory Pago.fromMap(Map<String, dynamic> map) {
    return Pago(
      id: map['id'],
      deudaId: map['deuda_id'],
      monto: map['monto'],
      fecha: map['fecha'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deuda_id': deudaId,
      'monto': monto,
      'fecha': fecha,
    };
  }
}
