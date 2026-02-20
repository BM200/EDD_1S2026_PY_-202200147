package ListaCircularProveedores;

use strict;
use warnings;
use Moo;
use NodoProveedor;
use NodoEntrega;

# Punteros de la lista circular principal
has 'primero' => (is => 'rw', default => sub { undef });
has 'ultimo'  => (is => 'rw', default => sub { undef });

sub esta_vacia {
    my ($self) = @_;
    return !defined $self->primero;
}

# 1. Registrar Proveedor (Insertar en Lista Circular)
sub insertar_proveedor {
    my ($self, %args) = @_;
    
    my $nuevo = NodoProveedor->new(%args);
    
    if ($self->esta_vacia) {
        $self->primero($nuevo);
        $self->ultimo($nuevo);

        # Circularidad: El unico nodo se apunta a si mismo
        $nuevo->siguiente($nuevo);
    }
    else {
        # Insertar al final
        $self->ultimo->siguiente($nuevo);
        $nuevo->siguiente($self->primero); # Cerrar circulo
        $self->ultimo($nuevo);
    }
    print "Proveedor registrado: " . $nuevo->nombre . "\n";
}

# 2. Buscar Proveedor por NIT
sub buscar_proveedor {
    my ($self, $nit) = @_;
    return undef if $self->esta_vacia;
    
    my $actual = $self->primero;
    
    do {
        if ($actual->nit eq $nit) {
            return $actual;
        }
        $actual = $actual->siguiente;
    } while ($actual != $self->primero); # Detenerse al dar la vuelta completa
    
    return undef;
}

# 3. Registrar Entrega (Insertar en Lista Simple interna)
sub agregar_entrega {
    my ($self, $nit_proveedor, %datos_entrega) = @_;
    
    my $proveedor = $self->buscar_proveedor($nit_proveedor);
    
    unless ($proveedor) {
        print "Error: Proveedor con NIT $nit_proveedor no existe.\n";
        return 0;
    }
    
    # Crear nodo entrega
    my $nueva_entrega = NodoEntrega->new(%datos_entrega);
    
    # Insertar al inicio de la lista interna del proveedor (Pila o LIFO es mas facil)
    if (defined $proveedor->primera_entrega) {
        $nueva_entrega->siguiente($proveedor->primera_entrega);
    }
    $proveedor->primera_entrega($nueva_entrega);
    
    print "Entrega registrada para el proveedor " . $proveedor->nombre . "\n";
    return 1;
}

# 4. Imprimir para Debug
sub imprimir_consola {
    my ($self) = @_;
    return if $self->esta_vacia;
    
    print "\n--- Lista de Proveedores ---\n";
    my $actual = $self->primero;
    
    do {
        print "PROVEEDOR: " . $actual->nombre . " (NIT: " . $actual->nit . ")\n";
        
        # Imprimir sus entregas
        my $entrega = $actual->primera_entrega;
        while (defined $entrega) {
            print "   -> Entrega: " . $entrega->factura . " | Med: " . $entrega->codigo_med . "\n";
            $entrega = $entrega->siguiente;
        }
        
        $actual = $actual->siguiente;
    } while ($actual != $self->primero);
    print "----------------------------\n";
}

1;