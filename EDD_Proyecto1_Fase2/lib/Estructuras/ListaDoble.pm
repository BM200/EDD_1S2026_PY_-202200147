package ListaDoble;
use strict;
use warnings;
use lib '../Nodos';
use NodoMedicamento;

sub new {
    my ($class) = @_;
    my $self = { primero => undef, ultimo => undef, size => 0 };
    bless $self, $class;
    return $self;
}

sub insertar {
    my ($self, %args) = @_;
    my $nuevo = NodoMedicamento->new(%args);
    if (!defined $self->{primero}) {
        $self->{primero} = $nuevo;
        $self->{ultimo} = $nuevo;
    } else {
        # Inserción al final simplificada (puedes usar tu lógica de ordenamiento de F1 si prefieres)
        my $ult = $self->{ultimo};
        $ult->set_siguiente($nuevo);
        $nuevo->set_anterior($ult);
        $self->{ultimo} = $nuevo;
    }
    $self->{size}++;
}

sub buscar {
    my ($self, $codigo) = @_;
    my $actual = $self->{primero};
    while (defined $actual) {
        if ($actual->get_codigo() eq $codigo) {
            return $actual;
        }
        $actual = $actual->get_siguiente();
    }
    return undef;
}

1;



