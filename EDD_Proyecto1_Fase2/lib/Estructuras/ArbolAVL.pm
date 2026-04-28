package ArbolAVL;
use strict;
use warnings;
use lib '../Nodos';
use NodoAVL;

sub new {
    my ($class) = @_;
    my $self = { root => undef, size => 0 };
    bless $self, $class;
    return $self;
}

sub is_empty { return !defined($_[0]->{root}); }

# --- FUNCIONES MATEMÁTICAS ---
sub _obtener_altura { return defined($_[1]) ? $_[1]->get_height() : 0; }
sub _obtener_balance {
    my ($self, $n) = @_;
    return defined($n) ? $self->_obtener_altura($n->get_left()) - $self->_obtener_altura($n->get_right()) : 0;
}
sub _max { return $_[0] > $_[1] ? $_[0] : $_[1]; }
sub _actualizar_altura {
    my ($self, $n) = @_;
    if (defined $n) {
        $n->set_height(1 + _max($self->_obtener_altura($n->get_left()), $self->_obtener_altura($n->get_right())));
    }
}

# --- ROTACIONES ---
sub _rot_der {
    my ($self, $y) = @_;
    my $x = $y->get_left(); my $T2 = $x->get_right();
    $x->set_right($y); $y->set_left($T2);
    $self->_actualizar_altura($y); $self->_actualizar_altura($x);
    return $x;
}
sub _rot_izq {
    my ($self, $x) = @_;
    my $y = $x->get_right(); my $T2 = $y->get_left();
    $y->set_left($x); $x->set_right($T2);
    $self->_actualizar_altura($x); $self->_actualizar_altura($y);
    return $y;
}

# --- INSERCIÓN ---
sub insertar {
    my ($self, %args) = @_;
    eval { $self->{root} = $self->_ins_rec($self->{root}, \%args); $self->{size}++; };
}
sub _ins_rec {
    my ($self, $n, $args) = @_;
    return NodoAVL->new(%{$args}) if !defined $n;
    my $nueva = $args->{numero_colegio}; my $act = $n->get_numero_colegio();
    if ($nueva lt $act) { $n->set_left($self->_ins_rec($n->get_left(), $args)); }
    elsif ($nueva gt $act) { $n->set_right($self->_ins_rec($n->get_right(), $args)); }
    else { die "Ya existe"; }

    $self->_actualizar_altura($n);
    my $bal = $self->_obtener_balance($n);
    if ($bal > 1 && $nueva lt $n->get_left()->get_numero_colegio()) { return $self->_rot_der($n); }
    if ($bal < -1 && $nueva gt $n->get_right()->get_numero_colegio()) { return $self->_rot_izq($n); }
    if ($bal > 1 && $nueva gt $n->get_left()->get_numero_colegio()) { $n->set_left($self->_rot_izq($n->get_left())); return $self->_rot_der($n); }
    if ($bal < -1 && $nueva lt $n->get_right()->get_numero_colegio()) { $n->set_right($self->_rot_der($n->get_right())); return $self->_rot_izq($n); }
    return $n;
}

# --- RECORRIDOS ---
sub in_orden { my @r; $_[0]->_in_rec($_[0]->{root}, \@r); return \@r; }
sub _in_rec { return if !defined $_[1]; $_[0]->_in_rec($_[1]->get_left(), $_[2]); push @{$_[2]}, $_[1]; $_[0]->_in_rec($_[1]->get_right(), $_[2]); }

sub pre_orden { my @r; $_[0]->_pre_rec($_[0]->{root}, \@r); return \@r; }
sub _pre_rec { return if !defined $_[1]; push @{$_[2]}, $_[1]; $_[0]->_pre_rec($_[1]->get_left(), $_[2]); $_[0]->_pre_rec($_[1]->get_right(), $_[2]); }

sub post_orden { my @r; $_[0]->_post_rec($_[0]->{root}, \@r); return \@r; }
sub _post_rec { return if !defined $_[1]; $_[0]->_post_rec($_[1]->get_left(), $_[2]); $_[0]->_post_rec($_[1]->get_right(), $_[2]); push @{$_[2]}, $_[1]; }

# --- BUSCAR Y ELIMINAR ---
sub buscar {
    my ($self, $c) = @_;
    my $curr = $self->{root};
    while (defined $curr) {
        if ($c eq $curr->get_numero_colegio()) { return $curr; }
        $curr = ($c lt $curr->get_numero_colegio()) ? $curr->get_left() : $curr->get_right();
    }
    return undef;
}

sub eliminar {
    my ($self, $c) = @_;
    eval { $self->{root} = $self->_elim_rec($self->{root}, $c); $self->{size}--; };
}
sub _elim_rec {
    my ($self, $n, $c) = @_;
    return undef if !defined $n;
    if ($c lt $n->get_numero_colegio()) { $n->set_left($self->_elim_rec($n->get_left(), $c)); }
    elsif ($c gt $n->get_numero_colegio()) { $n->set_right($self->_elim_rec($n->get_right(), $c)); }
    else {
        if (!defined $n->get_left() || !defined $n->get_right()) {
            my $t = defined $n->get_left() ? $n->get_left() : $n->get_right();
            $n = $t;
        } else {
            my $succ = $self->_min($n->get_right());
            $n->set_datos($succ);
            $n->set_right($self->_elim_rec($n->get_right(), $succ->get_numero_colegio()));
        }
    }
    return undef if !defined $n;
    $self->_actualizar_altura($n);
    my $bal = $self->_obtener_balance($n);
    if ($bal > 1 && $self->_obtener_balance($n->get_left()) >= 0) { return $self->_rot_der($n); }
    if ($bal > 1 && $self->_obtener_balance($n->get_left()) < 0) { $n->set_left($self->_rot_izq($n->get_left())); return $self->_rot_der($n); }
    if ($bal < -1 && $self->_obtener_balance($n->get_right()) <= 0) { return $self->_rot_izq($n); }
    if ($bal < -1 && $self->_obtener_balance($n->get_right()) > 0) { $n->set_right($self->_rot_der($n->get_right())); return $self->_rot_izq($n); }
    return $n;
}
sub _min { my $c = $_[1]; while(defined $c->get_left()){ $c = $c->get_left(); } return $c; }

1;