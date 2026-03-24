package NodoBST;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        # Datos del equipo
        codigo        => $args{codigo},
        nombre        => $args{nombre},
        fabricante    => $args{fabricante},
        precio        => $args{precio},
        cantidad      => $args{cantidad},
        fecha_ingreso => $args{fecha_ingreso},
        minimo        => $args{minimo},
        
        # Punteros
        left          => undef,
        right         => undef
    };
    bless $self, $class;
    return $self;
}

# --- GETTERS ---
sub get_codigo        { return $_[0]->{codigo}; }
sub get_nombre        { return $_[0]->{nombre}; }
sub get_fabricante    { return $_[0]->{fabricante}; }
sub get_precio        { return $_[0]->{precio}; }
sub get_cantidad      { return $_[0]->{cantidad}; }
sub get_fecha_ingreso { return $_[0]->{fecha_ingreso}; }
sub get_minimo        { return $_[0]->{minimo}; }

sub get_left          { return $_[0]->{left}; }
sub get_right         { return $_[0]->{right}; }

# --- SETTERS ---
sub set_left          { $_[0]->{left} = $_[1]; }
sub set_right         { $_[0]->{right} = $_[1]; }

# Setter especial para la eliminación (copiar datos del sucesor)
sub set_datos {
    my ($self, $nodo_origen) = @_;
    $self->{codigo}        = $nodo_origen->get_codigo();
    $self->{nombre}        = $nodo_origen->get_nombre();
    $self->{fabricante}    = $nodo_origen->get_fabricante();
    $self->{precio}        = $nodo_origen->get_precio();
    $self->{cantidad}      = $nodo_origen->get_cantidad();
    $self->{fecha_ingreso} = $nodo_origen->get_fecha_ingreso();
    $self->{minimo}        = $nodo_origen->get_minimo();
}

sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

1;