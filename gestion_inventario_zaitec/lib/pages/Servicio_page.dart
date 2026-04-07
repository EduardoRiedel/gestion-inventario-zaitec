import 'package:flutter/material.dart';
import 'menu_page.dart';
 
// Modelo de datos para un servicio, como una clase POJO en Java
class Servicio {
  final String nombre;
  final int duracionMinutos;
  final String descripcion;
  final double precio;
 
  const Servicio({
    required this.nombre,
    required this.duracionMinutos,
    required this.descripcion,
    required this.precio,
  });
}
 
class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
 
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}
 
class _ServicesPageState extends State<ServicesPage> {
 
  // Lista de servicios, como un ArrayList<Servicio> en Java
  final List<Servicio> _servicios = const [
    Servicio(
      nombre: 'Corte de pelo',
      duracionMinutos: 40,
      descripcion: 'Este servicio incluye lavado de cabeza',
      precio: 12,
    ),
    Servicio(
      nombre: 'Corte de pelo + barba',
      duracionMinutos: 45,
      descripcion: 'Realizaremos el corte de pelo y posteriormente un arreglo de la barba a maquina',
      precio: 15,
    ),
    Servicio(
      nombre: 'Solo degradado',
      duracionMinutos: 20,
      descripcion: 'Este servicio solo incluye degradado, no parte superior',
      precio: 8,
    ),
  ];
 
  void _editarServicio(Servicio servicio) {
    // Aquí iría la lógica para editar el servicio
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editando: ${servicio.nombre}')),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
 
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEEEEE),
        elevation: 0,
        automaticallyImplyLeading: false,
       
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87, size: 28),
            onPressed: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuPage()), //Aqui debe ir la pagina principal no esta 
                    );
            },
          ),
        ],
      ),
 
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
 
            const SizedBox(height: 16),
 
            // Título de la página
            const Text(
              'Servicios',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
 
            const SizedBox(height: 24),
 
            // Lista de tarjetas de servicios.
            // Expanded ocupa el espacio restante de la pantalla,
            // como layout_weight="1" en Android.
            Expanded(
              child: ListView.separated(
                // ListView.separated es como un RecyclerView en Android.
                // Muestra una lista de elementos con un separador entre ellos.
                itemCount: _servicios.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  // itemBuilder se llama por cada elemento, como onBindViewHolder en Android
                  return _ServicioCard(
                    servicio: _servicios[index],
                    onEditar: () => _editarServicio(_servicios[index]),
                  );
                },
              ),
            ),
 
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
 
// Widget separado para la tarjeta de cada servicio.
// En Android sería el layout XML de cada item del RecyclerView.
class _ServicioCard extends StatelessWidget {
  final Servicio servicio;
  final VoidCallback onEditar;
 
  const _ServicioCard({
    required this.servicio,
    required this.onEditar,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IntrinsicHeight(
        // IntrinsicHeight hace que todos los hijos del Row tengan la misma altura,
        // necesario para que la barra negra izquierda ocupe toda la altura de la tarjeta.
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
 
            // Barra negra decorativa en el lado izquierdo de la tarjeta
            Container(
              width: 5,
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
 
            // Contenido principal de la tarjeta
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
 
                        // Nombre del servicio
                        Text(
                          servicio.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
 
                        // Botón "Editar"
                        ElevatedButton(
                          onPressed: onEditar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Editar',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
 
                    const SizedBox(height: 2),
 
                    // Duración del servicio
                    Text(
                      '${servicio.duracionMinutos} min',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
 
                    const SizedBox(height: 8),
 
                    // Descripción del servicio
                    Text(
                      servicio.descripcion,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
 
                    const SizedBox(height: 8),
 
                    // Precio del servicio
                    Text(
                      '${servicio.precio.toStringAsFixed(0)} €',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}