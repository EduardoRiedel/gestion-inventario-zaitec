import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../styles.dart';

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
          ? Text(_editandoCita ? "Mover a..." : "Selecciona hora", 
              style: const TextStyle(color: Colors.orange, fontSize: 16)) 
          : null,
        leading: const Icon(Icons.account_circle_outlined, color: AppStyles.black, size: 30),
        actions: [
          if (enProceso)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => setState(() {
                _editandoCita = false;
                _anadiendoCita = false;
              }),
            ),
          IconButton(icon: const Icon(Icons.menu, color: AppStyles.black), onPressed: () {}),
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
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(color: AppStyles.black, shape: BoxShape.circle),
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
            child: enProceso ? _buildAvailableHoursList() : _buildAppointmentsList(),
          ),

          // 4. BOTONES INFERIORES
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: enProceso ? null : () => setState(() => _anadiendoCita = true),
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
                      backgroundColor: (_indiceCitaSeleccionada != null && !enProceso) ? AppStyles.black : Colors.grey,
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
          child: _appointmentTile(horasLibres[index], "Disponible", "", isOccupied: false),
        );
      },
    );
  }

  // --- CUADRO DE DIÁLOGO PARA DATOS DEL CLIENTE ---
  void _mostrarDialogoNuevaCita(String hora) {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a usar los botones
      builder: (context) => AlertDialog(
        title: Text("Cita a las $hora", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre del Cliente'),
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
            onPressed: () {
              // Aquí iría el guardado en base de datos
              setState(() {
                _anadiendoCita = false;
              });
              _nombreController.clear();
              _servicioController.clear();
              Navigator.pop(context); // Vuelve a la agenda
            },
            child: const Text("ACEPTAR", style: TextStyle(color: AppStyles.white)),
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
        child: Text(turno, style: TextStyle(color: isSelected ? AppStyles.white : AppStyles.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final List<Map<String, dynamic>> citas = _turnoSeleccionado == 'MAÑANA'
        ? [
            {'hora': '10:00', 'cliente': 'Juan Perez', 'servicio': 'Corte + barba', 'ocupado': true},
            {'hora': '11:00', 'cliente': 'Boro Loste', 'servicio': 'Corte', 'ocupado': true},
          ]
        : [
            {'hora': '16:00', 'cliente': 'Carlos Ruiz', 'servicio': 'Tinte', 'ocupado': true},
          ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];
        bool estaSeleccionada = _indiceCitaSeleccionada == index;

        return InkWell(
          onTap: () {
            setState(() {
              if (cita['ocupado']) {
                _indiceCitaSeleccionada = estaSeleccionada ? null : index;
              } else {
                _indiceCitaSeleccionada = null;
              }
            });
          },
          child: _appointmentTile(
            cita['hora'],
            cita['cliente'],
            cita['servicio'],
            isOccupied: cita['ocupado'],
            showDelete: estaSeleccionada,
          ),
        );
      },
    );
  }

  Widget _appointmentTile(String time, String client, String service,
      {required bool isOccupied, bool showDelete = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: isOccupied && !showDelete ? AppStyles.offWhite : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: isOccupied ? AppStyles.black : Colors.green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(client, style: TextStyle(fontSize: 16, color: isOccupied ? AppStyles.black : AppStyles.grey, fontWeight: isOccupied ? FontWeight.bold : FontWeight.normal)),
          ),
          if (showDelete)
            const Icon(Icons.delete_outline, color: Colors.red, size: 26)
          else if (isOccupied)
            Text(service, style: const TextStyle(fontSize: 12, color: AppStyles.grey)),
        ],
      ),
    );
  }
}