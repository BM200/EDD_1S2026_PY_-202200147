package NodoHash;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        numero_colegio  => $args{numero_colegio},
        nombre_completo => $args{nombre_completo},
        tipo_usuario    => $args{tipo_usuario},
        departamento    => $args{departamento},
        especialidad    => $args{especialidad},
        siguiente       => undef  # Puntero para el encadenamiento
    };
    bless $self, $class;
    return $self;
}

1;