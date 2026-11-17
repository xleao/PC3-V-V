Feature: Cancelación y liberación automática de reservas de espacios comunes
  Como residente o administrador del condominio en Comunidad360
  Quiero cancelar reservas dentro del plazo y liberar reservas impagas vencidas
  Para mantener disponibles las áreas comunes para todos los vecinos

  Rule: El residente solo puede cancelar con al menos 2 días de anticipación y sin pago validado

    Scenario: Cancelación exitosa con 7 días de anticipación y sin comprobante
      Given que el residente "Carlos Mendoza" tiene una reserva en estado "SOLICITADO" para dentro de 7 días
      And la reserva no tiene comprobante de pago validado
      When el residente solicita cancelar su reserva
      Then la reserva cambia al estado "CANCELADO_USUARIO"
      And el horario del salón queda libre

    Scenario: Rechazo de cancelación cuando falta solo 1 día para el evento
      Given que el residente "Carlos Mendoza" tiene una reserva en estado "SOLICITADO" para dentro de 1 día
      When el residente intenta cancelar su reserva
      Then el sistema impide la cancelación
      And muestra el aviso "Cancelación disponible con más de 2 días de anticipación."

    Scenario: Rechazo de cancelación cuando el pago ya fue validado
      Given que el residente "Carlos Mendoza" tiene una reserva en estado "CONFIRMADO" para dentro de 7 días
      And el pago de la reserva ya fue validado por el administrador
      When el residente intenta cancelar su reserva
      Then el sistema impide la cancelación
      And muestra el aviso "No puedes cancelar una reserva con pago registrado. Contacta al administrador para gestionar la cancelación."
      And la reserva sigue en estado "CONFIRMADO"

  Rule: Las reservas con pago diferido vencido y sin comprobante se liberan solas

    Scenario: Liberación automática de reserva diferida vencida sin pago
      Given que existe una reserva en estado "SOLICITADO" con pago diferido vencido hace 1 hora
      And el residente no subió ningún comprobante de pago
      When se ejecuta la revisión automática de reservas vencidas
      Then la reserva pasa al estado "CANCELADO_ADMIN"
      And se registra la nota "Cancelación automática: Plazo expirado."
