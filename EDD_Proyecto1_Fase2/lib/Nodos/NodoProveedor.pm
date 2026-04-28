package NodoProveedor;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        nit       => $args{nit},
        nombre    => $args{nombre},
        telefono  => $args{telefono},
        direccion => $args{direccion},
        
        # Doble Circularidad
        siguiente => undef,
        anterior  => undef,
        
        # Puntero a la lista interna de entregas
        primera_entrega => undef
    };
    bless $self, $class;
    return $self;
}

# --- GETTERS ---
sub get_nit       { return $_[0]->{nit}; }
sub get_nombre    { return $_[0]->{nombre}; }
sub get_telefono  { return $_[0]->{telefono}; }
sub get_direccion { return $_[0]->{direccion}; }

sub get_siguiente { return $_[0]->{siguiente}; }
sub get_anterior  { return $_[0]->{anterior}; }
sub get_primera_entrega { return $_[0]->{primera_entrega}; }

# --- SETTERS ---
sub set_siguiente { $_[0]->{siguiente} = $_[1]; }
sub set_anterior  { $_[0]->{anterior} = $_[1]; }
sub set_primera_entrega { $_[0]->{primera_entrega} = $_[1]; }

1;