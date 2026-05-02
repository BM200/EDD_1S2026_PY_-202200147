use Mojolicious::Lite;
use lib 'lib/Estructuras';
use lib 'lib/Nodos';
use TablaHash;

# Instancia global de la Tabla Hash
my $tabla_usuarios = TablaHash->new();

# --- CONFIGURACIÓN DE CORS ---
# Esto es obligatorio para que Angular pueda conectarse
hook after_dispatch => sub {
  my $c = shift;
  $c->res->headers->header('Access-Control-Allow-Origin' => '*');
  $c->res->headers->header('Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS');
  $c->res->headers->header('Access-Control-Allow-Headers' => 'Content-Type, Authorization');
};

# Responder a peticiones OPTIONS (preflight)
options '*' => sub {
  my $c = shift;
  $c->render(text => '');
};

# --- RUTAS DE LA API ---

# 1. Login
post '/login' => sub {
  my $c = shift;
  my $params = $c->req->json;
  my $user = $params->{usuario};
  my $pass = $params->{password};

  # Lógica de Administrador (Hardcodeada según PDF)
  if ($user eq 'AdminHospital' && $pass eq 'MedTrack2026') {
    return $c->render(json => { status => 'success', rol => 'admin', nombre => 'Administrador' });
  }

  # Lógica para Médicos (Aquí buscaremos en la Tabla Hash después)
  # Por ahora, un éxito genérico para probar la conexión
  $c->render(json => { status => 'error', mensaje => 'Usuario no cargado en Tabla Hash' });
};

app->start;