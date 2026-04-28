package NodoMatrizCabecera;
use strict;
use warnings;

sub new {
    my ($class, $indice) = @_;
    my $self = {
        label => $indice,      # El índice numérico (0, 1, 2...)
        next  => undef,        # Siguiente cabecera
        right => undef,        # Puntero a datos (si es cabecera de fila)
        down  => undef,        # Puntero a datos (si es cabecera de columna)
        
        nombre_real => ""      # Para guardar el texto (Ej: "LabFarma")
    };
    bless $self, $class;
    return $self;
}

# Métodos requeridos por tu lógica
sub get_label { return $_[0]->{label}; }
sub get_next  { return $_[0]->{next}; }
sub set_next  { $_[0]->{next} = $_[1]; }

# Accesos a la matriz
sub get_right { return $_[0]->{right}; }
sub set_right { $_[0]->{right} = $_[1]; }

sub get_down  { return $_[0]->{down}; }
sub set_down  { $_[0]->{down} = $_[1]; }

# Extra: Nombre real
sub set_nombre_real { $_[0]->{nombre_real} = $_[1]; }
sub get_nombre_real { return $_[0]->{nombre_real}; }

1;