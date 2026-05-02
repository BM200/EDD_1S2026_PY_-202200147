package TablaHash;
use strict;
use warnings;
use lib 'lib/Nodos';
use NodoHash;

sub new {
    my ($class) = @_;
    # Inicializamos 5 buckets (0 para otros, 1-4 para los tipos oficiales)
    my $self = {
        buckets => [undef, undef, undef, undef, undef],
        size    => 5
    };
    bless $self, $class;
    return $self;
}

# --- FUNCIÓN HASH ---
# Convierte "TIPO-01" en el índice 1, "TIPO-02" en el 2, etc.
sub _hash_function {
    my ($self, $tipo) = @_;
    if ($tipo =~ /TIPO-0(\d)/) {
        return $1; # Retorna el número del tipo
    }
    return 0; # Bucket por defecto para errores o tipos desconocidos
}

# --- INSERTAR ---
sub insertar {
    my ($self, $user) = @_;
    my $indice = $self->_hash_function($user->{tipo_usuario});
    
    my $nuevo = NodoHash->new(%{$user});
    
    # Si el bucket está vacío, insertamos el primero
    if (!defined $self->{buckets}->[$indice]) {
        $self->{buckets}->[$indice] = $nuevo;
    } 
    else {
        # Colisión: Insertamos al inicio de la lista (Encadenamiento)
        $nuevo->{siguiente} = $self->{buckets}->[$indice];
        $self->{buckets}->[$indice] = $nuevo;
    }
}

# --- OBTENER PERSONAL POR TIPO ---
# Este método lo usará la API para enviarle los datos a Angular
sub obtener_por_tipo {
    my ($self, $tipo) = @_;
    my $indice = $self->_hash_function($tipo);
    my @lista;
    
    my $actual = $self->{buckets}->[$indice];
    while (defined $actual) {
        push @lista, {
            numero_colegio  => $actual->{numero_colegio},
            nombre_completo => $actual->{nombre_completo},
            departamento    => $actual->{departamento},
            especialidad    => $actual->{especialidad}
        };
        $actual = $actual->{siguiente};
    }
    return \@lista; # Retorna una referencia al arreglo de usuarios
}

# --- REINICIAR TABLA (Para carga masiva) ---
sub limpiar {
    my ($self) = @_;
    $self->{buckets} = [undef, undef, undef, undef, undef];
}

1;