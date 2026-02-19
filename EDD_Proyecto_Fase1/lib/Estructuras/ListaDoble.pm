package ListaDoble;

use strict;
use warnings;
use lib '../Nodos'; 
use NodoMedicamento; #Importamos el módulo del nodo para usarlo en la lista.
use Moo;

# Atributos de la lista
has 'primero' => (is => 'rw', default => sub { undef });
has 'ultimo'  => (is => 'rw', default => sub { undef });
has 'size'    => (is => 'rw', default => sub { 0 });

#Metodo para verifiar si esta vacia

sub esta_vacia {
    my ($self) = @_;
    return !defined $self->primero;
}

#Metodo:Insertar ordenado 

sub insertar {
    my ($self, %args) = @_;
    #crear el objeto 
    my $nuevo = NodoMedicamento->new(%args);

    # Caso 1: Lista vacia
    if ($self->esta_vacia) {
        $self->primero($nuevo);
        $self->ultimo($nuevo);
    }
    else {
        my $actual = $self->primero;
        
        # Caso 2: Insertar al inicio (nuevo < actual)
        if ($nuevo->codigo lt $actual->codigo) {
            $nuevo->siguiente($self->primero);
            $self->primero->anterior($nuevo);
            $self->primero($nuevo);
        }
        else {
            # Recorrer buscando la posicion
            while (defined $actual->siguiente && 
                   $actual->siguiente->codigo lt $nuevo->codigo) {
                $actual = $actual->siguiente;
            }
            
            # Caso 3: Insertar al final
            if (!defined $actual->siguiente) {
                $actual->siguiente($nuevo);
                $nuevo->anterior($actual);
                $self->ultimo($nuevo);
            }
            # Caso 4: Insertar en medio
            else {
                my $siguiente_nodo = $actual->siguiente;
                
                # Conectar nuevo con anterior (actual)
                $actual->siguiente($nuevo);
                $nuevo->anterior($actual);
                
                # Conectar nuevo con siguiente
                $nuevo->siguiente($siguiente_nodo);
                $siguiente_nodo->anterior($nuevo);
            }
        }
    }
    # Aumentar tamaño
    $self->size($self->size + 1);
}

# Metodo para imprimir (Debugging)
sub imprimir_consola {
    my ($self) = @_;
    print "\n--- Inventario Actual ---\n";
    return if $self->esta_vacia;
    
    my $actual = $self->primero;
    while (defined $actual) {
        print "COD: " . $actual->codigo . " | " . $actual->nombre . 
              " | Stock: " . $actual->stock . "\n";
        $actual = $actual->siguiente;
    }
    print "-------------------------\n";
}

1;




