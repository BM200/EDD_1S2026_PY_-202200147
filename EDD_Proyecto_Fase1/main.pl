#!/usr/bin/perl
use strict;
use warnings;

use lib 'lib/Nodos';
use lib 'lib/Estructuras';
use lib 'lib/Utils';

use ListaDoble;
use ListaCircularProveedores;
use ListaSolicitudes; # 
use CargaArchivos;
use Graphviz;

# Instancias Globales
my $inventario = ListaDoble->new();
my $proveedores = ListaCircularProveedores->new();
my $solicitudes = ListaSolicitudes->new(); #

sub limpiar_pantalla {
    system($^O eq 'MSWin32' ? 'cls' : 'clear');
}

# --- MENU DE INICIO 
sub inicio {
    while (1) {
        limpiar_pantalla();
        print "\n=== BIENVENIDO A EDD MedTrack ===\n";
        print "1. Ingresar como ADMINISTRADOR\n";
        print "2. Ingresar como DEPARTAMENTO (Enfermeria/Urgencias)\n";
        print "3. Salir del Sistema\n";
        print "Seleccione: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) { menu_admin(); }
        elsif ($op == 2) { menu_usuario(); }
        elsif ($op == 3) { exit; }
    }
}

# --- ROL: USUARIO DEPARTAMENTO ---
sub menu_usuario {
    my $salir = 0;
    while (!$salir) {
        print "\n--- PANEL DEPARTAMENTO ---\n";
        print "1. Crear Solicitud de Reabastecimiento\n";
        print "2. Volver al Inicio\n";
        print "Opcion: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            print "Departamento (ej: UCI): "; my $dept = <STDIN>; chomp($dept);
            print "Codigo Medicamento: "; my $cod = <STDIN>; chomp($cod);
            print "Cantidad Requerida: "; my $cant = <STDIN>; chomp($cant);
            print "Prioridad (Alta/Baja): "; my $prio = <STDIN>; chomp($prio);
            
            $solicitudes->crear_solicitud(
                departamento => $dept,
                codigo_med   => $cod,
                cantidad     => $cant,
                prioridad    => $prio
            );
        }
        elsif ($op == 2) { $salir = 1; }
    }
}

# --- ROL: ADMINISTRADOR ---

sub menu_admin {
    my $salir = 0;
    while (!$salir) {
        print "\n--- PANEL ADMINISTRADOR ---\n";
        print "1. Cargar Inventario (CSV)\n";
        print "2. Gestionar Proveedores\n";
        print "3. Registrar Entrega (Entrada de Stock)\n";
        print "4. ATENDER SOLICITUDES (Salida de Stock)\n"; 
        print "5. Ver Inventario\n";
        print "6. Generar Reportes\n";
        print "7. Cerrar Sesion\n";
        print "Opcion: ";
        
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            print "Ruta archivo: "; my $f = <STDIN>; chomp($f);
            $f = "datos/medicamentos.csv" if $f eq "";
            CargaArchivos::cargar_medicamentos($inventario, $f);
        }
        elsif ($op == 2) { menu_proveedores(); }
        elsif ($op == 3) { menu_entrega_prov(); }
        elsif ($op == 4) { menu_atender_solicitudes(); }
        elsif ($op == 5) { $inventario->imprimir_consola(); }
        elsif ($op == 6) {
            print "Generando reportes...\n";
            Graphviz::generar_reporte_inventario($inventario);
            Graphviz::generar_reporte_proveedores($proveedores);
            # Graphviz::generar_reporte_solicitudes($solicitudes); 
        }
        elsif ($op == 7) { $salir = 1; }
    }
}

# Submenú Proveedores 
sub menu_proveedores {
    print "1. Registrar / 2. Ver: "; my $op = <STDIN>; chomp($op);
    if ($op == 1) {
        print "NIT: "; my $n = <STDIN>; chomp($n);
        print "Nombre: "; my $no = <STDIN>; chomp($no);
        $proveedores->insertar_proveedor(nit=>$n, nombre=>$no);
    } elsif ($op == 2) { $proveedores->imprimir_consola(); }
}

# Submenú Entrega 
sub menu_entrega_prov {
    print "NIT Proveedor: "; my $nit = <STDIN>; chomp($nit);
    unless ($proveedores->buscar_proveedor($nit)) { print "No existe.\n"; return; }
    
    print "Cod Med: "; my $cod = <STDIN>; chomp($cod);
    my $med = $inventario->buscar($cod);
    unless ($med) { print "Med no existe.\n"; return; }
    
    print "Cantidad: "; my $c = <STDIN>; chomp($c);
    print "Factura: "; my $f = <STDIN>; chomp($f);
    
    $proveedores->agregar_entrega($nit, codigo_med=>$cod, cantidad=>$c, factura=>$f);
    $med->stock($med->stock + $c); # SUMA STOCK
    print "Stock aumentado.\n";
}

# --- LOGICA DE ATENDER SOLICITUDES (Salida de Stock) ---
sub menu_atender_solicitudes {
    $solicitudes->imprimir_consola();
    return if $solicitudes->esta_vacia;
    
    print "\nIngrese ID de solicitud a procesar (0 para cancelar): ";
    my $id = <STDIN>; chomp($id);
    return if $id == 0;
    
    my $sol = $solicitudes->buscar($id);
    unless ($sol) { print "ID no encontrado.\n"; return; }
    
    print "Accion: 1. Aprobar (Despachar) / 2. Rechazar: ";
    my $accion = <STDIN>; chomp($accion);
    
    if ($accion == 1) {
        # Verificar Stock
        my $med = $inventario->buscar($sol->codigo_med);
        if ($med && $med->stock >= $sol->cantidad) {
            $med->stock($med->stock - $sol->cantidad); # RESTA STOCK
            print "Solicitud Aprobada. Stock restante de " . $med->codigo . ": " . $med->stock . "\n";
            $solicitudes->eliminar($id);
        } else {
            print "ERROR: Stock insuficiente o medicamento no existe.\n";
        }
    }
    elsif ($accion == 2) {
        print "Solicitud Rechazada.\n";
        $solicitudes->eliminar($id);
    }
}

# Arrancar
inicio();