package ListaDobleCircularProveedores;
use strict;
use warnings;
use lib '../Nodos';
use NodoProveedor;
use NodoEntrega;

sub new {
    my ($class) = @_;
    my $self = {
        primero => undef,
        ultimo  => undef,
        size    => 0
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{primero}) ? 1 : 0;
}

# --- 1. INSERTAR PROVEEDOR ---
sub insertar_proveedor {
    my ($self, %args) = @_;
    
    # Validar si ya existe
    if (defined $self->buscar_proveedor($args{nit})) {
        print "Proveedor con NIT '$args{nit}' ya existe. Ignorando inserción.\n";
        return;
    }

    my $nuevo = NodoProveedor->new(%args);

    if ($self->is_empty()) {
        $self->{primero} = $nuevo;
        $self->{ultimo}  = $nuevo;
        
        # Circularidad sobre sí mismo
        $nuevo->set_siguiente($nuevo);
        $nuevo->set_anterior($nuevo);
    } else {
        my $primero = $self->{primero};
        my $ultimo  = $self->{ultimo};
        
        # Enlazar nuevo nodo al final
        $ultimo->set_siguiente($nuevo);
        $nuevo->set_anterior($ultimo);
        
        # Cerrar el círculo doble
        $nuevo->set_siguiente($primero);
        $primero->set_anterior($nuevo);
        
        # Actualizar puntero último
        $self->{ultimo} = $nuevo;
    }
    $self->{size}++;
    print "Proveedor '" . $args{nombre} . "' registrado exitosamente.\n";
}

# --- 2. BUSCAR PROVEEDOR ---
sub buscar_proveedor {
    my ($self, $nit) = @_;
    return undef if $self->is_empty();
    
    my $actual = $self->{primero};
    do {
        if ($actual->get_nit() eq $nit) {
            return $actual;
        }
        $actual = $actual->get_siguiente();
    } while ($actual != $self->{primero}); # Hasta dar la vuelta
    
    return undef;
}

# --- 3. AGREGAR ENTREGA (Factura interna) ---
sub agregar_entrega {
    my ($self, $nit_proveedor, %datos_entrega) = @_;
    
    my $proveedor = $self->buscar_proveedor($nit_proveedor);
    
    unless (defined $proveedor) {
        die "Proveedor con NIT $nit_proveedor no encontrado.";
    }
    
    my $nueva_entrega = NodoEntrega->new(%datos_entrega);
    
    # Insertar al inicio de la sub-lista (Como una Pila / LIFO)
    my $cabeza_entregas = $proveedor->get_primera_entrega();
    if (defined $cabeza_entregas) {
        $nueva_entrega->set_siguiente($cabeza_entregas);
    }
    $proveedor->set_primera_entrega($nueva_entrega);
}

# --- 4. RECORRIDO PARA TABLAS GTK ---
sub obtener_lista_proveedores {
    my ($self) = @_;
    my @resultado;
    return \@resultado if $self->is_empty();
    
    my $actual = $self->{primero};
    do {
        push @resultado, $actual;
        $actual = $actual->get_siguiente();
    } while ($actual != $self->{primero});
    
    return \@resultado;
}

1;