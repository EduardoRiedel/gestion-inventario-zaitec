import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';



import 'package:gestion_inventario_zaitec/FirebaseManager.dart'; 

void main() {
  // Inicializa el enlace del test de integración
  final IntegrationTestWidgetsFlutterBinding binding = 
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  

  group('Pruebas Reales de Firebase', () {
    
    testWidgets("Debe crear una cita en Firebase", (WidgetTester tester) async {
      // Inicializamos Firebase
      try {
        await Firebase.initializeApp();
        print("Firebase inicializado correctamente");
      } catch (e) {
        print("Error al inicializar Firebase: $e");
      }

      final fm = FirebaseManager();

      print("🚀 Enviando datos a Firebase...");
      
      await fm.crearNuevaCita(
        servicio: "bigote",
        precio: "6",
        usuario: "Ivan Test Real",
        fechaElegida: DateTime.now(),
      );

      print("Test finalizado con éxito.");
    });
    // --- ACCIÓN: EDITAR ---
    testWidgets("Debe editar una cita existente", (WidgetTester tester) async {
      await Firebase.initializeApp();
      final fm = FirebaseManager();

      // 1. VE A FIREBASE Y COPIA UN ID QUE YA EXISTA (ej: N4GxlNLhnxqcBGULzEPa)
      String idParaEditar = "N4GxlNLhnxqcBGULzEPa"; 

      print("🛠️ Iniciando test de EDICIÓN para el ID: $idParaEditar");

      await fm.editarCita(
        id: idParaEditar,
        servicio: "Corte y Lavado (Editado)",
        precio: "35",
        usuario: "Ivan Cliente Editado",
        fecha: DateTime.now(),
      );

      print("Edición completada en Firebase.");
    });

    // --- ACCIÓN: ELIMINAR ---
    testWidgets("Debe eliminar una cita de la base de datos", (WidgetTester tester) async {
      await Firebase.initializeApp();
      final fm = FirebaseManager();

      // 2. COPIA OTRO ID QUE QUIERAS BORRAR
      String idParaBorrar = "0llhGDcagt3VoBli2R1P"; 

      print("🗑️ Iniciando test de ELIMINACIÓN para el ID: $idParaBorrar");

      await fm.eliminarCita(id: idParaBorrar);

      print("Cita eliminada correctamente de la nube.");
    });

  });
  
}