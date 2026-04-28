package NodoArbolB;
use strict;
use warnings;

sub new {
    my ($class, $es_hoja) = @_;
    my $self = {
        es_hoja => $es_hoja,
        claves  => [], # Array de HashRefs
        hijos   => [], # Array de Nodos
    };
    bless $self, $class;
    return $self;
}

sub get_es_hoja { return $_[0]->{es_hoja}; }
sub get_claves  { return $_[0]->{claves}; }
sub get_hijos   { return $_[0]->{hijos}; }
sub cantidad_claves { return scalar @{$_[0]->{claves}}; }

1;