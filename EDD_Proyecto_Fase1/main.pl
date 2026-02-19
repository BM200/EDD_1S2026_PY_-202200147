#!/usr/bin/perl
use strict;
use warnings;

# Rutas de librerías
use lib 'lib/Nodos';
use lib 'lib/Estructuras';
use lib 'lib/Utils';

# Imports
use ListaDoble;
use CargaArchivos;

# Instancia de la lista (Usando Moo)
my $inventario = ListaDoble->new();

sub limpiar_pantalla {
    system($^O eq 'MSWin32' ? 'cls' : 'clear');
}

sub menu_principal {
    my $opcion = 0;
    
    while ($opcion != 3) {
        print "\n=== SISTEMA EDD MedTrack ===\n";
        print "1. Cargar Inventario (CSV)\n";
        print "2. Mostrar Inventario Actual\n";
        print "3. Salir\n";
        print "Seleccione una opcion: ";
        
        $opcion = <STDIN>;
        chomp($opcion);

        if ($opcion == 1) {
            print "Ingrese ruta del archivo (Enter para default 'datos/medicamentos.csv'): ";
            my $archivo = <STDIN>;
            chomp($archivo);
            $archivo = "datos/medicamentos.csv" if $archivo eq "";
            
            # Llamada estática al cargador
            CargaArchivos::cargar_medicamentos($inventario, $archivo);
        }
        elsif ($opcion == 2) {
            $inventario->imprimir_consola();
        }
        elsif ($opcion == 3) {
            print "Saliendo...\n";
        }
        else {
            print "Opcion invalida.\n";
        }
    }
}

# Ejecución
limpiar_pantalla();
menu_principal();