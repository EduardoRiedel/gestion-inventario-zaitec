import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../styles.dart';
import '../../Modelos/Cita.dart';
import '../../Modelos/servicio_cita.dart';
import '../../Metodos/borrados.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  // --- VARIABLES DE ESTADO ---
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final ServicioCita _citaService = ServicioCita();

  String _turnoSeleccionado = 'MAÑANA';
  int? _indiceCitaSeleccionada;
  bool _editandoCita = false;
  bool _anadiendoCita = false; // <--- NUEVA: Controla el flujo de añadir

  // Controladores para el formulario de nueva cita
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _servicioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _servicioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool enProceso = _editandoCita || _anadiendoCita;

    return Scaffold(
      backgroundColor: AppStyles.white,
      appBar: AppBar(
        backgroundColor: AppStyles.white,
        elevation: 0,
        title: enProceso
            ? Text(
                _editandoCita ? "Mover a..." : "Selecciona hora",
                style: const TextStyle(color: Colors.orange, fontSize: 16),
              )
            : null,
        leading: const Icon(
          Icons.account_circle_outlined,
          color: AppStyles.black,
          size: 30,
        ),
        actions: [
          if (enProceso)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() {
                _editandoCita = false;
                _anadiendoCita = false;
              }),
            ),
          IconButton(
            icon: const Icon(Icons.menu, color: AppStyles.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. CALENDARIO
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!enProceso) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _indiceCitaSeleccionada = null;
                });
              }
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppStyles.black,
                shape: BoxShape.circle,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 2. SELECTOR MAÑANA / TARDE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShiftButton('MAÑANA'),
              const SizedBox(width: 12),
              _buildShiftButton('TARDE'),
            ],
          ),

          const SizedBox(height: 15),

          // 3. LISTA DINÁMICA (Cambia según si estamos en modo normal, editar o añadir)
          Expanded(
            child: enProceso
                ? _buildAvailableHoursList()
                : _buildAppointmentsList(),
          ),

          // 4. BOTONES INFERIORES
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: enProceso
                        ? null
                        : () => setState(() => _anadiendoCita = true),
                    style: AppStyles.botonPrincipal,
                    child: const Text('Añadir'),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_indiceCitaSeleccionada != null && !enProceso)
                        ? () => setState(() => _editandoCita = true)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          (_indiceCitaSeleccionada != null && !enProceso)
                          ? AppStyles.black
                          : Colors.grey,
                    ).merge(AppStyles.botonPrincipal),
                    child: Text(enProceso ? '---' : 'Editar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LISTA DE HORAS DISPONIBLES (Para Añadir o Editar) ---
  Widget _buildAvailableHoursList() {
    final List<String> horasLibres = _turnoSeleccionado == 'MAÑANA'
        ? ['09:00', '10:30', '12:00']
        : ['16:30', '18:30', '20:00'];

    return ListView.builder(
      itemCount: horasLibres.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (_anadiendoCita) {
              _mostrarDialogoNuevaCita(horasLibres[index]);
            } else {
              // Lógica de mover (Editar)
              setState(() {
                _editandoCita = false;
                _indiceCitaSeleccionada = null;
              });
            }
          },
          child: _appointmentTile(
            horasLibres[index],
            "Disponible",
            "",
            isOccupied: false,
          ),
        );
      },
    );
  }

  //CUADRO DE DIÁLOGO PARA DATOS DEL CLIENTE
  void _mostrarDialogoNuevaCita(String hora) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a usar los botones
      builder: (context) => AlertDialog(
        title: Text(
          "Cita a las $hora",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre del Cliente',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _servicioController,
              decoration: const InputDecoration(labelText: 'Tipo de Servicio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _nombreController.clear();
              _servicioController.clear();
              Navigator.pop(context); // Cierra el diálogo
            },
            child: const Text("CANCELAR", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppStyles.black),
            onPressed: () async {
              // 1. Añadimos 'async' aquí porque guardar en internet tarda un poquito

              // LÓGICA PARA CREAR LA FECHA
              // 'hora' es el String que recibe el método (ej: "09:00")
              final partes = hora.split(':');
              final horaInt = int.parse(partes[0]);
              final minutoInt = int.parse(partes[1]);

              // Combinamos el día que seleccionó el usuario en el calendario con la hora del botón
              final fechaCompleta = DateTime(
                _selectedDay!.year,
                _selectedDay!.month,
                _selectedDay!.day,
                horaInt,
                minutoInt,
              ).toUtc();

              //  CREAMOS EL OBJETO CITA
              final nuevaCita = Cita(
                fechaHora: fechaCompleta,
                usuario: _nombreController
                    .text, // Lo que escribió en el primer TextField
                servicio: _servicioController
                    .text, // Lo que escribió en el segundo TextField
                precio: 25, // !!!!!!!!!!!!!!!!!!!!! Lo dejamos precio fijo
              );

              // --- GUARDAMOS EN EL BACKEND (Firebase) ---
              // Usamos el servicio creado en servicio_cita.dart
              await _citaService.crearCita(nuevaCita);

              // --- LIMPIEZA Y CIERRE ---
              setState(() {
                _anadiendoCita = false;
              });
              _nombreController.clear();
              _servicioController.clear();
              Navigator.pop(
                context,
              ); // Cerramos el diálogo y volvemos a la agenda
            },
            child: const Text(
              "ACEPTAR",
              style: TextStyle(color: AppStyles.white),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE APOYO (Botones y Tiles) ---

  Widget _buildShiftButton(String turno) {
    bool isSelected = _turnoSeleccionado == turno;
    return GestureDetector(
      onTap: () {
        if (!_editandoCita && !_anadiendoCita) {
          setState(() {
            _turnoSeleccionado = turno;
            _indiceCitaSeleccionada = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppStyles.black : AppStyles.white,
          border: Border.all(color: AppStyles.black),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          turno,
          style: TextStyle(
            color: isSelected ? AppStyles.white : AppStyles.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<List<Cita>>(
      stream: _citaService.getCitasPorDia(_selectedDay!),
      builder: (context, snapshot) {
        // 1. Control de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Control de errores
        if (snapshot.hasError) {
          return Center(child: Text("Error al cargar: ${snapshot.error}"));
        }

        // 3. Obtener los datos (si no hay, lista vacía)
        final todasLasCitas = snapshot.data ?? [];

        // 4. Tu lógica de filtrado por turno (Mañana/Tarde)
        final citasFiltradas = todasLasCitas.where((c) {
          if (_turnoSeleccionado == 'MAÑANA') {
            return c.fechaHora.hour < 15;
          } else {
            return c.fechaHora.hour >= 15;
          }
        }).toList();

        // 5. Si no hay nada en ese turno
        if (citasFiltradas.isEmpty) {
          return const Center(child: Text("No hay citas en este turno"));
        }

        // 6. El ListView con los datos reales
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: citasFiltradas.length,
          itemBuilder: (context, index) {
            final cita = citasFiltradas[index];
            bool estaSeleccionada = _indiceCitaSeleccionada == index;

            // Formateamos la hora (HH:mm)
            String horaFormateada =
                "${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}";

            return InkWell(
              onTap: () {
                setState(() {
                  _indiceCitaSeleccionada = estaSeleccionada ? null : index;
                });
              },
              child: GestureDetector(
                // Si pulsamos de forma prolongada o normal en el icono, borramos
                // Pero para hacerlo más preciso, vamos a capturar el toque en el tile
                // Dentro de tu ListView.builder...
                onTap: () {
                  if (estaSeleccionada) {
                    // LLAMADA AL NUEVO ARCHIVO:
                    MetodosCitas.confirmarBorrado(
                      context: context,
                      citaId: cita.id!,
                      servicio: _citaService,
                      onConfirmado: () {
                        // Esto se ejecuta cuando borra con éxito
                        setState(() {
                          _indiceCitaSeleccionada = null;
                        });
                      },
                    );
                  } else {
                    setState(() => _indiceCitaSeleccionada = index);
                  }
                },
                child: _appointmentTile(
                  horaFormateada,
                  cita.usuario,
                  cita.servicio,
                  isOccupied: true,
                  showDelete: estaSeleccionada,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _appointmentTile(
    String time,
    String client,
    String service, {
    required bool isOccupied,
    bool showDelete = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isOccupied && !showDelete
            ? AppStyles.offWhite
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: isOccupied ? AppStyles.black : Colors.green,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              time,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              client,
              style: TextStyle(
                fontSize: 16,
                color: isOccupied ? AppStyles.black : AppStyles.grey,
                fontWeight: isOccupied ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (showDelete)
            const Icon(Icons.delete_outline, color: Colors.red, size: 26)
          else if (isOccupied)
            Text(
              service,
              style: const TextStyle(fontSize: 12, color: AppStyles.grey),
            ),
        ],
      ),
    );
  }
}
