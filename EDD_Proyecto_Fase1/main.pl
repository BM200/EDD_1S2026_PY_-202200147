#!/usr/bin/perl
use strict;
use warnings;

# --- RUTAS DE LIBRERÍAS ---
use lib 'lib/Nodos';
use lib 'lib/Estructuras';
use lib 'lib/Utils';

# --- IMPORTS ---
use ListaDoble;
use ListaCircularProveedores;
use ListaSolicitudes;
use MatrizDispersa;
use CargaArchivos;
use Graphviz;

# --- INSTANCIAS GLOBALES ---
my $inventario  = ListaDoble->new();
my $proveedores = ListaCircularProveedores->new();
my $solicitudes = ListaSolicitudes->new();
my $matriz      = MatrizDispersa->new();

# --- CREDENCIALES ---
my %credenciales_dept = (
    "UCI"        => "1234",
    "URGENCIAS"  => "1111",
    "PEDIATRIA"  => "2222",
    "ENFERMERIA" => "3333"
);

my %credenciales_admin = (
    "admin" => "admin123"
);

# --- UTILITARIOS ---
sub limpiar_pantalla {
    system($^O eq 'MSWin32' ? 'cls' : 'clear');
}

# --- FLUJO PRINCIPAL ---
inicio();

sub inicio {
    while (1) {
        limpiar_pantalla();
        print "\n=== BIENVENIDO A EDD MedTrack ===\n";
        print "1. Iniciar Sesion (Administrador)\n";
        print "2. Iniciar Sesion (Departamento)\n";
        print "3. Salir del Sistema\n";
        print "Seleccione: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op eq "1") { 
            if (login_admin()) {
                menu_admin(); 
            }
        }
        elsif ($op eq "2") { 
            my $depto = login_usuario();
            if ($depto) {
                menu_usuario($depto); 
            }
        }
        elsif ($op eq "3") { 
            print "Cerrando sistema...\n";
            exit; 
        }
    }
}

# --- LOGINS ---
sub login_admin {
    print "\n--- LOGIN ADMINISTRADOR ---\n";
    print "Usuario (admin): "; my $u = <STDIN>; chomp($u);
    print "Password (admin123): "; my $p = <STDIN>; chomp($p);
    
    if (exists $credenciales_admin{$u} && $credenciales_admin{$u} eq $p) {
        print "Acceso Concedido.\n";
        sleep(1);
        return 1;
    } else {
        print "ERROR: Credenciales incorrectas.\n";
        sleep(1);
        return 0;
    }
}

sub login_usuario {
    print "\n--- LOGIN DEPARTAMENTAL ---\n";
    print "Codigo Departamento (ej: UCI): "; my $u = <STDIN>; chomp($u);
    $u = uc($u); 
    print "Password (1234): "; my $p = <STDIN>; chomp($p);
    
    if (exists $credenciales_dept{$u} && $credenciales_dept{$u} eq $p) {
        print "Acceso Concedido a $u.\n";
        sleep(1);
        return $u;
    } else {
        print "ERROR: Credenciales incorrectas.\n";
        sleep(1);
        return 0;
    }
}

# --- MENU USUARIO (DEPARTAMENTO) ---
sub menu_usuario {
    my ($nombre_depto) = @_;
    my $salir = 0;
    
    while (!$salir) {
        limpiar_pantalla();
        print "\n--- PANEL DEPARTAMENTO: $nombre_depto ---\n";
        print "1. Crear Solicitud de Reabastecimiento\n";
        print "2. Ver Mis Solicitudes (Opcional)\n";
        print "3. Cerrar Sesion\n";
        print "Opcion: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            print "Codigo Medicamento: "; my $cod = <STDIN>; chomp($cod);
            # Validar que exista el med (Opcional pero recomendado)
            if ($inventario->buscar($cod)) {
                print "Cantidad Requerida: "; my $cant = <STDIN>; chomp($cant);
                print "Prioridad (Alta/Baja): "; my $prio = <STDIN>; chomp($prio);
                
                $solicitudes->crear_solicitud(
                    departamento => $nombre_depto,
                    codigo_med   => $cod,
                    cantidad     => $cant,
                    prioridad    => $prio
                );
            } else {
                print "Error: El medicamento no existe en el catalogo.\n";
            }
            print "Presione Enter..."; <STDIN>;
        }
        elsif ($op == 2) {
            $solicitudes->imprimir_consola(); # Muestra todas por ahora
            print "Presione Enter..."; <STDIN>;
        }
        elsif ($op == 3) { $salir = 1; }
    }
}

# --- MENU ADMINISTRADOR ---
sub menu_admin {
    my $salir = 0;
    while (!$salir) {
        limpiar_pantalla();
        print "\n--- PANEL ADMINISTRADOR ---\n";
        print "1. Cargar Inventario (CSV)\n";
        print "2. Gestionar Proveedores\n";
        print "3. Registrar Entrega (Entrada Stock)\n";
        print "4. ATENDER SOLICITUDES (Salida Stock)\n";
        print "5. Ver Inventario / Matriz\n";
        print "6. Generar Reportes Graficos\n";
        print "7. Cerrar Sesion\n";
        print "Opcion: ";
        
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            print "Ruta archivo: "; 
            my $archivo = <STDIN>; # Declaramos $archivo aqui con 'my'
            chomp($archivo);
            $archivo = "datos/medicamentos.csv" if $archivo eq "";
            
            # Cargar Lista Doble
            CargaArchivos::cargar_medicamentos($inventario, $archivo);
            
            # Cargar Matriz Dispersa automáticamente
            my $actual = $inventario->primero;
            while (defined $actual) {
                $matriz->insertar_elemento(
                    $actual->nombre,       # Fila (Med)
                    $actual->laboratorio,  # Columna (Lab)
                    $actual->precio        # Valor
                );
                $actual = $actual->siguiente;
            }
            print "Matriz de Precios actualizada correctamente.\n";
            print "Presione Enter..."; <STDIN>;
        }
        elsif ($op == 2) { 
            menu_proveedores(); 
        }
        elsif ($op == 3) { 
            menu_entrega_prov(); 
        }
        elsif ($op == 4) { 
            menu_atender_solicitudes(); 
        }
        elsif ($op == 5) {
            print "\n1. Lista Lineal (Inventario)\n2. Matriz Dispersa (Precios)\nEleccion: ";
            my $sel = <STDIN>; chomp($sel);
            if ($sel == 1) { $inventario->imprimir_consola(); }
            elsif ($sel == 2) { $matriz->imprimir_consola(); }
            print "Enter para volver..."; <STDIN>;
        }
        elsif ($op == 6) {
            print "Generando reportes...\n";
            Graphviz::generar_reporte_inventario($inventario);
            Graphviz::generar_reporte_proveedores($proveedores);
            Graphviz::generar_reporte_solicitudes($solicitudes);
            Graphviz::generar_reporte_matriz($matriz); 
            print "Reportes generados en carpeta /reportes.\n";
            print "Enter para volver..."; <STDIN>;
        }
        elsif ($op == 7) { $salir = 1; }
    }
}

# --- SUBMENUS ---

sub menu_proveedores {
    print "\n--- Proveedores ---\n";
    print "1. Registrar Nuevo\n2. Ver Lista\nOpcion: "; 
    my $op = <STDIN>; chomp($op);
    
    if ($op == 1) {
        print "NIT: "; my $n = <STDIN>; chomp($n);
        print "Nombre: "; my $no = <STDIN>; chomp($no);
        $proveedores->insertar_proveedor(nit=>$n, nombre=>$no);
    } 
    elsif ($op == 2) { 
        $proveedores->imprimir_consola(); 
    }
    print "Enter..."; <STDIN>;
}

sub menu_entrega_prov {
    print "\n--- Registrar Entrada ---\n";
    print "NIT Proveedor: "; my $nit = <STDIN>; chomp($nit);
    unless ($proveedores->buscar_proveedor($nit)) { print "Proveedor no existe.\nEnter..."; <STDIN>; return; }
    
    print "Cod Med: "; my $cod = <STDIN>; chomp($cod);
    my $med = $inventario->buscar($cod);
    unless ($med) { print "Med no existe en inventario.\nEnter..."; <STDIN>; return; }
    
    print "Cantidad: "; my $c = <STDIN>; chomp($c);
    print "Factura: "; my $f = <STDIN>; chomp($f);
    print "Fecha: "; my $d = <STDIN>; chomp($d);
    
    $proveedores->agregar_entrega($nit, codigo_med=>$cod, cantidad=>$c, factura=>$f, fecha=>$d);
    $med->stock($med->stock + $c);
    print "Stock actualizado: " . $med->stock . "\n";
    print "Enter..."; <STDIN>;
}

sub menu_atender_solicitudes {
    limpiar_pantalla();
    $solicitudes->imprimir_consola();
    return if $solicitudes->esta_vacia;
    
    print "\nID Solicitud a procesar (0 cancelar): ";
    my $id = <STDIN>; chomp($id);
    return if $id == 0;
    
    my $sol = $solicitudes->buscar($id);
    unless ($sol) { print "ID invalido.\nEnter..."; <STDIN>; return; }
    
    print "1. APROBAR (Descontar Stock)\n2. RECHAZAR\nOpcion: ";
    my $acc = <STDIN>; chomp($acc);
    
    if ($acc == 1) {
        my $med = $inventario->buscar($sol->codigo_med);
        if ($med && $med->stock >= $sol->cantidad) {
            $med->stock($med->stock - $sol->cantidad);
            print "Aprobada. Stock restante: " . $med->stock . "\n";
            $solicitudes->eliminar($id);
        } else {
            print "ERROR: Stock insuficiente (" . ($med ? $med->stock : 0) . ").\n";
        }
    }
    elsif ($acc == 2) {
        print "Rechazada.\n";
        $solicitudes->eliminar($id);
    }
    print "Enter..."; <STDIN>;
}