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
use MatrizDispersa;

# Instancias Globales
my $inventario = ListaDoble->new();
my $proveedores = ListaCircularProveedores->new();
my $solicitudes = ListaSolicitudes->new(); 
my $matriz = MatrizDispersa->new();


sub limpiar_pantalla {
    system($^O eq 'MSWin32' ? 'cls' : 'clear');
}


# --- DATOS DE USUARIOS (SIMULADOS) ---
# Hash: Usuario => Contraseña
my %credenciales_dept = (
    "UCI"        => "1234",
    "URGENCIAS"  => "1111",
    "PEDIATRIA"  => "2222",
    "ENFERMERIA" => "3333"
);

my %credenciales_admin = (
    "admin" => "admin123"
);

# --- MENU DE INICIO 
# --- DATOS DE USUARIOS (SIMULADOS) ---
# Hash: Usuario => Contraseña      
my %credenciales_dept = (
    "UCI"        => "1234",
    "URGENCIAS"  => "1111",
    "PEDIATRIA"  => "2222",
    "ENFERMERIA" => "3333"
);

my %credenciales_admin = (
    "admin" => "admin123"
);

# --- MENU DE INICIO (LOGIN REAL) ---
sub inicio {
    while (1) {
        limpiar_pantalla();
        print "\n=== BIENVENIDO A EDD MedTrack ===\n";
        print "1. Iniciar Sesion (Administrador)\n";
        print "2. Iniciar Sesion (Departamento)\n";
        print "3. Salir del Sistema\n";
        print "Seleccione: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) { 
            if (login_admin()) {
                menu_admin(); 
            }
        }
        elsif ($op == 2) { 
            # Capturamos el departamento que inició sesión
            my $depto_logueado = login_usuario();
            if ($depto_logueado) {
                menu_usuario($depto_logueado); 
            }
        }
        elsif ($op == 3) { exit; }
        else {
            print "Opcion no valida. Presione Enter..."; <STDIN>;
        }
    }
}

sub login_admin {
    print "\n--- LOGIN ADMINISTRADOR ---\n";
    print "Usuario: "; my $u = <STDIN>; chomp($u);
    print "Password: "; my $p = <STDIN>; chomp($p);
    
    if (exists $credenciales_admin{$u} && $credenciales_admin{$u} eq $p) {
        print "Acceso Concedido. Bienvenido Admin.\n";
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
    # Convertir a mayúsculas para estandarizar
    $u = uc($u); 
    
    print "Password: "; my $p = <STDIN>; chomp($p);
    
    if (exists $credenciales_dept{$u} && $credenciales_dept{$u} eq $p) {
        print "Acceso Concedido. Bienvenido $u.\n";
        sleep(1);
        return $u; # Retornamos el nombre del departamento
    } else {
        print "ERROR: Departamento no existe o password incorrecto.\n";
        sleep(1);
        return 0;
    }
}

# --- ROL: USUARIO DEPARTAMENTO ---
sub menu_usuario {
    my ($nombre_depto) = @_; # Recibimos el nombre del depto logueado
    
    my $salir = 0;
    while (!$salir) {
        limpiar_pantalla();
        print "\n--- PANEL DEPARTAMENTO: $nombre_depto ---\n"; # Mostrar nombre
        print "1. Crear Solicitud de Reabastecimiento\n";
        print "2. Cerrar Sesion\n";
        print "Opcion: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            # Ya no pedimos el departamento, usamos el del login
            print "Codigo Medicamento: "; my $cod = <STDIN>; chomp($cod);
            print "Cantidad Requerida: "; my $cant = <STDIN>; chomp($cant);
            print "Prioridad (Alta/Baja): "; my $prio = <STDIN>; chomp($prio);
            
            $solicitudes->crear_solicitud(
                departamento => $nombre_depto, # Usamos la variable
                codigo_med   => $cod,
                cantidad     => $cant,
                prioridad    => $prio
            );
            print "Presione Enter para continuar..."; <STDIN>;
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

        CargaArchivos::cargar_medicamentos($inventario, $archivo);

        my $actual = $inventario->primero;
            while (defined $actual) {
                # Insertamos: Medicamento, Laboratorio, Precio
                $matriz->insertar_elemento(
                    $actual->nombre,       # Fila
                    $actual->laboratorio,  # Columna
                    $actual->precio        # Valor
                );
                $actual = $actual->siguiente;
            }
            print "Matriz dispersa actualizada con precios.\n";

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