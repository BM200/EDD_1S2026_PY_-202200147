package NodoMedicamento;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        codigo           => $args{codigo},
        nombre           => $args{nombre},
        principio_activo => $args{principio_activo},
        fabricante       => $args{fabricante},
        precio           => $args{precio},
        stock            => $args{stock},
        vencimiento      => $args{vencimiento},
        minimo           => $args{minimo},
        siguiente        => undef,
        anterior         => undef
    };
    bless $self, $class;
    return $self;
}

# --- GETTERS ---
sub get_codigo           { return $_[0]->{codigo}; }
sub get_nombre           { return $_[0]->{nombre}; }
sub get_principio_activo { return $_[0]->{principio_activo}; }
sub get_fabricante       { return $_[0]->{fabricante}; }
sub get_precio           { return $_[0]->{precio}; }
sub get_stock            { return $_[0]->{stock}; }
sub get_vencimiento      { return $_[0]->{vencimiento}; }
sub get_minimo           { return $_[0]->{minimo}; }
sub get_siguiente        { return $_[0]->{siguiente}; }
sub get_anterior         { return $_[0]->{anterior}; }

# --- SETTERS ---
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }
sub set_anterior  { $_[0]->{anterior} = $_[1]; }
sub set_stock     { $_[0]->{stock} = $_[1]; }

1;