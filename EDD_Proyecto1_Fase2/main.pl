#!/usr/bin/perl
use strict;
use warnings;
use utf8; # Vital para que GTK muestre acentos correctamente
use Gtk3 -init;


# --- RUTAS DE LIBRERÍAS ---
use lib 'lib/Nodos';
use lib 'lib/Estructuras';
use lib 'lib/Utils';
use lib 'lib/GUI';

# --- IMPORTS DE ESTRUCTURAS ---
use ListaDoble;
use ArbolBST;
use ArbolAVL;
use ArbolB;
use ListaDobleCircularProveedores;
use MatrizDispersa;

# --- IMPORTS DE INTERFAZ ---
use VentanaLogin;
use PanelAdmin;

# --- INICIALIZAR BASE DE DATOS EN MEMORIA ---
# Empaquetamos todas las estructuras en un solo HashRef para 
# pasarlo fácilmente de una ventana a otra sin usar variables globales.
my $db = {
    medicamentos => ListaDoble->new(), 
    equipos      => ArbolBST->new(),
    suministros  => ArbolB->new(),
    proveedores  => ListaDobleCircularProveedores->new(),
    usuarios     => ArbolAVL->new(),
    matriz       => MatrizDispersa->new(),
};

# --- ARRANCAR APLICACIÓN ---
print "Iniciando EDD MedTrack GUI...\n";

# Instanciamos la ventana de login pasándole la base de datos
my $login_app = VentanaLogin->new($db);
$login_app->mostrar();

# Bucle principal de GTK (Mantiene la ventana abierta)
Gtk3::main();