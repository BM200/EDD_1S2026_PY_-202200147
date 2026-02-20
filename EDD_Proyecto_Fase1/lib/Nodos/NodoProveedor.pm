package NodoProveedor;

use strict; 
use warnings;
use Moo;

#Datos del proveedor

has 'nit'     => (is => 'rw');
has 'nombre'  => (is => 'rw');
has 'contacto' => (is => 'rw');
has 'direccion' => (is => 'rw');
has 'telefono' => (is => 'rw');

#puntero lista circular. (al siguiente proveedor. )
has 'siguiente' => (is => 'rw');

#cabeza de la lista interna. registra el historial de entregas del proveedor.
has 'primera_entrega' => (is => 'rw', default => sub { undef });

1;
