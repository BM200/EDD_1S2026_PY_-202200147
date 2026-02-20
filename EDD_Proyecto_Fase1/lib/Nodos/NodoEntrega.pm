package NodoEntrega;
use strict;
use warnings;
use Moo;

#datos de la entrega

has 'fecha'      => (is => 'rw');
has 'factura'    => (is => 'rw');
has 'codigo_med' => (is => 'rw');
has 'cantidad'   => (is => 'rw');

# Puntero lista simple
has 'siguiente'  => (is => 'rw');

1;