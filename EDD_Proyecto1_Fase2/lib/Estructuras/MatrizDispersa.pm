package MatrizDispersa;
use strict;
use warnings;
use lib '../Nodos';
use NodoMatrizCabecera;
use NodoMatrizDato;

sub new {
    my ($class) = @_;
    my $self = {
        lista_filas => undef,
        lista_cols  => undef,
        num_filas   => 0,
        num_cols    => 0,
        total_datos => 0,
        map_filas   => {}, 
        map_cols    => {}, 
        next_fila   => 0,
        next_col    => 0
    };
    bless $self, $class;
    return $self;
}

sub sumar_elemento {
    my ($self, $prov, $fab, $cant) = @_;
    
    # 1. Limpieza de strings
    $prov =~ s/^\s+|\s+$//g; $prov =~ s/\s+/ /g;
    $fab  =~ s/^\s+|\s+$//g; $fab  =~ s/\s+/ /g;
    return if ($prov eq "" || $fab eq "");

    # 2. Mapeo
    my $idx_f = $self->_obtener_indice_fila($prov);
    my $idx_c = $self->_obtener_indice_col($fab);

    # 3. Buscar celda
    my $nodo = $self->obtener($idx_f, $idx_c);

    if (defined $nodo) {
        # SUMAR
        $nodo->set_valor($nodo->get_valor() + $cant);
    } else {
        # INSERTAR
        $self->_insertar_interno($idx_f, $idx_c, $cant, $prov, $fab);
    }
}

sub _obtener_indice_fila {
    my ($self, $n) = @_;
    return $self->{map_filas}->{$n} if exists $self->{map_filas}->{$n};
    my $idx = $self->{next_fila}++;
    $self->{map_filas}->{$n} = $idx;
    $self->{num_filas}++;
    return $idx;
}

sub _obtener_indice_col {
    my ($self, $n) = @_;
    return $self->{map_cols}->{$n} if exists $self->{map_cols}->{$n};
    my $idx = $self->{next_col}++;
    $self->{map_cols}->{$n} = $idx;
    $self->{num_cols}++;
    return $idx;
}

sub _insertar_interno {
    my ($self, $f, $c, $v, $nom_f, $nom_c) = @_;
    my $cab_f = $self->_obtener_o_crear_cab_fila($f, $nom_f);
    my $cab_c = $self->_obtener_o_crear_cab_col($c, $nom_c);
    my $nuevo = NodoMatrizDato->new($f, $c, $v);

    # Enlace Fila
    if (!defined $cab_f->get_right()) { $cab_f->set_right($nuevo); }
    elsif ($cab_f->get_right()->get_col() > $c) {
        my $p = $cab_f->get_right(); $nuevo->set_right($p); $p->set_left($nuevo); $cab_f->set_right($nuevo);
    } else {
        my $ant = $cab_f->get_right();
        while (defined $ant->get_right() && $ant->get_right()->get_col() < $c) { $ant = $ant->get_right(); }
        my $sig = $ant->get_right();
        $nuevo->set_right($sig); $nuevo->set_left($ant); $ant->set_right($nuevo);
        $sig->set_left($nuevo) if defined $sig;
    }

    # Enlace Columna
    if (!defined $cab_c->get_down()) { $cab_c->set_down($nuevo); }
    elsif ($cab_c->get_down()->get_fila() > $f) {
        my $p = $cab_c->get_down(); $nuevo->set_down($p); $p->set_up($nuevo); $cab_c->set_down($nuevo);
    } else {
        my $ant = $cab_c->get_down();
        while (defined $ant->get_down() && $ant->get_down()->get_fila() < $f) { $ant = $ant->get_down(); }
        my $sig = $ant->get_down();
        $nuevo->set_down($sig); $nuevo->set_up($ant); $ant->set_down($nuevo);
        $sig->set_up($nuevo) if defined $sig;
    }
    $self->{total_datos}++;
}

sub obtener {
    my ($self, $f, $c) = @_;
    my $cab = $self->_buscar_cab_fila($f);
    return undef unless defined $cab;
    my $act = $cab->get_right();
    while (defined $act) {
        return $act if ($act->get_col() == $c);
        last if ($act->get_col() > $c);
        $act = $act->get_right();
    }
    return undef;
}

sub _buscar_cab_fila {
    my ($self, $f) = @_;
    my $act = $self->{lista_filas};
    while (defined $act) {
        return $act if ($act->get_label() == $f);
        last if ($act->get_label() > $f);
        $act = $act->get_next();
    }
    return undef;
}

# --- LÓGICA DE CABECERAS REPARADA ---
sub _obtener_o_crear_cab_fila {
    my ($self, $f, $nom) = @_;
    # 1. Si está vacío o el nuevo es menor que el primero
    if (!defined $self->{lista_filas}) {
        my $n = NodoMatrizCabecera->new($f); $n->set_nombre_real($nom);
        return $self->{lista_filas} = $n;
    }
    if ($self->{lista_filas}->get_label() == $f) { return $self->{lista_filas}; }
    if ($self->{lista_filas}->get_label() > $f) {
        my $n = NodoMatrizCabecera->new($f); $n->set_nombre_real($nom);
        $n->set_next($self->{lista_filas}); return $self->{lista_filas} = $n;
    }
    # 2. Recorrer la lista
    my $ant = $self->{lista_filas};
    while (defined $ant->get_next() && $ant->get_next()->get_label() < $f) { $ant = $ant->get_next(); }
    # 3. Ya existe?
    if (defined $ant->get_next() && $ant->get_next()->get_label() == $f) { return $ant->get_next(); }
    # 4. No existe, insertar en medio o al final
    my $n = NodoMatrizCabecera->new($f); $n->set_nombre_real($nom);
    $n->set_next($ant->get_next()); $ant->set_next($n);
    return $n;
}

sub _obtener_o_crear_cab_col {
    my ($self, $c, $nom) = @_;
    if (!defined $self->{lista_cols}) {
        my $n = NodoMatrizCabecera->new($c); $n->set_nombre_real($nom);
        return $self->{lista_cols} = $n;
    }
    if ($self->{lista_cols}->get_label() == $c) { return $self->{lista_cols}; }
    if ($self->{lista_cols}->get_label() > $c) {
        my $n = NodoMatrizCabecera->new($c); $n->set_nombre_real($nom);
        $n->set_next($self->{lista_cols}); return $self->{lista_cols} = $n;
    }
    my $ant = $self->{lista_cols};
    while (defined $ant->get_next() && $ant->get_next()->get_label() < $c) { $ant = $ant->get_next(); }
    if (defined $ant->get_next() && $ant->get_next()->get_label() == $c) { return $ant->get_next(); }
    my $n = NodoMatrizCabecera->new($c); $n->set_nombre_real($nom);
    $n->set_next($ant->get_next()); $ant->set_next($n);
    return $n;
}

1;