package NodoEntrega;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        fecha      => $args{fecha},
        factura    => $args{factura},
        codigo_med => $args{codigo_med},
        cantidad   => $args{cantidad},
        siguiente  => undef
    };
    bless $self, $class;
    return $self;
}

# Getters
sub get_fecha      { return $_[0]->{fecha}; }
sub get_factura    { return $_[0]->{factura}; }
sub get_codigo_med { return $_[0]->{codigo_med}; }
sub get_cantidad   { return $_[0]->{cantidad}; }
sub get_siguiente  { return $_[0]->{siguiente}; }

# Setters
sub set_siguiente  { $_[0]->{siguiente} = $_[1]; }

1;