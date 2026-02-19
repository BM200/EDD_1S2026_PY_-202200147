package NodoMedicamento;

use strict;
use warnings;
use Moo; #
#atributos de datos

has 'codigo'           => (is => 'rw');
has 'nombre'           => (is => 'rw');
has 'principio_activo' => (is => 'rw');
has 'laboratorio'      => (is => 'rw');
has 'precio'           => (is => 'rw');
has 'stock'            => (is => 'rw');
has 'vencimiento'      => (is => 'rw');
has 'minimo'           => (is => 'rw');

# Punteros (rw = read/write)
has 'siguiente'        => (is => 'rw');
has 'anterior'         => (is => 'rw');

1;

