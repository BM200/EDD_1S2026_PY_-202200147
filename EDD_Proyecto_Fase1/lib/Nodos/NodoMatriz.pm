package NodoMatriz;
use strict;
use warnings;
use Moo;

# Datos
has 'precio' => (is => 'rw');
has 'nombre_med' => (is => 'rw');
has 'nombre_lab' => (is => 'rw');

# Coordenadas (Para facilitar ordenamiento)
has 'x' => (is => 'rw'); # Columna (Laboratorio)
has 'y' => (is => 'rw'); # Fila (Medicamento)

# Punteros Ortogonales
has 'arriba'   => (is => 'rw');
has 'abajo'    => (is => 'rw');
has 'izquierda'=> (is => 'rw');
has 'derecha'  => (is => 'rw');

1;