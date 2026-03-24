package NodoArbolB;
use strict;
use warnings;

sub new {
    my ($class, $es_hoja) = @_;
    my $self = {
        es_hoja => $es_hoja, # 1 (true) o 0 (false)
        claves  => [],       # Array que guardará hashes con los datos de los suministros (Max 3)
        hijos   => [],       # Array que guardará referencias a otros NodoArbolB (Max 4)
    };
    bless $self, $class;
    return $self;
}

# --- GETTERS & SETTERS ---
sub get_es_hoja { return $_[0]->{es_hoja}; }
sub set_es_hoja { $_[0]->{es_hoja} = $_[1]; }

sub get_claves  { return $_[0]->{claves}; }
sub get_hijos   { return $_[0]->{hijos}; }

# --- MÉTODOS AUXILIARES MANUALES ---
# Devuelven cuántos elementos hay actualmente en los arreglos
sub cantidad_claves {
    my ($self) = @_;
    return scalar @{$self->{claves}};
}

sub cantidad_hijos {
    my ($self) = @_;
    return scalar @{$self->{hijos}};
}

1;