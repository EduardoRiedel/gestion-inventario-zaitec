import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';



import 'package:gestion_inventario_zaitec/Firebase/FirebaseManager.dart'; 

void main() {
  // Inicializar el enlace del test de integración
  final IntegrationTestWidgetsFlutterBinding binding = 
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  

  group('Pruebas Reales de Firebase', () {
    
    testWidgets("Debe crear una cita en Firebase", (WidgetTester tester) async {
      // Inicializar Firebase
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
    // editar
    testWidgets("Debe editar una cita existente", (WidgetTester tester) async {
      await Firebase.initializeApp();
      final fm = FirebaseManager();

      // id a editar
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

    // eliminar
    testWidgets("Debe eliminar una cita de la base de datos", (WidgetTester tester) async {
      await Firebase.initializeApp();
      final fm = FirebaseManager();

       // id a borrar
      String idParaBorrar = "0llhGDcagt3VoBli2R1P"; 

      print("🗑️ Iniciando test de ELIMINACIÓN para el ID: $idParaBorrar");

      await fm.eliminarCita(id: idParaBorrar);

      print("Cita eliminada correctamente de la nube.");
    });

  });
  
}