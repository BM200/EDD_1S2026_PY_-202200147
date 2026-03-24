package ArbolAVL;
use strict;
use warnings;
use lib '../Nodos';
use NodoAVL;

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

sub get_size { return $_[0]->{size}; }

# --- FUNCIONES MATEMÁTICAS AVL ---
sub _obtener_altura {
    my ($self, $nodo) = @_;
    return defined($nodo) ? $nodo->get_height() : 0;
}

sub _obtener_balance {
    my ($self, $nodo) = @_;
    return defined($nodo) ? $self->_obtener_altura($nodo->get_left()) - $self->_obtener_altura($nodo->get_right()) : 0;
}

sub _max {
    my ($a, $b) = @_;
    return $a > $b ? $a : $b;
}

sub _actualizar_altura {
    my ($self, $nodo) = @_;
    if (defined($nodo)) {
        $nodo->set_height( 1 + _max($self->_obtener_altura($nodo->get_left()), $self->_obtener_altura($nodo->get_right())) );
    }
}

# --- ROTACIONES ---
sub _rotacion_derecha {
    my ($self, $y) = @_;
    my $x = $y->get_left();
    my $T2 = $x->get_right();

    # Realizar rotacion
    $x->set_right($y);
    $y->set_left($T2);

    # Actualizar alturas
    $self->_actualizar_altura($y);
    $self->_actualizar_altura($x);

    return $x; # Nueva raiz
}

sub _rotacion_izquierda {
    my ($self, $x) = @_;
    my $y = $x->get_right();
    my $T2 = $y->get_left();

    # Realizar rotacion
    $y->set_left($x);
    $x->set_right($T2);

    # Actualizar alturas
    $self->_actualizar_altura($x);
    $self->_actualizar_altura($y);

    return $y; # Nueva raiz
}

# --- INSERCIÓN AUTO-BALANCEADA ---
sub insertar {
    my ($self, %args) = @_;
    
    # Manejo de errores para evitar caídas
    eval {
        $self->{root} = $self->_insertar_recursivo($self->{root}, \%args);
        $self->{size}++;
    };
    if ($@) {
        # Si arroja un die (como duplicado), lo capturamos aquí
        print "Error insertando usuario en AVL: $@\n";
    }
}

sub _insertar_recursivo {
    my ($self, $nodo, $args_ref) = @_;
    
    # 1. Inserción normal de BST
    if (!defined($nodo)) {
        return NodoAVL->new(%{$args_ref});
    }

    my $clave_nueva = $args_ref->{numero_colegio};
    my $clave_actual = $nodo->get_numero_colegio();

    if ($clave_nueva lt $clave_actual) {
        $nodo->set_left( $self->_insertar_recursivo($nodo->get_left(), $args_ref) );
    } 
    elsif ($clave_nueva gt $clave_actual) {
        $nodo->set_right( $self->_insertar_recursivo($nodo->get_right(), $args_ref) );
    } 
    else {
        die "El numero de colegio '$clave_nueva' ya esta registrado.";
    }

    # 2. Actualizar altura
    $self->_actualizar_altura($nodo);

    # 3. Obtener factor de balance
    my $balance = $self->_obtener_balance($nodo);

    # 4. Rotaciones de balanceo
    # Izquierda-Izquierda
    if ($balance > 1 && $clave_nueva lt $nodo->get_left()->get_numero_colegio()) {
        return $self->_rotacion_derecha($nodo);
    }
    # Derecha-Derecha
    if ($balance < -1 && $clave_nueva gt $nodo->get_right()->get_numero_colegio()) {
        return $self->_rotacion_izquierda($nodo);
    }
    # Izquierda-Derecha
    if ($balance > 1 && $clave_nueva gt $nodo->get_left()->get_numero_colegio()) {
        $nodo->set_left( $self->_rotacion_izquierda($nodo->get_left()) );
        return $self->_rotacion_derecha($nodo);
    }
    # Derecha-Izquierda
    if ($balance < -1 && $clave_nueva lt $nodo->get_right()->get_numero_colegio()) {
        $nodo->set_right( $self->_rotacion_derecha($nodo->get_right()) );
        return $self->_rotacion_izquierda($nodo);
    }

    return $nodo;
}

# --- ELIMINACIÓN AUTO-BALANCEADA ---
sub eliminar {
    my ($self, $colegio) = @_;
    
    if ($self->is_empty()) { return; }
    
    eval {
        $self->{root} = $self->_eliminar_recursivo($self->{root}, $colegio);
        $self->{size}--;
    };
    if ($@) { print "Error eliminando en AVL: $@\n"; }
}

sub _eliminar_recursivo {
    my ($self, $nodo, $colegio) = @_;
    return undef if !defined($nodo);

    my $clave_actual = $nodo->get_numero_colegio();

    # 1. Eliminación normal de BST
    if ($colegio lt $clave_actual) {
        $nodo->set_left( $self->_eliminar_recursivo($nodo->get_left(), $colegio) );
    } 
    elsif ($colegio gt $clave_actual) {
        $nodo->set_right( $self->_eliminar_recursivo($nodo->get_right(), $colegio) );
    } 
    else {
        # Encontramos el nodo
        if (!defined($nodo->get_left()) || !defined($nodo->get_right())) {
            my $temp = defined($nodo->get_left()) ? $nodo->get_left() : $nodo->get_right();
            if (!defined($temp)) {
                $nodo = undef; # Caso: No tiene hijos
            } else {
                $nodo = $temp; # Caso: Un solo hijo
            }
        } else {
            # Caso: Dos hijos (Busca el mínimo del subárbol derecho)
            my $temp = $self->_encontrar_minimo($nodo->get_right());
            $nodo->set_datos($temp);
            $nodo->set_right( $self->_eliminar_recursivo($nodo->get_right(), $temp->get_numero_colegio()) );
        }
    }

    return $nodo if !defined($nodo); # Si el árbol tenía solo 1 nodo y lo borramos

    # 2. Actualizar altura y balancear (Subiendo por la recursión)
    $self->_actualizar_altura($nodo);
    my $balance = $self->_obtener_balance($nodo);

    # Rotaciones
    # Caso I-I
    if ($balance > 1 && $self->_obtener_balance($nodo->get_left()) >= 0) {
        return $self->_rotacion_derecha($nodo);
    }
    # Caso I-D
    if ($balance > 1 && $self->_obtener_balance($nodo->get_left()) < 0) {
        $nodo->set_left( $self->_rotacion_izquierda($nodo->get_left()) );
        return $self->_rotacion_derecha($nodo);
    }
    # Caso D-D
    if ($balance < -1 && $self->_obtener_balance($nodo->get_right()) <= 0) {
        return $self->_rotacion_izquierda($nodo);
    }
    # Caso D-I
    if ($balance < -1 && $self->_obtener_balance($nodo->get_right()) > 0) {
        $nodo->set_right( $self->_rotacion_derecha($nodo->get_right()) );
        return $self->_rotacion_izquierda($nodo);
    }

    return $nodo;
}

sub _encontrar_minimo {
    my ($self, $nodo) = @_;
    return $nodo if !defined($nodo->get_left());
    return $self->_encontrar_minimo($nodo->get_left());
}

# --- BÚSQUEDA ---
sub buscar {
    my ($self, $colegio) = @_;
    return $self->_buscar_recursivo($self->{root}, $colegio);
}

sub _buscar_recursivo {
    my ($self, $nodo, $colegio) = @_;
    return undef if !defined($nodo);

    my $clave_actual = $nodo->get_numero_colegio();
    
    if ($colegio eq $clave_actual) { return $nodo; } 
    elsif ($colegio lt $clave_actual) { return $self->_buscar_recursivo($nodo->get_left(), $colegio); } 
    else { return $self->_buscar_recursivo($nodo->get_right(), $colegio); }
}

# --- RECORRIDOS (In, Pre, Post para tablas GTK) ---
sub in_orden {
    my ($self) = @_;
    my @resultado;
    $self->_in_orden_recursivo($self->{root}, \@resultado);
    return \@resultado;
}
sub _in_orden_recursivo {
    my ($self, $nodo, $res) = @_;
    if (defined($nodo)) {
        $self->_in_orden_recursivo($nodo->get_left(), $res);
        push @$res, $nodo;
        $self->_in_orden_recursivo($nodo->get_right(), $res);
    }
}


1;