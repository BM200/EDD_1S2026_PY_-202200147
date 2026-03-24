package ArbolB;
use strict;
use warnings;
use lib '../Nodos';
use NodoArbolB;

sub new {
    my ($class) = @_;
    my $self = {
        root  => undef,
        orden => 4, # Orden 4 implica máximo 3 claves por nodo
        size  => 0,
    };
    bless $self, $class;
    return $self;
}

sub is_empty {
    my ($self) = @_;
    return !defined($self->{root}) ? 1 : 0;
}

# --- INSERCIÓN MANUAL ---
sub insertar {
    my ($self, %args) = @_;
    
    eval {
        if (!defined($self->{root})) {
            # Árbol vacío, creamos la primera raíz
            $self->{root} = NodoArbolB->new(1); # es_hoja = 1
            push @{$self->{root}->get_claves()}, \%args;
            $self->{size}++;
            print "Suministro '$args{codigo}' insertado en raiz vacia.\n";
            return;
        }

        my $raiz = $self->{root};
        
        # Si la raíz está llena (tiene 3 claves)
        if ($raiz->cantidad_claves() == 3) {
            my $nueva_raiz = NodoArbolB->new(0); # es_hoja = 0 (nodo interno)
            
            # La vieja raíz se convierte en el hijo izquierdo de la nueva raíz
            push @{$nueva_raiz->get_hijos()}, $raiz;
            
            # Dividir la vieja raíz
            $self->_split_hijo($nueva_raiz, 0, $raiz);
            
            # Ahora la nueva raíz tiene 1 clave y 2 hijos, insertamos en ella
            $self->_insertar_no_lleno($nueva_raiz, \%args);
            $self->{root} = $nueva_raiz;
        } else {
            # Raíz no está llena, insertar normal
            $self->_insertar_no_lleno($raiz, \%args);
        }
        $self->{size}++;
    };
    if ($@) {
        print "Error insertando en Arbol B: $@\n";
    }
}

# Algoritmo de división manual (Split)
sub _split_hijo {
    my ($self, $nodo_padre, $indice_hijo, $nodo_lleno) = @_;
    
    # Creamos un nuevo nodo que será el "hermano derecho" del nodo lleno
    my $nuevo_nodo = NodoArbolB->new($nodo_lleno->get_es_hoja());
    
    # Las claves en orden 4 son [0, 1, 2]. 
    # La clave en índice 1 (la de en medio) subirá al padre.
    # La clave en índice 2 se moverá al nuevo nodo.
    
    # 1. Extraemos la última clave del nodo lleno y la ponemos en el nuevo
    my $clave_derecha = pop @{$nodo_lleno->get_claves()};
    unshift @{$nuevo_nodo->get_claves()}, $clave_derecha;
    
    # 2. Extraemos la clave mediana que subirá
    my $clave_mediana = pop @{$nodo_lleno->get_claves()};
    
    # 3. Si no es hoja, movemos también los 2 últimos hijos al nuevo nodo
    if (!$nodo_lleno->get_es_hoja()) {
        my $hijo_der2 = pop @{$nodo_lleno->get_hijos()};
        my $hijo_der1 = pop @{$nodo_lleno->get_hijos()};
        unshift @{$nuevo_nodo->get_hijos()}, $hijo_der1, $hijo_der2;
    }
    
    # 4. Insertar el nuevo nodo en el arreglo de hijos del padre
    splice(@{$nodo_padre->get_hijos()}, $indice_hijo + 1, 0, $nuevo_nodo);
    
    # 5. Subir la clave mediana al arreglo de claves del padre
    splice(@{$nodo_padre->get_claves()}, $indice_hijo, 0, $clave_mediana);
}

sub _insertar_no_lleno {
    my ($self, $nodo, $args_ref) = @_;
    my $i = $nodo->cantidad_claves() - 1;
    my $clave_nueva = $args_ref->{codigo};

    if ($nodo->get_es_hoja()) {
        # Es hoja: encontramos la posición correcta moviendo los elementos mayores
        while ($i >= 0 && ($nodo->get_claves()->[$i]->{codigo} gt $clave_nueva)) {
            $i--;
        }
        
        # Validación de duplicados
        if ($i >= 0 && ($nodo->get_claves()->[$i]->{codigo} eq $clave_nueva)) {
            die "El suministro '$clave_nueva' ya existe.";
        }
        
        # Insertar en la posición
        splice(@{$nodo->get_claves()}, $i + 1, 0, $args_ref);
        print "Suministro '$clave_nueva' insertado en hoja.\n";
    } else {
        # Es nodo interno: buscar a qué hijo descender
        while ($i >= 0 && ($nodo->get_claves()->[$i]->{codigo} gt $clave_nueva)) {
            $i--;
        }
        $i++;
        
        # Si el hijo destino está lleno, lo dividimos primero
        if ($nodo->get_hijos()->[$i]->cantidad_claves() == 3) {
            $self->_split_hijo($nodo, $i, $nodo->get_hijos()->[$i]);
            
            # Determinar a cuál de los dos nuevos hijos divididos ir
            if ($nodo->get_claves()->[$i]->{codigo} lt $clave_nueva) {
                $i++;
            }
        }
        $self->_insertar_no_lleno($nodo->get_hijos()->[$i], $args_ref);
    }
}

# --- BÚSQUEDA ---
sub buscar {
    my ($self, $codigo) = @_;
    if ($self->is_empty()) { return undef; }
    
    my $resultado = undef;
    eval {
        $resultado = $self->_buscar_recursivo($self->{root}, $codigo);
    };
    if ($@) { print "Error en búsqueda Árbol B: $@\n"; }
    return $resultado;
}

sub _buscar_recursivo {
    my ($self, $nodo, $codigo) = @_;
    return undef if !defined($nodo);

    my $i = 0;
    while ($i < $nodo->cantidad_claves() && ($codigo gt $nodo->get_claves()->[$i]->{codigo})) {
        $i++;
    }

    # Si encontramos coincidencia exacta
    if ($i < $nodo->cantidad_claves() && ($codigo eq $nodo->get_claves()->[$i]->{codigo})) {
        return $nodo->get_claves()->[$i]; # Retorna el HashRef con los datos
    }

    # Si es hoja y no estaba, no existe
    if ($nodo->get_es_hoja()) {
        return undef;
    }

    # Bajar al hijo correspondiente
    return $self->_buscar_recursivo($nodo->get_hijos()->[$i], $codigo);
}

# --- RECORRIDO IN-ORDEN ---
sub in_orden {
    my ($self) = @_;
    my @resultado;
    eval { $self->_in_orden_recursivo($self->{root}, \@resultado); };
    return \@resultado;
}

sub _in_orden_recursivo {
    my ($self, $nodo, $res) = @_;
    if (defined($nodo)) {
        my $i;
        # Intercalar hijos y claves
        for ($i = 0; $i < $nodo->cantidad_claves(); $i++) {
            if (!$nodo->get_es_hoja()) {
                $self->_in_orden_recursivo($nodo->get_hijos()->[$i], $res);
            }
            push @$res, $nodo->get_claves()->[$i];
        }
        # Último hijo a la derecha
        if (!$nodo->get_es_hoja()) {
            $self->_in_orden_recursivo($nodo->get_hijos()->[$i], $res);
        }
    }
}

1;