package NodoEncabezado;
use strict;
use warnings;
use Moo;

has 'id'        => (is => 'rw'); # El dato clave (Nombre Lab o Nombre Med)
has 'siguiente' => (is => 'rw'); # Siguiente encabezado
has 'acceso'    => (is => 'rw'); # Acceso al primer nodo de datos de esta fila/col

1;
