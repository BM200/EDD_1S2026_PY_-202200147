package ListaSolicitudes;
use strict;
use warnings;
use Moo;
use NodoSolicitud;

has 'primero' => (is => 'rw', default => sub { undef });
has 'ultimo' => (is => 'rw', default => sub { undef });
has 'contador_id' => (is => 'rw', default => sub { 1 });  #esto es autoincrementable. 

sub esta_vacia {
    my ($self) = @_;
    return !defined $self->primero;
}

#1.crear solicitud (Insertar al final)
sub crear_solicitud {
    my ($self, %args) = @_;
    
    $args{id} = $self->contador_id;
    $self->contador_id($self->contador_id + 1);
    
    # El estado por defecto es 'Pendiente' gracias a Moo en el Nodo
    
    my $nuevo = NodoSolicitud->new(%args);
    
    if ($self->esta_vacia) {
        $self->primero($nuevo);
        $self->ultimo($nuevo);
        $nuevo->siguiente($nuevo);
        $nuevo->anterior($nuevo);
    }
    else {
        my $ultimo = $self->ultimo;
        my $primero = $self->primero;
        
        $ultimo->siguiente($nuevo);
        $nuevo->anterior($ultimo);
        
        $nuevo->siguiente($primero);
        $primero->anterior($nuevo);
        
        $self->ultimo($nuevo);
    }
    print "Solicitud #$args{id} creada (Estado: Pendiente).\n";
}

# 2. Buscar Solicitud por ID
sub buscar {
    my ($self, $id) = @_;
    return undef if $self->esta_vacia;
    
    my $actual = $self->primero;
    do {
        if ($actual->id == $id) {
            return $actual;
        }
        $actual = $actual->siguiente;
    } while ($actual != $self->primero);
    
    return undef;
}

# 3. Eliminar Solicitud (Se usa al Aprobar o Rechazar)
sub eliminar {
    my ($self, $id) = @_;
    my $nodo = $self->buscar($id);
    
    unless ($nodo) {
        print "Error: Solicitud ID $id no encontrada.\n";
        return 0;
    }
    
    # Caso: Único nodo
    if ($nodo == $nodo->siguiente) {
        $self->primero(undef);
        $self->ultimo(undef);
    }
    else {
        my $ante = $nodo->anterior;
        my $sig  = $nodo->siguiente;
        
        # Saltar el nodo a eliminar
        $ante->siguiente($sig);
        $sig->anterior($ante);
        
        # Si borramos el primero o el último, movemos los punteros de la lista
        if ($nodo == $self->primero) {
            $self->primero($sig);
        }
        if ($nodo == $self->ultimo) {
            $self->ultimo($ante);
        }
    }
    return 1;
}

# 4. Imprimir
sub imprimir_consola {
    my ($self) = @_;
    if ($self->esta_vacia) {
        print "No hay solicitudes pendientes.\n";
        return;
    }
    
    print "\n--- Solicitudes Pendientes ---\n";
    my $actual = $self->primero;
    do {
        print "ID: " . $actual->id . " | Dept: " . $actual->departamento . 
              " | Med: " . $actual->codigo_med . " | Cant: " . $actual->cantidad . "\n";
        $actual = $actual->siguiente;
    } while ($actual != $self->primero);
    print "------------------------------\n";
}

1;
