package NodoMatrizDato;
use strict;
use warnings;

sub new {
    my ($class, $fila, $col, $valor) = @_;
    my $self = {
        fila  => $fila,
        col   => $col,
        valor => $valor,
        # Punteros
        up    => undef,
        down  => undef,
        left  => undef,
        right => undef
    };
    bless $self, $class;
    return $self;
}

# Getters
sub get_fila  { return $_[0]->{fila}; }
sub get_col   { return $_[0]->{col}; }
sub get_valor { return $_[0]->{valor}; }
sub get_up    { return $_[0]->{up}; }
sub get_down  { return $_[0]->{down}; }
sub get_left  { return $_[0]->{left}; }
sub get_right { return $_[0]->{right}; }

# Setters
sub set_valor { $_[0]->{valor} = $_[1]; }
sub set_up    { $_[0]->{up}    = $_[1]; }
sub set_down  { $_[0]->{down}  = $_[1]; }
sub set_left  { $_[0]->{left}  = $_[1]; }
sub set_right { $_[0]->{right} = $_[1]; }

1;