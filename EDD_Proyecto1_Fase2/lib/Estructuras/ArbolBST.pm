package ArbolBST;
use strict;
use warnings;
use lib '../Nodos';
use NodoBST;

sub new {
    my ($class) = @_;
    my $self = { root => undef, size => 0 };
    bless $self, $class;
    return $self;
}

sub is_empty { return !defined($_[0]->{root}); }

# --- INSERCIÓN ---
sub insertar {
    my ($self, %args) = @_;
    if (!defined($self->{root})) {
        $self->{root} = NodoBST->new(%args);
        $self->{size}++;
        return;
    }
    my $ins = $self->_ins_rec($self->{root}, \%args);
    $self->{size}++ if $ins;
}

sub _ins_rec {
    my ($self, $n, $args) = @_;
    my $nueva = $args->{codigo}; my $act = $n->get_codigo();
    if ($nueva lt $act) {
        if (!defined($n->get_left())) { $n->set_left(NodoBST->new(%{$args})); return 1; }
        else { return $self->_ins_rec($n->get_left(), $args); }
    } elsif ($nueva gt $act) {
        if (!defined($n->get_right())) { $n->set_right(NodoBST->new(%{$args})); return 1; }
        else { return $self->_ins_rec($n->get_right(), $args); }
    }
    return 0;
}

# --- RECORRIDOS (LOS 3 OBLIGATORIOS) ---

sub in_orden {
    my ($self) = @_;
    my @res;
    $self->_in_rec($self->{root}, \@res);
    return \@res;
}
sub _in_rec {
    return if !defined $_[1];
    $_[0]->_in_rec($_[1]->get_left(), $_[2]);
    push @{$_[2]}, $_[1];
    $_[0]->_in_rec($_[1]->get_right(), $_[2]);
}

sub pre_orden {
    my ($self) = @_;
    my @res;
    $self->_pre_rec($self->{root}, \@res);
    return \@res;
}
sub _pre_rec {
    return if !defined $_[1];
    push @{$_[2]}, $_[1]; # RAÍZ PRIMERO
    $_[0]->_pre_rec($_[1]->get_left(), $_[2]);
    $_[0]->_pre_rec($_[1]->get_right(), $_[2]);
}

sub post_orden {
    my ($self) = @_;
    my @res;
    $self->_post_rec($self->{root}, \@res);
    return \@res;
}
sub _post_rec {
    return if !defined $_[1];
    $_[0]->_post_rec($_[1]->get_left(), $_[2]);
    $_[0]->_post_rec($_[1]->get_right(), $_[2]);
    push @{$_[2]}, $_[1]; # RAÍZ AL FINAL
}

# --- BÚSQUEDA ---
sub buscar {
    my ($self, $c) = @_;
    my $curr = $self->{root};
    while (defined $curr) {
        return $curr if $c eq $curr->get_codigo();
        $curr = ($c lt $curr->get_codigo()) ? $curr->get_left() : $curr->get_right();
    }
    return undef;
}

# --- ELIMINACIÓN ---
sub eliminar {
    my ($self, $c) = @_;
    $self->{root} = $self->_elim_rec($self->{root}, $c);
}
sub _elim_rec {
    my ($self, $n, $c) = @_;
    return undef if !defined $n;
    if ($c lt $n->get_codigo()) { $n->set_left($self->_elim_rec($n->get_left(), $c)); }
    elsif ($c gt $n->get_codigo()) { $n->set_right($self->_elim_rec($n->get_right(), $c)); }
    else {
        if (!defined $n->get_left() || !defined $n->get_right()) {
            $n = defined $n->get_left() ? $n->get_left() : $n->get_right();
        } else {
            my $s = $n->get_right(); while(defined $s->get_left()){ $s = $s->get_left(); }
            $n->set_datos($s);
            $n->set_right($self->_elim_rec($n->get_right(), $s->get_codigo()));
        }
    }
    return $n;
}

1;