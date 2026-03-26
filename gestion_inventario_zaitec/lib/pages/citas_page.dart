import 'package:flutter/material.dart';
import 'package:gestion_inventario_zaitec/Firebase/FirebaseManager.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Asegúrate de tener esta importación
import '../styles.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- VARIABLES DE ESTADO ---
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  String _turnoSeleccionado = 'MAÑANA';
  int? _indiceCitaSeleccionada;
  bool _editandoCita = false;
  bool _anadiendoCita = false;

  // Variables para el StreamBuilder (Filtrado Real)
  String? _filtroNombre;
  String? _filtroServicio;

  // Controladores
  final TextEditingController _filtroNombreController = TextEditingController();
  final TextEditingController _filtroServicioController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();

  final List<String> _serviciosDisponibles = [
    'Todos',
    'Corte',
    'Corte + barba',
    'Barba',
    'Tinte',
    'Lavado',
  ];

  String _servicioFiltroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _filtroNombreController.dispose();
    _filtroServicioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool enProceso = _editandoCita || _anadiendoCita;
    bool hayFiltros = _filtroNombre != null || _filtroServicio != null;

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
          IconButton(
            icon: Icon(Icons.filter_list, color: hayFiltros ? Colors.orange : AppStyles.black),
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
                      backgroundColor: (_indiceCitaSeleccionada != null && !enProceso)
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

  // --- LISTA CON STREAMBUILDER
  Widget _buildAppointmentsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseManager().obtenerCitasPeluquero(
        usuario: _filtroNombre,
        servicio: _filtroServicio,
        fechaHora: _selectedDay,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text("Error al cargar citas"));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppStyles.black));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text("No hay citas"));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            
            // Formatear hora desde Timestamp
            final DateTime fecha = (data['Fecha y Hora'] as Timestamp).toDate();
            final String horaStr = "${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";

            bool estaSeleccionada = _indiceCitaSeleccionada == index;

            return InkWell(
              onTap: () => setState(() => _indiceCitaSeleccionada = estaSeleccionada ? null : index),
              child: _appointmentTile(
                horaStr,
                data['Usuario'] ?? 'Sin nombre',
                data['Servicio'] ?? '',
                isOccupied: true,
                showDelete: estaSeleccionada,
              ),
            );
          },
        );
      },
    );
  }

  // --- DIÁLOGO DE FILTRO ---
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
                decoration: const InputDecoration(
                  labelText: 'Nombre del Cliente',
                  prefixIcon: Icon(Icons.person_search),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _servicioFiltroSeleccionado,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Servicio',
                  prefixIcon: Icon(Icons.content_cut),
                ),
                items: _serviciosDisponibles.map((String servicio) {
                  return DropdownMenuItem<String>(value: servicio, child: Text(servicio));
                }).toList(),
                onChanged: (nuevoValor) {
                  setDialogState(() => _servicioFiltroSeleccionado = nuevoValor!);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _filtroNombreController.clear();
                  _servicioFiltroSeleccionado = 'Todos';
                  _filtroNombre = null;
                  _filtroServicio = null;
                });
                Navigator.pop(context);
              },
              child: const Text("LIMPIAR", style: TextStyle(color: Colors.grey)),
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

  // WIDGETS DE APOYO
  Widget _buildAvailableHoursList() {
    final List<String> horasLibres = _turnoSeleccionado == 'MAÑANA' ? ['09:00', '10:30', '12:00'] : ['16:30', '18:30', '20:00'];
    return ListView.builder(
      itemCount: horasLibres.length,
      itemBuilder: (context, index) => InkWell(
        onTap: () => _anadiendoCita ? _mostrarDialogoNuevaCita(horasLibres[index]) : setState(() { _editandoCita = false; _indiceCitaSeleccionada = null; }),
        child: _appointmentTile(horasLibres[index], "Disponible", "", isOccupied: false),
      ),
    );
  }

  //DIÁLOGO DE NUEVA CITA
  void _mostrarDialogoNuevaCita(String hora) {
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
              onPressed: () { setState(() => _anadiendoCita = false); _nombreController.clear(); Navigator.pop(context); },
              child: const Text("ACEPTAR", style: TextStyle(color: AppStyles.white)),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE APOYO ---
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

  // --- WIDGET DE CITA (OCUPADA O LIBRE) ---
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