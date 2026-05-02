use strict;
use warnings;
use Gtk3 -init;

# Crear una ventana simple
my $window = Gtk3::Window->new('toplevel');
$window->set_title("Prueba GTK EDD MedTrack");
$window->set_default_size(300, 200);

# Al cerrar la ventana, terminar el programa
$window->signal_connect(destroy => sub { Gtk3::main_quit() });

# Agregar un botón
my $button = Gtk3::Button->new_with_label("¡GTK Funciona Correctamente!");
$button->signal_connect(clicked => sub { print "Boton presionado en consola\n" });
$window->add($button);

# Mostrar todo y arrancar
$window->show_all();
Gtk3::main();