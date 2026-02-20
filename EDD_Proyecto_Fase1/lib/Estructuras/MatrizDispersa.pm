package MatrizDispersa; # Nombre de paquete simplificado

use strict;
use warnings;

# Rutas corregidas a tus archivos
use lib '../Nodos';
use NodoMatrizCabecera;
use NodoMatrizDato;

# CONSTRUCTOR
sub new {
    my ($class) = @_; # Quitamos filas/cols fijas, será dinámico

    my $self = {
        lista_filas => undef,
        lista_cols  => undef,
        num_filas   => 0,
        num_cols    => 0,
        total_datos => 0,
        
        # MAPEOS: Para convertir Strings a Índices
        map_filas => {}, # Hash: "Tylenol" => 0
        map_cols  => {}, # Hash: "LabFarma" => 0
        next_fila => 0,
        next_col  => 0
    };

    bless $self, $class;
    return $self;
}

# --- LOGICA DE MAPEO (NUEVO) ---
# Convierte nombres en índices y llama a la inserción numérica
sub insertar_elemento {
    my ($self, $nombre_med, $nombre_lab, $precio) = @_;
    
    # 1. Resolver Índice de Fila (Medicamento)
    my $idx_fila;
    if (exists $self->{map_filas}->{$nombre_med}) {
        $idx_fila = $self->{map_filas}->{$nombre_med};
    } else {
        $idx_fila = $self->{next_fila}++;
        $self->{map_filas}->{$nombre_med} = $idx_fila;
        $self->{num_filas}++;
    }

    # 2. Resolver Índice de Columna (Laboratorio)
    my $idx_col;
    if (exists $self->{map_cols}->{$nombre_lab}) {
        $idx_col = $self->{map_cols}->{$nombre_lab};
    } else {
        $idx_col = $self->{next_col}++;
        $self->{map_cols}->{$nombre_lab} = $idx_col;
        $self->{num_cols}++;
    }

    # 3. Insertar usando tu lógica numérica
    # Nota: Pasamos también los nombres para guardarlos en las cabeceras si son nuevas
    $self->_insertar_interno($idx_fila, $idx_col, $precio, $nombre_med, $nombre_lab);
}

# --- TU CÓDIGO ORIGINAL (ADAPTADO) ---

sub _buscar_cab_fila {
    my ($self, $fila_idx) = @_;
    my $actual = $self->{lista_filas};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $fila_idx);
        last if ($actual->get_label() > $fila_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub _buscar_cab_col {
    my ($self, $col_idx) = @_;
    my $actual = $self->{lista_cols};
    while (defined $actual) {
        return $actual if ($actual->get_label() == $col_idx);
        last if ($actual->get_label() > $col_idx);
        $actual = $actual->get_next();
    }
    return undef;
}

sub _obtener_o_crear_cab_fila {
    my ($self, $fila_idx, $nombre_real) = @_; # Agregado nombre_real

    # Helper para crear nodo con nombre
    my $crear_nodo = sub {
        my $n = NodoMatrizCabecera->new($fila_idx);
        $n->set_nombre_real($nombre_real) if defined $nombre_real;
        return $n;
    };

    if (!defined $self->{lista_filas}) {
        my $nueva = $crear_nodo->();
        $self->{lista_filas} = $nueva;
        return $nueva;
    }
    if ($self->{lista_filas}->get_label() > $fila_idx) {
        my $nueva = $crear_nodo->();
        $nueva->set_next($self->{lista_filas});
        $self->{lista_filas} = $nueva;
        return $nueva;
    }
    if ($self->{lista_filas}->get_label() == $fila_idx) {
        return $self->{lista_filas};
    }

    my $anterior = $self->{lista_filas};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $fila_idx) {
            return $actual;
        }
        if ($actual->get_label() > $fila_idx) {
            my $nueva = $crear_nodo->();
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = $crear_nodo->();
    $anterior->set_next($nueva);
    return $nueva;
}

sub _obtener_o_crear_cab_col {
    my ($self, $col_idx, $nombre_real) = @_;

    my $crear_nodo = sub {
        my $n = NodoMatrizCabecera->new($col_idx);
        $n->set_nombre_real($nombre_real) if defined $nombre_real;
        return $n;
    };

    if (!defined $self->{lista_cols}) {
        my $nueva = $crear_nodo->();
        $self->{lista_cols} = $nueva;
        return $nueva;
    }
    if ($self->{lista_cols}->get_label() > $col_idx) {
        my $nueva = $crear_nodo->();
        $nueva->set_next($self->{lista_cols});
        $self->{lista_cols} = $nueva;
        return $nueva;
    }
    if ($self->{lista_cols}->get_label() == $col_idx) {
        return $self->{lista_cols};
    }

    my $anterior = $self->{lista_cols};
    my $actual   = $anterior->get_next();

    while (defined $actual) {
        if ($actual->get_label() == $col_idx) {
            return $actual;
        }
        if ($actual->get_label() > $col_idx) {
            my $nueva = $crear_nodo->();
            $nueva->set_next($actual);
            $anterior->set_next($nueva);
            return $nueva;
        }
        $anterior = $actual;
        $actual   = $actual->get_next();
    }

    my $nueva = $crear_nodo->();
    $anterior->set_next($nueva);
    return $nueva;
}

# Insertar Interno (Tu lógica original con ligeros ajustes)
sub _insertar_interno {
    my ($self, $fila, $col, $valor, $nom_fila, $nom_col) = @_;

    # Obtener o crear cabeceras (pasando nombres reales)
    my $cab_fila = $self->_obtener_o_crear_cab_fila($fila, $nom_fila);
    my $cab_col  = $self->_obtener_o_crear_cab_col($col, $nom_col);

    # Verificar existencia
    my $existente = $self->obtener($fila, $col);
    if (defined $existente) {
        $existente->set_valor($valor);
        return;
    }

    my $nuevo = NodoMatrizDato->new($fila, $col, $valor);

    # ENLAZAR FILA
    if (!defined $cab_fila->get_right()) {
        $cab_fila->set_right($nuevo);
    }
    elsif ($cab_fila->get_right()->get_col() > $col) {
        my $primero = $cab_fila->get_right();
        $nuevo->set_right($primero);
        $primero->set_left($nuevo);
        $cab_fila->set_right($nuevo);
    }
    else {
        my $anterior = $cab_fila->get_right();
        my $actual   = $anterior->get_right();
        while (defined $actual && $actual->get_col() < $col) {
            $anterior = $actual;
            $actual   = $actual->get_right();
        }
        $nuevo->set_right($actual);
        $nuevo->set_left($anterior);
        $anterior->set_right($nuevo);
        if (defined $actual) { $actual->set_left($nuevo); }
    }

    # ENLAZAR COLUMNA
    if (!defined $cab_col->get_down()) {
        $cab_col->set_down($nuevo);
    }
    elsif ($cab_col->get_down()->get_fila() > $fila) {
        my $primero = $cab_col->get_down();
        $nuevo->set_down($primero);
        $primero->set_up($nuevo);
        $cab_col->set_down($nuevo);
    }
    else {
        my $anterior = $cab_col->get_down();
        my $actual   = $anterior->get_down();
        while (defined $actual && $actual->get_fila() < $fila) {
            $anterior = $actual;
            $actual   = $actual->get_down();
        }
        $nuevo->set_down($actual);
        $nuevo->set_up($anterior);
        $anterior->set_down($nuevo);
        if (defined $actual) { $actual->set_up($nuevo); }
    }

    $self->{total_datos}++;
}

sub obtener {
    my ($self, $fila, $col) = @_;
    my $cab_fila = $self->_buscar_cab_fila($fila);
    return undef unless defined $cab_fila;

    my $actual = $cab_fila->get_right();
    while (defined $actual) {
        return $actual if ($actual->get_col() == $col);
        last           if ($actual->get_col() >  $col);
        $actual = $actual->get_right();
    }
    return undef;
}

sub imprimir_consola {
    my ($self) = @_;
    print "\n--- Matriz Dispersa de Precios ---\n";
    
    my $cab_fila = $self->{lista_filas};
    while (defined $cab_fila) {
        print "MED: " . $cab_fila->get_nombre_real() . " -> ";
        
        my $nodo = $cab_fila->get_right();
        while (defined $nodo) {
            # Necesitamos buscar el nombre del laboratorio (columna)
            # Esto es ineficiente pero sirve para debug visual
            my $precio = $nodo->get_valor();
            print "[Q$precio] ";
            $nodo = $nodo->get_right();
        }
        print "\n";
        $cab_fila = $cab_fila->get_next();
    }
    print "----------------------------------\n";
}

1;