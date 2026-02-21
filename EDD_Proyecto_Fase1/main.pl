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
        #limpiar_pantalla();
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
        print "1. CONSULTAR DISPONIBILIDAD\n";
        print "2. Crear Solicitud de Reabastecimiento\n";
        print "3. Ver Historial de Solicitudes\n";
        print "4. Cerrar Sesion\n";
        print "Opcion: ";
        my $op = <STDIN>; chomp($op);
        
        if ($op == 1) {
            consultar_disponibilidad();
        }
        elsif ($op == 2) {
            print "Codigo Medicamento: "; my $cod = <STDIN>; chomp($cod);
            if ($inventario->buscar($cod)) {
                print "Cantidad: "; my $cant = <STDIN>; chomp($cant);
                print "Prioridad (Alta/Baja): "; my $prio = <STDIN>; chomp($prio);
                print "Fecha (YYYY-MM-DD): "; my $fec = <STDIN>; chomp($fec); # <--- PEDIMOS FECHA
                
                $solicitudes->crear_solicitud(
                    departamento => $nombre_depto,
                    codigo_med   => $cod,
                    cantidad     => $cant,
                    prioridad    => $prio,
                    fecha        => $fec  # <--- GUARDAMOS FECHA
                );
            } else { print "Error: Medicamento no existe.\n"; }
            print "Enter..."; <STDIN>;
        }
        elsif ($op == 3) {
            # --- HISTORIAL COMPLETO (REQUISITO 4) ---
            print "\n--- HISTORIAL DE SOLICITUDES ($nombre_depto) ---\n";
            print "ID | Fecha      | Med    | Cant | Estado\n";
            print "---------------------------------------------\n";
            
            if (!$solicitudes->esta_vacia) {
                my $actual = $solicitudes->primero;
                do {
                    # Filtramos solo las de este departamento
                    if ($actual->departamento eq $nombre_depto) {
                        printf("%-3s| %-10s | %-6s | %-4s | %s\n", 
                            $actual->id, $actual->fecha, $actual->codigo_med, 
                            $actual->cantidad, $actual->estado);
                    }
                    $actual = $actual->siguiente;
                } while ($actual != $solicitudes->primero);
            }
            print "---------------------------------------------\n";
            print "Presione Enter..."; <STDIN>;
        }
        elsif ($op == 4) { $salir = 1; }
    }
}

# --- MENU ADMINISTRADOR ---
sub menu_admin {
    my $salir = 0;
    while (!$salir) {
       # limpiar_pantalla();
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
    print "\n--- PROCESAR SOLICITUDES PENDIENTES ---\n";
    
    if ($solicitudes->esta_vacia) {
        print "No hay solicitudes registradas.\nEnter..."; <STDIN>; return;
    }
    
    # 1. Mostrar SOLO las Pendientes
    my $hay_pendientes = 0;
    my $actual = $solicitudes->primero;
    do {
        if ($actual->estado eq 'Pendiente') {
            print "ID: " . $actual->id . " | Dept: " . $actual->departamento . 
                  " | Med: " . $actual->codigo_med . " | Cant: " . $actual->cantidad . "\n";
            $hay_pendientes = 1;
        }
        $actual = $actual->siguiente;
    } while ($actual != $solicitudes->primero);
    
    if (!$hay_pendientes) {
        print "No hay solicitudes pendientes de aprobar.\nEnter..."; <STDIN>; return;
    }
    
    print "\nID Solicitud a procesar (0 cancelar): ";
    my $id = <STDIN>; chomp($id);
    return if $id == 0;
    
    my $sol = $solicitudes->buscar($id);
    
    # Validar que exista y que sea Pendiente (para no re-aprobar viejas)
    unless ($sol && $sol->estado eq 'Pendiente') { 
        print "ID invalido o solicitud ya procesada.\nEnter..."; <STDIN>; return; 
    }
    
    print "1. APROBAR (Descontar Stock)\n2. RECHAZAR\nOpcion: ";
    my $acc = <STDIN>; chomp($acc);
    
    if ($acc == 1) {
        my $med = $inventario->buscar($sol->codigo_med);
        if ($med && $med->stock >= $sol->cantidad) {
            $med->stock($med->stock - $sol->cantidad);
            
            # CAMBIO DE ESTADO
            $sol->estado('Aprobada'); 
            
            print "Solicitud APROBADA. Stock restante: " . $med->stock . "\n";
        } else {
            print "ERROR: Stock insuficiente (" . ($med ? $med->stock : 0) . ").\n";
        }
    }
    elsif ($acc == 2) {
        # CAMBIO DE ESTADO 
        $sol->estado('Rechazada');
        print "Solicitud RECHAZADA.\n";
    }
    print "Enter..."; <STDIN>;
}

sub registrar_medicamento_manual {
    print "\n--- REGISTRO MANUAL DE MEDICAMENTO ---\n";
    print "Ingrese los datos del nuevo medicamento:\n";
    
    print "Codigo (ej: MED999): "; my $cod = <STDIN>; chomp($cod);
    # Validar duplicados
    if ($inventario->buscar($cod)) {
        print "ERROR: El codigo $cod ya existe en el inventario.\n";
        print "Presione Enter..."; <STDIN>;
        return;
    }

    print "Nombre Comercial: "; my $nom = <STDIN>; chomp($nom);
    print "Principio Activo: "; my $act = <STDIN>; chomp($act);
    print "Laboratorio: "; my $lab = <STDIN>; chomp($lab);
    print "Precio Unitario (Q): "; my $pre = <STDIN>; chomp($pre);
    print "Stock Inicial: "; my $stk = <STDIN>; chomp($stk);
    print "Fecha Vencimiento (YYYY-MM-DD): "; my $ven = <STDIN>; chomp($ven);
    print "Stock Minimo: "; my $min = <STDIN>; chomp($min);
    
    # 1. Insertar en Inventario (Lista Doble)
    $inventario->insertar(
        codigo           => $cod,
        nombre           => $nom,
        principio_activo => $act,
        laboratorio      => $lab,
        precio           => $pre,
        stock            => $stk,
        vencimiento      => $ven,
        minimo           => $min
    );
    
    # 2. Actualizar Matriz Dispersa (Sincronización)
    $matriz->insertar_elemento($nom, $lab, $pre);
    
    print "\n[EXITO] Medicamento registrado y matriz actualizada.\n";
    print "Presione Enter para continuar..."; <STDIN>;
}

sub consultar_disponibilidad {
    print "\n--- CONSULTA DE DISPONIBILIDAD ---\n";
    print "Ingrese Nombre o Codigo del medicamento: ";
    my $busqueda = <STDIN>; chomp($busqueda);
    
    # Recorrido secuencial para buscar coincidencias (Case Insensitive)
    my $actual = $inventario->primero;
    my $encontrado = 0;
    
    print "\nResultados de la busqueda:\n";
    print "--------------------------------------------------\n";
    
    while (defined $actual) {
        # Buscamos por Codigo exacto O por Nombre (conteniendo el texto)
        if ($actual->codigo eq $busqueda || $actual->nombre =~ /\Q$busqueda\E/i) {
            $encontrado = 1;
            print "MEDICAMENTO: " . $actual->nombre . " (" . $actual->codigo . ")\n";
            print " - Laboratorio: " . $actual->laboratorio . "\n";
            print " - Stock Disponible: " . $actual->stock . "\n";
            
            # Estado del Stock
            if ($actual->stock == 0) {
                print " - ESTADO: [AGOTADO] (Contacte al Admin)\n";
            } elsif ($actual->stock < $actual->minimo) {
                print " - ESTADO: [BAJO STOCK] (Reorden sugerida)\n";
            } else {
                print " - ESTADO: [DISPONIBLE]\n";
            }
            print "--------------------------------------------------\n";
        }
        $actual = $actual->siguiente;
    }
    
    if (!$encontrado) {
        print "No se encontraron medicamentos con ese criterio.\n";
    }
    print "\nPresione Enter para volver..."; <STDIN>;
}   