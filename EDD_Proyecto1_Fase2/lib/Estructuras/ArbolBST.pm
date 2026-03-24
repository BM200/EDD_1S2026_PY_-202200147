package ArbolBST;
use strict;
use warnings;
use lib '../Nodos';
use NodoBST;

sub new {
    my ($class) = @_;
    my $self = {
        root => undef,
        size => 0,
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

# --- INSERCIÓN ---
sub insertar {
    my ($self, %args) = @_;
    
    if (!defined($self->{root})) {
        $self->{root} = NodoBST->new(%args);
        $self->{size}++;
        print "Insertado equipo '$args{codigo}' como RAIZ del arbol.\n";
        return;
    }

    my $insertado = $self->_insertar_recursivo($self->{root}, \%args);
    if ($insertado) {
        $self->{size}++;
    }
}

sub _insertar_recursivo {
    my ($self, $nodo_actual, $args_ref) = @_;
    my $clave_nueva = $args_ref->{codigo};
    my $clave_actual = $nodo_actual->get_codigo();

    if ($clave_nueva lt $clave_actual) {
        if (!defined($nodo_actual->get_left())) {
            $nodo_actual->set_left(NodoBST->new(%{$args_ref}));
            print "Insertado '$clave_nueva' a la IZQUIERDA de '$clave_actual'.\n";
            return 1;
        } else {
            return $self->_insertar_recursivo($nodo_actual->get_left(), $args_ref);
        }
    } 
    elsif ($clave_nueva gt $clave_actual) {
        if (!defined($nodo_actual->get_right())) {
            $nodo_actual->set_right(NodoBST->new(%{$args_ref}));
            print "Insertado '$clave_nueva' a la DERECHA de '$clave_actual'.\n";
            return 1;
        } else {
            return $self->_insertar_recursivo($nodo_actual->get_right(), $args_ref);
        }
    } 
    else {
        print "Error: El equipo con codigo '$clave_nueva' ya existe. No se aceptan duplicados.\n";
        return 0;
    }
}

# --- BÚSQUEDA ---
sub buscar {
    my ($self, $codigo) = @_;
    if ($self->is_empty()) { return undef; }
    return $self->_buscar_recursivo($self->{root}, $codigo);
}

sub _buscar_recursivo {
    my ($self, $nodo_actual, $codigo) = @_;
    return undef if !defined($nodo_actual);

    my $clave_actual = $nodo_actual->get_codigo();

    if ($codigo eq $clave_actual) {
        return $nodo_actual; 
    } elsif ($codigo lt $clave_actual) {
        return $self->_buscar_recursivo($nodo_actual->get_left(), $codigo);
    } else {
        return $self->_buscar_recursivo($nodo_actual->get_right(), $codigo);
    }
}

# --- ELIMINACIÓN ---
sub eliminar {
    my ($self, $codigo) = @_;

    if ($self->is_empty()) {
        print "El arbol esta vacio. No hay nada que eliminar.\n";
        return;
    }

    my $existe = $self->buscar($codigo);
    if (!defined($existe)) {
        print "El equipo '$codigo' no existe en el arbol.\n";
        return;
    }

    $self->{root} = $self->_eliminar_recursivo($self->{root}, $codigo);
    $self->{size}--;
    print "Equipo '$codigo' eliminado exitosamente.\n";
}

sub _eliminar_recursivo {
    my ($self, $nodo_actual, $codigo) = @_;
    return undef if !defined($nodo_actual);

    my $clave_actual = $nodo_actual->get_codigo();

    if ($codigo lt $clave_actual) {
        $nodo_actual->set_left( $self->_eliminar_recursivo($nodo_actual->get_left(), $codigo) );
        return $nodo_actual;
    } 
    elsif ($codigo gt $clave_actual) {
        $nodo_actual->set_right( $self->_eliminar_recursivo($nodo_actual->get_right(), $codigo) );
        return $nodo_actual;
    } 
    else {
        # Nodo a eliminar encontrado
        if ($nodo_actual->es_hoja()) {
            return undef;
        } 
        elsif (!defined($nodo_actual->get_left())) {
            return $nodo_actual->get_right();
        } 
        elsif (!defined($nodo_actual->get_right())) {
            return $nodo_actual->get_left();
        } 
        else {
            # Nodo con 2 hijos: Buscar sucesor inorden (mínimo del subárbol derecho)
            my $sucesor = $self->_encontrar_minimo($nodo_actual->get_right());
            
            # Copiar TODOS los datos del sucesor al nodo actual
            $nodo_actual->set_datos($sucesor);
            
            # Eliminar el nodo sucesor original
            $nodo_actual->set_right( $self->_eliminar_recursivo($nodo_actual->get_right(), $sucesor->get_codigo()) );

            return $nodo_actual;
        }
    }
}

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    if (!defined($nodo->get_left())) {
        return $nodo;
    }
    return $self->_encontrar_minimo($nodo->get_left());
}

# --- RECORRIDOS (Para las Tablas GTK) ---
# En vez de imprimir directo, devuelven arreglos para llenar la tabla gráfica luego.

sub in_orden {
    my ($self) = @_;
    my @resultado;
    $self->_in_orden_recursivo($self->{root}, \@resultado);
    return \@resultado;
}
sub _in_orden_recursivo {
    my ($self, $nodo, $res) = @_;
    return if !defined($nodo);
    $self->_in_orden_recursivo($nodo->get_left(), $res);
    push @$res, $nodo;
    $self->_in_orden_recursivo($nodo->get_right(), $res);
}

sub pre_orden {
    my ($self) = @_;
    my @resultado;
    $self->_pre_orden_recursivo($self->{root}, \@resultado);
    return \@resultado;
}
sub _pre_orden_recursivo {
    my ($self, $nodo, $res) = @_;
    return if !defined($nodo);
    push @$res, $nodo;
    $self->_pre_orden_recursivo($nodo->get_left(), $res);
    $self->_pre_orden_recursivo($nodo->get_right(), $res);
}

sub post_orden {
    my ($self) = @_;
    my @resultado;
    $self->_post_orden_recursivo($self->{root}, \@resultado);
    return \@resultado;
}
sub _post_orden_recursivo {
    my ($self, $nodo, $res) = @_;
    return if !defined($nodo);
    $self->_post_orden_recursivo($nodo->get_left(), $res);
    $self->_post_orden_recursivo($nodo->get_right(), $res);
    push @$res, $nodo;
}

1;