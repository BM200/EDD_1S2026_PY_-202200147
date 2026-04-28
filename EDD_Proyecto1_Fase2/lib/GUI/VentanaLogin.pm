package VentanaLogin;
use strict;
use warnings;
use utf8;
use Gtk3;
use PanelAdmin;
use PanelUsuario;

sub new {
    my ($class, $db) = @_;
    my $self = {
        db      => $db,
        ventana => undef,
    };
    bless $self, $class;
    $self->_construir_interfaz();
    return $self;
}

sub _construir_interfaz {
    my ($self) = @_;
    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Iniciar Sesión");
    $ventana->set_default_size(400, 350);
    $ventana->set_position('center');
    $ventana->set_border_width(20);
    $ventana->signal_connect(destroy => sub { Gtk3::main_quit() });
    $self->{ventana} = $ventana;

    my $vbox = Gtk3::Box->new('vertical', 10);
    $ventana->add($vbox);

    my $titulo = Gtk3::Label->new();
    $titulo->set_markup("<span size='x-large' weight='bold'>EDD MEDTRACK</span>\n<span size='small'>Hospital General San Carlos</span>");
    $vbox->pack_start($titulo, 0, 0, 10);

    $vbox->pack_start(Gtk3::Label->new("USUARIO:"), 0, 0, 0);
    my $txt_usuario = Gtk3::Entry->new();
    $vbox->pack_start($txt_usuario, 0, 0, 5);

    $vbox->pack_start(Gtk3::Label->new("CONTRASEÑA:"), 0, 0, 0);
    my $txt_pass = Gtk3::Entry->new();
    $txt_pass->set_visibility(0);
    $vbox->pack_start($txt_pass, 0, 0, 5);

    my $btn_login = Gtk3::Button->new_with_label("Iniciar Sesión");
    $btn_login->signal_connect(clicked => sub {
        $self->_intentar_login($txt_usuario->get_text(), $txt_pass->get_text());
    });
    $vbox->pack_start($btn_login, 0, 0, 15);
}

sub mostrar { $_[0]->{ventana}->show_all(); }

sub _intentar_login {
    my ($self, $usuario, $pass) = @_;

    # 1. Admin
    if ($usuario eq "AdminHospital" && $pass eq "MedTrack2025") {
        $self->{ventana}->hide();
        my $panel = PanelAdmin->new($self->{db}, $self); # Pasamos $self como padre
        $panel->mostrar();
        return;
    }

    # 2. Médico (AVL)
    my $nodo = $self->{db}->{usuarios}->buscar($usuario);
    if (defined $nodo && $nodo->get_contrasena() eq $pass) {
        $self->{ventana}->hide();
        my $panel_user = PanelUsuario->new($self->{db}, $nodo, $self); # Pasamos $self como padre
        $panel_user->mostrar();
        return;
    }
    $self->_mostrar_alerta("Error", "Credenciales incorrectas.");
}

sub _mostrar_alerta {
    my ($self, $titulo, $mensaje) = @_;
    my $dialog = Gtk3::MessageDialog->new($self->{ventana}, ['modal'], ($titulo eq 'Error' ? 'error' : 'info'), 'ok', $mensaje);
    $dialog->set_title($titulo); $dialog->show_all(); $dialog->run(); $dialog->destroy();
}

1;