use strict;
use warnings;
use lib 'lib/Nodos';
use lib 'lib/Estructuras';
use ArbolBST;

my $arbol = ArbolBST->new();

# Insertar datos desordenados
$arbol->insertar(codigo => "EQU-005", nombre => "Rayos X");
$arbol->insertar(codigo => "EQU-002", nombre => "Bisturí Laser");
$arbol->insertar(codigo => "EQU-008", nombre => "Resonancia");
$arbol->insertar(codigo => "EQU-001", nombre => "Monitor");

print "\nRecorrido IN-ORDEN (Debe salir ordenado de 001 a 008):\n";
my $nodos = $arbol->in_orden();
foreach my $nodo (@$nodos) {
    print "- " . $nodo->codigo . " : " . $nodo->nombre . "\n";
}