package NodoSolicitud;
use strict;
use warnings;
use Moo;

#Datos de la solicitud
has 'id' => (is => 'rw'); #un numero  unico. 
has 'departamento' => (is => 'rw'); # por ejemplo urgencias. 
has 'codigo_med' => (is => 'rw'); 
has 'cantidad' => (is => 'rw');
has 'prioridad' => (is => 'rw'); 

# CAMPOS PARA HISTORIAL
has 'estado'       => (is => 'rw', default => 'Pendiente'); # Pendiente, Aprobada, Rechazada
has 'fecha'        => (is => 'rw'); # YYYY-MM-DD

#punteros(circular doble)
has 'siguiente' => (is => 'rw');
has 'anterior' => (is => 'rw');

1;
