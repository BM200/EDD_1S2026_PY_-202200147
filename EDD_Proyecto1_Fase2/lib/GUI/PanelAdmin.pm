package PanelAdmin;
use strict;
use warnings;
use utf8;
use Gtk3;
use LectorJSON;
use GeneradorGrafos;
use Encode qw(decode_utf8);

sub new {
    my ($class, $db, $parent) = @_;
    my $self = { db => $db, parent => $parent, ventana => undef };
    bless $self, $class;
    $self->_construir_interfaz();
    return $self;
}

sub _construir_interfaz {
    my ($self) = @_;
    my $ventana = Gtk3::Window->new('toplevel');
    $ventana->set_title("Panel Administrativo - EDD MedTrack");
    $ventana->set_default_size(1100, 750);
    $ventana->set_position('center');
    $ventana->signal_connect(destroy => sub { $self->{ventana}->destroy(); $self->{parent}->mostrar(); });
    $self->{ventana} = $ventana;

    my $vbox_main = Gtk3::Box->new('vertical', 0);
    $ventana->add($vbox_main);

    my $header = Gtk3::Box->new('horizontal', 10);
    $header->set_border_width(10);
    my $lbl_titulo = Gtk3::Label->new();
    $lbl_titulo->set_markup("<span size='large' weight='bold'>Panel de Administración General</span>");
    $header->pack_start($lbl_titulo, 0, 0, 0);

    my $btn_logout = Gtk3::Button->new_with_label("Cerrar Sesión");
    $btn_logout->signal_connect(clicked => sub { $self->{ventana}->destroy(); $self->{parent}->mostrar(); });
    $header->pack_end($btn_logout, 0, 0, 0);
    $vbox_main->pack_start($header, 0, 0, 0);

    my $notebook = Gtk3::Notebook->new();
    $vbox_main->pack_start($notebook, 1, 1, 0);

    $notebook->append_page($self->_crear_pestana_carga_masiva(), Gtk3::Label->new("Carga Masiva"));
    $notebook->append_page($self->_crear_pestana_personal_medico(), Gtk3::Label->new("Personal Médico (AVL)"));
    $notebook->append_page($self->_crear_pestana_equipos_bst(), Gtk3::Label->new("Equipos (BST)"));
    $notebook->append_page($self->_crear_pestana_suministros_b(), Gtk3::Label->new("Suministros (Árbol B)"));
    $notebook->append_page($self->_crear_pestana_proveedores(), Gtk3::Label->new("Proveedores"));
    $notebook->append_page($self->_crear_pestana_matriz(), Gtk3::Label->new("Relaciones (Matriz)"));
    $notebook->append_page($self->_crear_pestana_reportes(), Gtk3::Label->new("Reportes"));
    $notebook->append_page($self->_crear_pestana_info(), Gtk3::Label->new("Información"));
}

sub mostrar { $_[0]->{ventana}->show_all(); }

# --- 1. PESTAÑA CARGA ---
sub _crear_pestana_carga_masiva {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 20);
    $vbox->set_border_width(30);
    my $btn_inv = Gtk3::Button->new_with_label("Cargar Inventario Completo (JSON)");
    $btn_inv->signal_connect(clicked => sub { $self->_abrir_dialogo_archivo('inventario'); });
    $vbox->pack_start($btn_inv, 0, 0, 0);
    my $btn_usr = Gtk3::Button->new_with_label("Cargar Personal Médico (JSON)");
    $btn_usr->signal_connect(clicked => sub { $self->_abrir_dialogo_archivo('usuarios'); });
    $vbox->pack_start($btn_usr, 0, 0, 0);
    return $vbox;
}

# --- 2. PESTAÑA MÉDICOS (AVL) ---
sub _crear_pestana_personal_medico {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(15);
    my $hbox = Gtk3::Box->new('horizontal', 5);
    
    my $btn_new = Gtk3::Button->new_with_label("Registrar Nuevo");
    $btn_new->signal_connect(clicked => sub { $self->_mostrar_formulario_registro('Médico'); });
    $hbox->pack_start($btn_new, 0, 0, 5);

    my $txt_bus = Gtk3::Entry->new(); $hbox->pack_start($txt_bus, 1, 1, 5);
    my $btn_bus = Gtk3::Button->new_with_label("Buscar");
    $btn_bus->signal_connect(clicked => sub { my $n = $self->{db}->{usuarios}->buscar($txt_bus->get_text()); $self->_mostrar_alerta("Búsqueda", defined $n ? "Hallado: ".decode_utf8($n->get_nombre_completo()) : "No hallado"); });
    $hbox->pack_start($btn_bus, 0, 0, 5);

    my $btn_del = Gtk3::Button->new_with_label("Eliminar");
    $btn_del->signal_connect(clicked => sub { $self->{db}->{usuarios}->eliminar($txt_bus->get_text()); $self->_mostrar_alerta("Info", "Eliminado."); });
    $hbox->pack_start($btn_del, 0, 0, 5);

    my $cb = Gtk3::ComboBoxText->new(); foreach ("In-Orden","Pre-Orden","Post-Orden"){ $cb->append_text($_); } $cb->set_active(0);
    $hbox->pack_start($cb, 0, 0, 5);

    my $btn_act = Gtk3::Button->new_with_label("Refrescar");
    $hbox->pack_start($btn_act, 0, 0, 5);
    $vbox->pack_start($hbox, 0, 0, 5);

    my $list_store = Gtk3::ListStore->new('Glib::String','Glib::String','Glib::String','Glib::String');
    my $tv = Gtk3::TreeView->new_with_model($list_store);
    my @tit = ("Colegio","Nombre","Tipo","Depto");
    for my $i (0..3){ $tv->append_column(Gtk3::TreeViewColumn->new_with_attributes($tit[$i], Gtk3::CellRendererText->new(), text=>$i)); }
    my $s = Gtk3::ScrolledWindow->new(); $s->add($tv); $vbox->pack_start($s, 1, 1, 0);

    $btn_act->signal_connect(clicked => sub {
        $list_store->clear();
        my $t = $cb->get_active_text();
        my $nodes = ($t eq "Pre-Orden") ? $self->{db}->{usuarios}->pre_orden() : ($t eq "Post-Orden" ? $self->{db}->{usuarios}->post_orden() : $self->{db}->{usuarios}->in_orden());
        foreach (@$nodes){ $list_store->set($list_store->append(), 0, $_->get_numero_colegio(), 1, decode_utf8($_->get_nombre_completo()), 2, $_->get_tipo_usuario(), 3, $_->get_departamento()); }
    });
    return $vbox;
}

# --- 3. PESTAÑA EQUIPOS (BST) ---
sub _crear_pestana_equipos_bst {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(15);
    my $hbox = Gtk3::Box->new('horizontal', 5);
    
    my $btn_new = Gtk3::Button->new_with_label("Registrar Nuevo");
    $btn_new->signal_connect(clicked => sub { $self->_mostrar_formulario_registro('Equipo'); });
    $hbox->pack_start($btn_new, 0, 0, 5);

    my $txt_bus = Gtk3::Entry->new(); $hbox->pack_start($txt_bus, 1, 1, 5);
    my $btn_bus = Gtk3::Button->new_with_label("Buscar");
    $btn_bus->signal_connect(clicked => sub { my $n = $self->{db}->{equipos}->buscar($txt_bus->get_text()); $self->_mostrar_alerta("Búsqueda", defined $n ? "Equipo: ".decode_utf8($n->get_nombre()) : "No hallado"); });
    $hbox->pack_start($btn_bus, 0, 0, 5);

    my $btn_del = Gtk3::Button->new_with_label("Eliminar");
    $btn_del->signal_connect(clicked => sub { $self->{db}->{equipos}->eliminar($txt_bus->get_text()); $self->_mostrar_alerta("Info", "Eliminado."); });
    $hbox->pack_start($btn_del, 0, 0, 5);

    my $cb = Gtk3::ComboBoxText->new(); foreach ("In-Orden","Pre-Orden","Post-Orden"){ $cb->append_text($_); } $cb->set_active(0);
    $hbox->pack_start($cb, 0, 0, 5);

    my $btn_act = Gtk3::Button->new_with_label("Refrescar");
    $hbox->pack_start($btn_act, 0, 0, 5);
    $vbox->pack_start($hbox, 0, 0, 5);

    my $list_store = Gtk3::ListStore->new('Glib::String','Glib::String','Glib::String','Glib::String','Glib::String');
    my $tv = Gtk3::TreeView->new_with_model($list_store);
    my @tit = ("Código","Nombre","Fabricante","Precio","Stock");
    for my $i (0..4){ $tv->append_column(Gtk3::TreeViewColumn->new_with_attributes($tit[$i], Gtk3::CellRendererText->new(), text=>$i)); }
    my $s = Gtk3::ScrolledWindow->new(); $s->add($tv); $vbox->pack_start($s, 1, 1, 0);

    $btn_act->signal_connect(clicked => sub {
        $list_store->clear();
        my $t = $cb->get_active_text();
        my $nodes = ($t eq "Pre-Orden") ? $self->{db}->{equipos}->pre_orden() : ($t eq "Post-Orden" ? $self->{db}->{equipos}->post_orden() : $self->{db}->{equipos}->in_orden());
        foreach (@$nodes){ $list_store->set($list_store->append(), 0, $_->get_codigo(), 1, decode_utf8($_->get_nombre()), 2, decode_utf8($_->get_fabricante()), 3, $_->get_precio(), 4, $_->get_cantidad()); }
    });
    return $vbox;
}

# --- 4. PESTAÑA SUMINISTROS (B-TREE) ---
sub _crear_pestana_suministros_b {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    $vbox->set_border_width(15);
    my $hbox = Gtk3::Box->new('horizontal', 5);
    
    my $btn_new = Gtk3::Button->new_with_label("Registrar Nuevo");
    $btn_new->signal_connect(clicked => sub { $self->_mostrar_formulario_registro('Suministro'); });
    $hbox->pack_start($btn_new, 0, 0, 5);

    my $txt_bus = Gtk3::Entry->new(); $hbox->pack_start($txt_bus, 1, 1, 5);
    my $btn_bus = Gtk3::Button->new_with_label("Buscar");
    $btn_bus->signal_connect(clicked => sub { my $n = $self->{db}->{suministros}->buscar($txt_bus->get_text()); $self->_mostrar_alerta("Info", defined $n ? $n->{nombre} : "No hallado"); });
    $hbox->pack_start($btn_bus, 0, 0, 5);

    my $btn_del = Gtk3::Button->new_with_label("Eliminar");
    $btn_del->signal_connect(clicked => sub { $self->{db}->{suministros}->eliminar($txt_bus->get_text()); $self->_mostrar_alerta("Info", "Eliminado."); });
    $hbox->pack_start($btn_del, 0, 0, 5);


    my $btn_act = Gtk3::Button->new_with_label("Refrescar");
    $hbox->pack_start($btn_act, 0, 0, 5);
    $vbox->pack_start($hbox, 0, 0, 5);

    my $list_store = Gtk3::ListStore->new('Glib::String','Glib::String','Glib::String','Glib::String','Glib::String');
    my $tv = Gtk3::TreeView->new_with_model($list_store);
    my @tit = ("Código","Nombre","Fabricante","Precio","Stock");
    for my $i (0..4){ $tv->append_column(Gtk3::TreeViewColumn->new_with_attributes($tit[$i], Gtk3::CellRendererText->new(), text=>$i)); }
    my $s = Gtk3::ScrolledWindow->new(); $s->add($tv); $vbox->pack_start($s, 1, 1, 0);

    $btn_act->signal_connect(clicked => sub {
        $list_store->clear();
        foreach (@{$self->{db}->{suministros}->in_orden()}){ $list_store->set($list_store->append(), 0, $_->{codigo}, 1, decode_utf8($_->{nombre}), 2, decode_utf8($_->{fabricante}), 3, $_->{precio}, 4, $_->{cantidad}); }
    });
    return $vbox;
}

# --- 5. PROVEEDORES ---
sub _crear_pestana_proveedores {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    my $btn = Gtk3::Button->new_with_label("Actualizar Tabla");
    my $ls = Gtk3::ListStore->new('Glib::String','Glib::String','Glib::String','Glib::String');
    my $tv = Gtk3::TreeView->new_with_model($ls);
    my @tit = ("NIT","Nombre","Teléfono","Dirección");
    for my $i (0..3){ $tv->append_column(Gtk3::TreeViewColumn->new_with_attributes($tit[$i], Gtk3::CellRendererText->new(), text=>$i)); }
    $vbox->pack_start($btn,0,0,5); my $s = Gtk3::ScrolledWindow->new(); $s->add($tv); $vbox->pack_start($s,1,1,0);
    $btn->signal_connect(clicked => sub { $ls->clear(); foreach(@{$self->{db}->{proveedores}->obtener_lista_proveedores()}){ $ls->set($ls->append(), 0, $_->get_nit(), 1, decode_utf8($_->get_nombre()), 2, $_->get_telefono(), 3, decode_utf8($_->get_direccion())); } });
    return $vbox;
}

# --- 6. MATRIZ ---
sub _crear_pestana_matriz {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    my $btn = Gtk3::Button->new_with_label("Actualizar Matriz"); $vbox->pack_start($btn,0,0,5);
    my $ls = Gtk3::ListStore->new('Glib::String','Glib::String','Glib::String');
    my $tv = Gtk3::TreeView->new_with_model($ls);
    my @tit = ("Proveedor","Fabricante","Total");
    for my $i (0..2){ $tv->append_column(Gtk3::TreeViewColumn->new_with_attributes($tit[$i], Gtk3::CellRendererText->new(), text=>$i)); }
    my $s = Gtk3::ScrolledWindow->new(); $s->add($tv); $vbox->pack_start($s,1,1,0);
    $btn->signal_connect(clicked => sub {
        $ls->clear(); my $m = $self->{db}->{matriz}; my $cf = $m->{lista_filas};
        while(defined $cf){ my $nd = $cf->get_right(); while(defined $nd){
            my $cc = $m->{lista_cols}; my $fab="N/A"; while(defined $cc){ if($cc->get_label()==$nd->get_col()){ $fab=$cc->get_nombre_real(); last; } $cc=$cc->get_next(); }
            $ls->set($ls->append(), 0, decode_utf8($cf->get_nombre_real()), 1, decode_utf8($fab), 2, $nd->get_valor());
            $nd=$nd->get_right(); } $cf=$cf->get_next(); }
    });
    return $vbox;
}

# --- 7. REPORTES ---
sub _crear_pestana_reportes {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 10);
    my $hbox = Gtk3::Box->new('horizontal', 10);
    my $btn_g = Gtk3::Button->new_with_label("1. Generar"); $hbox->pack_start($btn_g, 1, 1, 0);
    my $cb = Gtk3::ComboBoxText->new(); foreach ("AVL (Personal)", "BST (Equipos)", "Arbol B (Suministros)", "Matriz", "Proveedores") { $cb->append_text($_); } $cb->set_active(0); $hbox->pack_start($cb, 1, 1, 0);
    my $btn_v = Gtk3::Button->new_with_label("2. Ver"); $hbox->pack_start($btn_v, 1, 1, 0);
    $vbox->pack_start($hbox, 0, 0, 5);
    my $scr = Gtk3::ScrolledWindow->new(); $vbox->pack_start($scr, 1, 1, 0); my $img = Gtk3::Image->new(); $scr->add($img);
    $btn_g->signal_connect(clicked => sub {
        GeneradorGrafos->generar_avl($self->{db}->{usuarios}); GeneradorGrafos->generar_bst($self->{db}->{equipos}); GeneradorGrafos->generar_arbol_b($self->{db}->{suministros}); GeneradorGrafos->generar_matriz($self->{db}->{matriz}); GeneradorGrafos->generar_proveedores($self->{db}->{proveedores});
        $self->_mostrar_alerta("Info", "PNGs creados.");
    });
    $btn_v->signal_connect(clicked => sub {
        my $s = $cb->get_active_text(); my $f = "reportes/reporte_avl.png";
        $f="reportes/reporte_bst.png" if $s=~/BST/; $f="reportes/reporte_arbol_b.png" if $s=~/Arbol B/; $f="reportes/reporte_matriz.png" if $s=~/Matriz/; $f="reportes/reporte_proveedores.png" if $s=~/Proveedores/;
        $img->set_from_file($f) if -e $f;
    });
    return $vbox;
}

# --- 8. INFO ---
sub _crear_pestana_info {
    my ($self) = @_;
    my $vbox = Gtk3::Box->new('vertical', 20);
    my $lbl = Gtk3::Label->new();
    $lbl->set_markup("<span size='xx-large' weight='bold'>DATOS DEL DESARROLLADOR</span>\n\nNombre: Mario Balam\nCarnet:202200147 \nSección: c");
    $vbox->pack_start($lbl, 1, 1, 0);
    return $vbox;
}

# --- FORMULARIO REGISTRO ---
sub _mostrar_formulario_registro {
    my ($self, $tipo) = @_;
    my $d = Gtk3::Dialog->new_with_buttons("Registrar $tipo", $self->{ventana}, 'modal', "Cancelar"=>'cancel', "Guardar"=>'ok');
    my $grid = Gtk3::Grid->new(); $grid->set_row_spacing(10); $grid->set_border_width(20); $d->get_content_area()->add($grid);
    my %ent;
    my @lab = ($tipo eq 'Médico') ? ("No. Colegio", "Nombre", "Contraseña", "Especialidad") : ("Código", "Nombre", "Fabricante", "Precio", "Stock");
    for my $i (0..$#lab) { $grid->attach(Gtk3::Label->new($lab[$i].":"), 0, $i, 1, 1); my $e = Gtk3::Entry->new(); $grid->attach($e, 1, $i, 1, 1); $ent{$lab[$i]} = $e; }
    my $cb_t = Gtk3::ComboBoxText->new(); if($tipo eq 'Médico'){ foreach(qw/TIPO-01 TIPO-02 TIPO-03 TIPO-04/){ $cb_t->append_text($_); } $cb_t->set_active(0); $grid->attach($cb_t, 1, 4, 1, 1); }
    $d->show_all();
    if ($d->run() eq 'ok') {
        my $fail=0; foreach(keys %ent){ $fail=1 if $ent{$_}->get_text() eq ""; }
        if($fail){ $self->_mostrar_alerta("Error","Campos vacíos."); }
        else {
            if ($tipo eq 'Médico') { $self->{db}->{usuarios}->insertar(numero_colegio=>$ent{"No. Colegio"}->get_text(), nombre_completo=>$ent{Nombre}->get_text(), contrasena=>$ent{Contraseña}->get_text(), especialidad=>$ent{Especialidad}->get_text(), tipo_usuario=>$cb_t->get_active_text(), departamento=>'DEP-MED'); }
            else { my $s = ($tipo eq 'Equipo') ? $self->{db}->{equipos} : $self->{db}->{suministros}; $s->insertar(codigo=>$ent{Código}->get_text(), nombre=>$ent{Nombre}->get_text(), fabricante=>$ent{Fabricante}->get_text(), precio=>$ent{Precio}->get_text(), cantidad=>$ent{Stock}->get_text()); }
        }
    } $d->destroy();
}

sub _abrir_dialogo_archivo {
    my ($self, $tipo) = @_;
    my $d = Gtk3::FileChooserDialog->new("Abrir JSON", $self->{ventana}, 'open', "Cancelar"=>'cancel', "Abrir"=>'accept');
    if ($d->run() eq 'accept') {
        my $r = $d->get_filename(); $d->destroy();
        my $e = ($tipo eq 'inventario') ? LectorJSON->cargar_inventario($r, $self->{db}->{medicamentos}, $self->{db}->{equipos}, $self->{db}->{suministros}, $self->{db}->{proveedores}, $self->{db}->{matriz}) : LectorJSON->cargar_usuarios($r, $self->{db}->{usuarios});
        $self->_mostrar_alerta("Carga", $e ? "Éxito" : "Fallo");
    } else { $d->destroy(); }
}

sub _mostrar_alerta { my ($self, $t, $m) = @_; my $d = Gtk3::MessageDialog->new($self->{ventana}, ['modal'], 'info', 'ok', $m); $d->set_title($t); $d->run(); $d->destroy(); }

1;