package ArbolB;
use strict;
use warnings;
use lib '../Nodos';
use NodoArbolB;

sub new {
    my ($class) = @_;
    my $self = { root => undef, orden => 4, size => 0 };
    bless $self, $class;
    return $self;
}

sub is_empty { return !defined($_[0]->{root}); }

# --- INSERCIÓN ---
sub insertar {
    my ($self, %args) = @_;
    if (!defined($self->{root})) {
        $self->{root} = NodoArbolB->new(1);
        push @{$self->{root}->get_claves()}, \%args;
    } else {
        if ($self->{root}->cantidad_claves() == 3) {
            my $s = NodoArbolB->new(0);
            push @{$s->get_hijos()}, $self->{root};
            $self->_split_hijo($s, 0, $self->{root});
            $self->_insertar_no_lleno($s, \%args);
            $self->{root} = $s;
        } else { $self->_insertar_no_lleno($self->{root}, \%args); }
    }
    $self->{size}++;
}

sub _split_hijo {
    my ($self, $x, $i, $y) = @_;
    my $z = NodoArbolB->new($y->get_es_hoja());
    my $mid_val = splice(@{$y->get_claves()}, 1, 2); # Orden 4
    my $mediana = shift @{$mid_val};
    push @{$z->get_claves()}, @{$mid_val};
    if (!$y->get_es_hoja()) {
        my @hijos_z = splice(@{$y->get_hijos()}, 2, 2);
        push @{$z->get_hijos()}, @hijos_z;
    }
    splice(@{$x->get_hijos()}, $i + 1, 0, $z);
    splice(@{$x->get_claves()}, $i, 0, $mediana);
}

sub _insertar_no_lleno {
    my ($self, $x, $k) = @_;
    my $i = $x->cantidad_claves() - 1;
    if ($x->get_es_hoja()) {
        while ($i >= 0 && $x->get_claves()->[$i]->{codigo} gt $k->{codigo}) { $i--; }
        splice(@{$x->get_claves()}, $i + 1, 0, $k);
    } else {
        while ($i >= 0 && $x->get_claves()->[$i]->{codigo} gt $k->{codigo}) { $i--; }
        $i++;
        if ($x->get_hijos()->[$i]->cantidad_claves() == 3) {
            $self->_split_hijo($x, $i, $x->get_hijos()->[$i]);
            if ($x->get_claves()->[$i]->{codigo} lt $k->{codigo}) { $i++; }
        }
        $self->_insertar_no_lleno($x->get_hijos()->[$i], $k);
    }
}

# --- BUSCAR ---
sub buscar {
    my ($self, $k) = @_;
    return undef if !$self->{root};
    return $self->_buscar_rec($self->{root}, $k);
}
sub _buscar_rec {
    my ($self, $n, $k) = @_;
    my $i = 0;
    while ($i < $n->cantidad_claves() && $k gt $n->get_claves()->[$i]->{codigo}) { $i++; }
    if ($i < $n->cantidad_claves() && $k eq $n->get_claves()->[$i]->{codigo}) { return $n->get_claves()->[$i]; }
    return $n->get_es_hoja() ? undef : $self->_buscar_rec($n->get_hijos()->[$i], $k);
}

# --- RECORRIDO IN-ORDEN (EL QUE PIDE LA GUI) ---
sub in_orden {
    my ($self) = @_;
    my @res;
    $self->_in_rec($self->{root}, \@res);
    return \@res; # Retorna referencia al array
}

sub _in_rec {
    my ($self, $n, $r) = @_;
    return if !defined $n;
    my $i;
    for ($i = 0; $i < $n->cantidad_claves(); $i++) {
        $self->_in_rec($n->get_hijos()->[$i], $r) if !$n->get_es_hoja();
        push @$r, $n->get_claves()->[$i];
    }
    $self->_in_rec($n->get_hijos()->[$i], $r) if !$n->get_es_hoja();
}

# ==========================================
# --- 3. ELIMINACIÓN (REQUISITO FUNCIÓN 3.3) ---
# ==========================================
sub eliminar {
    my ($self, $codigo) = @_;
    return if !$self->{root};
    eval {
        $self->_eliminar_rec($self->{root}, $codigo);
        if ($self->{root}->cantidad_claves() == 0) {
            $self->{root} = $self->{root}->get_es_hoja() ? undef : $self->{root}->get_hijos()->[0];
        }
        $self->{size}--;
    };
}

sub _eliminar_rec {
    my ($self, $nodo, $k) = @_;
    my $idx = 0;
    while ($idx < $nodo->cantidad_claves() && $nodo->get_claves()->[$idx]->{codigo} lt $k) { $idx++; }

    if ($idx < $nodo->cantidad_claves() && $nodo->get_claves()->[$idx]->{codigo} eq $k) {
        if ($nodo->get_es_hoja()) { splice(@{$nodo->get_claves()}, $idx, 1); }
        else { $self->_eliminar_no_hoja($nodo, $idx); }
    } else {
        return if $nodo->get_es_hoja();
        my $ultimo = ($idx == $nodo->cantidad_claves());
        if ($nodo->get_hijos()->[$idx]->cantidad_claves() < 1) { $self->_llenar($nodo, $idx); }
        if ($ultimo && $idx > $nodo->cantidad_claves()) { $self->_eliminar_rec($nodo->get_hijos()->[$idx-1], $k); }
        else { $self->_eliminar_rec($nodo->get_hijos()->[$idx], $k); }
    }
}

sub _eliminar_no_hoja {
    my ($self, $nodo, $idx) = @_;
    my $item = $nodo->get_claves()->[$idx];
    if ($nodo->get_hijos()->[$idx]->cantidad_claves() >= 1) {
        my $pred = $self->_get_pred($nodo, $idx);
        $nodo->get_claves()->[$idx] = $pred;
        $self->_eliminar_rec($nodo->get_hijos()->[$idx], $pred->{codigo});
    } elsif ($nodo->get_hijos()->[$idx+1]->cantidad_claves() >= 1) {
        my $succ = $self->_get_succ($nodo, $idx);
        $nodo->get_claves()->[$idx] = $succ;
        $self->_eliminar_rec($nodo->get_hijos()->[$idx+1], $succ->{codigo});
    } else {
        $self->_fusionar($nodo, $idx);
        $self->_eliminar_rec($nodo->get_hijos()->[$idx], $item->{codigo});
    }
}

sub _llenar {
    my ($self, $nodo, $i) = @_;
    if ($i != 0 && $nodo->get_hijos()->[$i-1]->cantidad_claves() >= 2) { $self->_prestar_ant($nodo, $i); }
    elsif ($i != $nodo->cantidad_claves() && $nodo->get_hijos()->[$i+1]->cantidad_claves() >= 2) { $self->_prestar_sig($nodo, $i); }
    else {
        if ($i != $nodo->cantidad_claves()) { $self->_fusionar($nodo, $i); }
        else { $self->_fusionar($nodo, $i - 1); }
    }
}

sub _prestar_ant {
    my ($self, $nodo, $i) = @_;
    my $hijo = $nodo->get_hijos()->[$i];
    my $hermano = $nodo->get_hijos()->[$i-1];
    unshift @{$hijo->get_claves()}, $nodo->get_claves()->[$i-1];
    if (!$hijo->get_es_hoja()) { unshift @{$hijo->get_hijos()}, pop @{$hermano->get_hijos()}; }
    $nodo->get_claves()->[$i-1] = pop @{$hermano->get_claves()};
}

sub _prestar_sig {
    my ($self, $nodo, $i) = @_;
    my $hijo = $nodo->get_hijos()->[$i];
    my $hermano = $nodo->get_hijos()->[$i+1];
    push @{$hijo->get_claves()}, $nodo->get_claves()->[$i];
    if (!$hijo->get_es_hoja()) { push @{$hijo->get_hijos()}, shift @{$hermano->get_hijos()}; }
    $nodo->get_claves()->[$i] = shift @{$hermano->get_claves()};
}

sub _fusionar {
    my ($self, $nodo, $i) = @_;
    my $hijo = $nodo->get_hijos()->[$i];
    my $hermano = $nodo->get_hijos()->[$i+1];
    push @{$hijo->get_claves()}, splice(@{$nodo->get_claves()}, $i, 1);
    push @{$hijo->get_claves()}, @{$hermano->get_claves()};
    if (!$hijo->get_es_hoja()) { push @{$hijo->get_hijos()}, @{$hermano->get_hijos()}; }
    splice(@{$nodo->get_hijos()}, $i + 1, 1);
}

sub _get_pred {
    my ($self, $nodo, $idx) = @_;
    my $cur = $nodo->get_hijos()->[$idx];
    while (!$cur->get_es_hoja()) { $cur = $cur->get_hijos()->[$cur->cantidad_claves()]; }
    return $cur->get_claves()->[$cur->cantidad_claves()-1];
}

sub _get_succ {
    my ($self, $nodo, $idx) = @_;
    my $cur = $nodo->get_hijos()->[$idx+1];
    while (!$cur->get_es_hoja()) { $cur = $cur->get_hijos()->[0]; }
    return $cur->get_claves()->[0];
}

# ==========================================
# --- 4. RECORRIDO ---
# ==========================================

# --- RECORRIDO PRE-ORDEN ---
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

# --- RECORRIDO POST-ORDEN ---
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