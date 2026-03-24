package NodoAVL;
use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = {
        # Datos del Personal Médico
        numero_colegio  => $args{numero_colegio},
        nombre_completo => $args{nombre_completo},
        tipo_usuario    => $args{tipo_usuario},
        departamento    => $args{departamento},
        especialidad    => $args{especialidad},
        contrasena      => $args{contrasena},
        
        # Atributos de estructura AVL
        left   => undef,
        right  => undef,
        height => 1, # Todos los nodos nacen con altura 1
    };
    bless $self, $class;
    return $self;
}

# --- GETTERS ---
sub get_numero_colegio  { return $_[0]->{numero_colegio}; }
sub get_nombre_completo { return $_[0]->{nombre_completo}; }
sub get_tipo_usuario    { return $_[0]->{tipo_usuario}; }
sub get_departamento    { return $_[0]->{departamento}; }
sub get_especialidad    { return $_[0]->{especialidad}; }
sub get_contrasena      { return $_[0]->{contrasena}; }

sub get_left   { return $_[0]->{left}; }
sub get_right  { return $_[0]->{right}; }
sub get_height { return $_[0]->{height}; }

# --- SETTERS ---
sub set_left   { $_[0]->{left} = $_[1]; }
sub set_right  { $_[0]->{right} = $_[1]; }
sub set_height { $_[0]->{height} = $_[1]; }
sub set_contrasena { $_[0]->{contrasena} = $_[1]; } # Útil para la Función 5 (Editar perfil)

# Setter especial para la eliminación (copiar datos del sucesor)
sub set_datos {
    my ($self, $nodo_origen) = @_;
    $self->{numero_colegio}  = $nodo_origen->get_numero_colegio();
    $self->{nombre_completo} = $nodo_origen->get_nombre_completo();
    $self->{tipo_usuario}    = $nodo_origen->get_tipo_usuario();
    $self->{departamento}    = $nodo_origen->get_departamento();
    $self->{especialidad}    = $nodo_origen->get_especialidad();
    $self->{contrasena}      = $nodo_origen->get_contrasena();
}

sub es_hoja {
    my ($self) = @_;
    return (!defined($self->{left}) && !defined($self->{right})) ? 1 : 0;
}

1;