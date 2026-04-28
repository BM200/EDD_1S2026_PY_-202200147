package PanelUsuario;
use strict;
use warnings;
use utf8;
use Gtk3;
use Encode qw(decode_utf8);

sub new {
    my ($class, $db, $user_nodo, $parent) = @_;
    my $self = {
        db      => $db,
        user    => $user_nodo,
        parent  => $parent,
        ventana => undef,
    };
    bless $self, $class;
    $self->_construir_interfaz();
    return $self;
}

sub _construir_interfaz {
    my ($self) = @_;
    my $u = $self->{user};
    my $depto = $u->get_departamento();

    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("EDD MedTrack - Panel Médico");
    $ventana->set_default_size(700, 550);
    $ventana->set_position('center');
    $ventana->signal_connect(destroy => sub { $self->{parent}->mostrar(); });
    $self->{ventana} = $ventana;

    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(15);
    $ventana->add($vbox);

    # Saludo Personalizado
    my $lbl_bv = Gtk3::Label->new();
    $lbl_bv->set_markup("<span size='large'>Bienvenido(a), <b>" . decode_utf8($u->get_nombre_completo()) . "</b></span>\n" .
                        "<span color='blue'>Departamento: $depto</span>");
    $vbox->pack_start($lbl_bv, 0, 0, 5);

    my $btn_logout = Gtk3::Button->new_with_label("Cerrar Sesión");
    $btn_logout->signal_connect(clicked => sub { $self->{ventana}->destroy(); $self->{parent}->mostrar(); });
    $vbox->pack_start($btn_logout, 0, 0, 0);

    my $notebook = Gtk3::Notebook->new();
    $vbox->pack_start($notebook, 1, 1, 0);

    # --- LÓGICA DE PERMISOS (PAGINA 6 DEL PDF) ---
    
    # 1. Medicamentos: Solo para DEP-MED y DEP-FAR
    if ($depto eq 'DEP-MED' || $depto eq 'DEP-FAR') {
        $notebook->append_page($self->_crear_vista_consulta('Medicamentos'), Gtk3::Label->new("Medicamentos"));
    }

    # 2. Suministros: Solo para DEP-MED y DEP-CIR
    if ($depto eq 'DEP-MED' || $depto eq 'DEP-CIR') {
        $notebook->append_page($self->_crear_vista_consulta('Suministros'), Gtk3::Label->new("Suministros"));
    }

    # 3. Equipos: Solo para DEP-CIR y DEP-LAB
    if ($depto eq 'DEP-CIR' || $depto eq 'DEP-LAB') {
        $notebook->append_page($self->_crear_vista_consulta('Equipos'), Gtk3::Label->new("Equipos"));
    }

    # 4. Perfil: Disponible para todos
    $notebook->append_page($self->_crear_pestana_perfil(), Gtk3::Label->new("Mi Perfil"));
}

sub mostrar { $_[0]->{ventana}->show_all(); }

# --- VISTA DE BÚSQUEDA Y DISPONIBILIDAD ---
sub _crear_vista_consulta {
    my ($self, $tipo) = @_;
    my $vbox = Gtk3::Box->new('vertical', 15);
    $vbox->set_border_width(20);

    # Instrucción superior
    my $lbl_inst = Gtk3::Label->new("Ingrese el código para verificar disponibilidad de $tipo:");
    $vbox->pack_start($lbl_inst, 0, 0, 0);

    # Barra de búsqueda
    my $hbox = Gtk3::Box->new('horizontal', 5);
    my $txt_bus = Gtk3::Entry->new();
    $txt_bus->set_placeholder_text("Ej: MED-001");
    $hbox->pack_start($txt_bus, 1, 1, 0);
    
    my $btn_bus = Gtk3::Button->new_with_label("Verificar");
    $hbox->pack_start($btn_bus, 0, 0, 0);
    $vbox->pack_start($hbox, 0, 0, 0);

    # Área de resultados (Label con formato)
    my $lbl_res = Gtk3::Label->new("");
    $lbl_res->set_justify('center');
    $vbox->pack_start($lbl_res, 1, 1, 0);

    # --- EVENTO DE BÚSQUEDA ---
    $btn_bus->signal_connect(clicked => sub {
        my $id = $txt_bus->get_text();
        my $info = "No se encontró el registro: $id";
        my $es_critico = 0;

        if ($tipo eq 'Medicamentos') {
            # Búsqueda en la Lista Doble (Fase 1)
            my $nodo = $self->{db}->{medicamentos}->buscar($id);
            if (defined $nodo) {
                my $nombre = decode_utf8($nodo->get_nombre());
                my $stock = $nodo->get_stock();
                my $minimo = $nodo->get_minimo();
                
                $info = "PRODUCTO: $nombre\nSTOCK: $stock\nVENCE: " . $nodo->get_vencimiento();
                
                # Alerta de Stock Bajo (Pág 15 del PDF)
                if ($stock <= $minimo) {
                    $info .= "\n⚠️ ALERTA: BAJO STOCK (Mínimo: $minimo)";
                    $es_critico = 1;
                }
            }
        } 
        elsif ($tipo eq 'Equipos') {
            # Búsqueda en Árbol BST
            my $n = $self->{db}->{equipos}->buscar($id);
            if ($n) {
                $info = "EQUIPO: " . decode_utf8($n->get_nombre()) . "\nSTOCK: " . $n->get_cantidad() . "\nFABRICANTE: " . decode_utf8($n->get_fabricante());
                $es_critico = 1 if $n->get_cantidad() <= $n->get_minimo();
            }
        } 
        elsif ($tipo eq 'Suministros') {
            # Búsqueda en Árbol B (Devuelve HashRef)
            my $n = $self->{db}->{suministros}->buscar($id);
            if ($n) {
                $info = "SUMINISTRO: " . decode_utf8($n->{nombre}) . "\nSTOCK: " . $n->{cantidad} . "\nPRECIO: Q" . $n->{precio};
                $es_critico = 1 if $n->{cantidad} <= $n->{nivel_minimo};
            }
        }

        # Cambiar color según el resultado
        if ($info =~ /No se encontró/) {
            $lbl_res->set_markup("<span size='x-large' color='gray'>$info</span>");
        } elsif ($es_critico) {
            $lbl_res->set_markup("<span size='x-large' color='red' weight='bold'>$info</span>");
        } else {
            $lbl_res->set_markup("<span size='x-large' color='darkgreen'>$info</span>");
        }
    });

    return $vbox;
}
# --- PESTAÑA PERFIL (EDITAR DATOS - FUNCIÓN 5) ---
sub _crear_pestana_perfil {
    my ($self) = @_;
    my $grid = Gtk3::Grid->new();
    $grid->set_row_spacing(15); $grid->set_column_spacing(10); $grid->set_border_width(30);

    $grid->attach(Gtk3::Label->new("Nombre Completo:"), 0, 0, 1, 1);
    my $txt_nom = Gtk3::Entry->new(); 
    $txt_nom->set_text(decode_utf8($self->{user}->get_nombre_completo()));
    $grid->attach($txt_nom, 1, 0, 1, 1);

    $grid->attach(Gtk3::Label->new("Nueva Contraseña:"), 0, 1, 1, 1);
    my $txt_pass = Gtk3::Entry->new(); 
    $txt_pass->set_visibility(0);
    $grid->attach($txt_pass, 1, 1, 1, 1);

    my $btn_save = Gtk3::Button->new_with_label("Guardar Cambios");
    $btn_save->signal_connect(clicked => sub {
        if ($txt_nom->get_text() eq "") {
            $self->_mostrar_alerta("Error", "El nombre no puede estar vacío.");
            return;
        }
        $self->{user}->{nombre_completo} = $txt_nom->get_text();
        if ($txt_pass->get_text() ne "") {
            $self->{user}->set_contrasena($txt_pass->get_text());
        }
        $self->_mostrar_alerta("Éxito", "Sus datos han sido actualizados en el sistema.");
    });
    $grid->attach($btn_save, 1, 2, 1, 1);

    return $grid;
}

sub _mostrar_alerta {
    my ($self, $t, $m) = @_;
    my $d = Gtk3::MessageDialog->new($self->{ventana}, ['modal'], 'info', 'ok', $m);
    $d->set_title($t); $d->show_all(); $d->run(); $d->destroy();
}

1;