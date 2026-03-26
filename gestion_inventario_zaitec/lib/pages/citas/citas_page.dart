import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // --- SERVICIOS Y CONTROLADORES ---
  final ServicioCita _citaService = ServicioCita();
  
  // Controladores para diálogos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _filtroNombreController = TextEditingController();

  // --- VARIABLES DE ESTADO ---
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _turnoSeleccionado = 'MAÑANA';
  int? _indiceCitaSeleccionada;
  bool _editandoCita = false;
  bool _anadiendoCita = false;

  // Variables de Filtrado
  String? _filtroNombre;
  String? _filtroServicio;
  String _servicioFiltroSeleccionado = 'Todos';
  
  final List<String> _serviciosDisponibles = [
    'Todos', 'Corte', 'Corte + barba', 'Barba', 'Tinte', 'Lavado',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _filtroNombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool enProceso = _editandoCita || _anadiendoCita;
    bool hayFiltrosActive = _filtroNombre != null || _filtroServicio != null;

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
          IconButton(
            icon: Icon(Icons.filter_list, color: hayFiltrosActive ? Colors.orange : AppStyles.black),
            onPressed: _mostrarDialogoFiltro,
          ),
          IconButton(icon: const Icon(Icons.menu, color: AppStyles.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildShiftButton('MAÑANA'),
              const SizedBox(width: 12),
              _buildShiftButton('TARDE'),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: enProceso ? _buildAvailableHoursList() : _buildAppointmentsList(),
          ),
          _buildBottomButtons(enProceso),
        ],
      ),
    );
  }

  // --- LISTA DINÁMICA CON FILTROS Y STREAM ---
  Widget _buildAppointmentsList() {
    return StreamBuilder<List<Cita>>(
      stream: _citaService.getCitasPorDia(_selectedDay!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppStyles.black));
        }
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final todasLasCitas = snapshot.data ?? [];

        // FILTRADO COMBINADO (Turno + Nombre + Servicio)
        final citasFiltradas = todasLasCitas.where((c) {
          bool cumpleTurno = _turnoSeleccionado == 'MAÑANA' ? c.fechaHora.hour < 15 : c.fechaHora.hour >= 15;
          bool cumpleNombre = _filtroNombre == null || c.usuario.toLowerCase().contains(_filtroNombre!.toLowerCase());
          bool cumpleServicio = _filtroServicio == null || c.servicio == _filtroServicio;
          return cumpleTurno && cumpleNombre && cumpleServicio;
        }).toList();

        if (citasFiltradas.isEmpty) return const Center(child: Text("No hay citas que coincidan"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: citasFiltradas.length,
          itemBuilder: (context, index) {
            final cita = citasFiltradas[index];
            bool estaSeleccionada = _indiceCitaSeleccionada == index;
            String horaStr = "${cita.fechaHora.hour.toString().padLeft(2, '0')}:${cita.fechaHora.minute.toString().padLeft(2, '0')}";

            return InkWell(
              onTap: () {
                if (estaSeleccionada) {
                  MetodosCitas.confirmarBorrado(
                    context: context,
                    citaId: cita.id!,
                    servicio: _citaService,
                    onConfirmado: () => setState(() => _indiceCitaSeleccionada = null),
                  );
                } else {
                  setState(() => _indiceCitaSeleccionada = index);
                }
              },
              child: _appointmentTile(
                horaStr, cita.usuario, cita.servicio,
                isOccupied: true,
                showDelete: estaSeleccionada,
              ),
            );
          },
        );
      },
    );
  }

  // --- DIÁLOGOS (NUEVA CITA Y FILTRO) ---
  void _mostrarDialogoNuevaCita(String hora) {
    _servicioFiltroSeleccionado = _serviciosDisponibles[1]; // Reset a primer servicio real
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Cita a las $hora", style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Cliente')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _servicioFiltroSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo de Servicio'),
                items: _serviciosDisponibles.where((s) => s != 'Todos').map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDialogState(() => _servicioFiltroSeleccionado = val!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () { _nombreController.clear(); Navigator.pop(context); }, child: const Text("CANCELAR", style: TextStyle(color: Colors.red))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.black),
              onPressed: () async {
                final partes = hora.split(':');
                final fechaCompleta = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day, int.parse(partes[0]), int.parse(partes[1])).toUtc();

                await _citaService.crearCita(Cita(
                  fechaHora: fechaCompleta,
                  usuario: _nombreController.text,
                  servicio: _servicioFiltroSeleccionado,
                  precio: 25,
                ));

                setState(() => _anadiendoCita = false);
                _nombreController.clear();
                if (mounted) Navigator.pop(context);
              },
              child: const Text("ACEPTAR", style: TextStyle(color: AppStyles.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoFiltro() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Filtrar Citas", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _filtroNombreController,
                decoration: const InputDecoration(labelText: 'Nombre del Cliente', prefixIcon: Icon(Icons.person_search)),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _servicioFiltroSeleccionado,
                items: _serviciosDisponibles.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setDialogState(() => _servicioFiltroSeleccionado = val!),
                decoration: const InputDecoration(labelText: 'Servicio', prefixIcon: Icon(Icons.content_cut)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filtroNombre = null; _filtroServicio = null;
                  _filtroNombreController.clear(); _servicioFiltroSeleccionado = 'Todos';
                });
                Navigator.pop(context);
              },
              child: const Text("LIMPIAR"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppStyles.black),
              onPressed: () {
                setState(() {
                  _filtroNombre = _filtroNombreController.text.isEmpty ? null : _filtroNombreController.text;
                  _filtroServicio = (_servicioFiltroSeleccionado == 'Todos') ? null : _servicioFiltroSeleccionado;
                });
                Navigator.pop(context);
              },
              child: const Text("APLICAR", style: TextStyle(color: AppStyles.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- BOTONES Y UI ---
  Widget _buildBottomButtons(bool enProceso) {
    return Padding(
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
              onPressed: (_indiceCitaSeleccionada != null && !enProceso) ? () => setState(() => _editandoCita = true) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (_indiceCitaSeleccionada != null && !enProceso) ? AppStyles.black : Colors.grey,
              ).merge(AppStyles.botonPrincipal),
              child: Text(enProceso ? '---' : 'Editar'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableHoursList() {
    final List<String> horas = _turnoSeleccionado == 'MAÑANA' ? ['09:00', '10:30', '12:00'] : ['16:30', '18:30', '20:00'];
    return ListView.builder(
      itemCount: horas.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => _anadiendoCita ? _mostrarDialogoNuevaCita(horas[index]) : setState(() { _editandoCita = false; _indiceCitaSeleccionada = null; }),
        child: _appointmentTile(horas[index], "Disponible", "", isOccupied: false),
      ),
    );
  }

  Widget _buildShiftButton(String turno) {
    bool isSelected = _turnoSeleccionado == turno;
    return GestureDetector(
      onTap: () { if (!_editandoCita && !_anadiendoCita) setState(() { _turnoSeleccionado = turno; _indiceCitaSeleccionada = null; }); },
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

  Widget _appointmentTile(String time, String client, String service, {required bool isOccupied, bool showDelete = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(color: isOccupied && !showDelete ? AppStyles.offWhite : Colors.transparent, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(border: Border.all(color: isOccupied ? AppStyles.black : Colors.green), borderRadius: BorderRadius.circular(8)),
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(client, style: TextStyle(fontSize: 16, color: isOccupied ? AppStyles.black : AppStyles.grey, fontWeight: isOccupied ? FontWeight.bold : FontWeight.normal))),
          if (showDelete) const Icon(Icons.delete_outline, color: Colors.red, size: 26)
          else if (isOccupied) Text(service, style: const TextStyle(fontSize: 12, color: AppStyles.grey)),
        ],
      ),
    );
  }
}