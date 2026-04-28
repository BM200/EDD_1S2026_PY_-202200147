package GeneradorGrafos;
use strict;
use warnings;
use utf8;
use Encode qw(decode_utf8);

#1. Reporte de arbol AVL(personal medico. )
sub generar_avl {
    my ($class, $arbol) = @_;
    
    my $dot = "digraph G {\n";
    $dot .= "    nodesep=0.2;\n"; 
    $dot .= "    ranksep=0.4;\n"; 
    $dot .= "    node [shape=circle, style=filled, fillcolor=lightblue, fixedsize=true, width=1.0, 
    fontsize=8, fontname=\"Arial\"];\n";
    
    $dot .= _recorrer_avl_dot($arbol->{root});
    $dot .= "}";
    
    _escribir_y_compilar("reporte_avl", $dot);
}

sub _recorrer_avl_dot {
    my ($nodo) = @_;
    return "" if !defined $nodo;
    
    my $txt = "";
    my $id = $nodo->get_numero_colegio();
    $id =~ s/-/_/g; 
    
    # --- TRUCO: Acortar el nombre para que quepa en el círculo ---
    my $nombre = decode_utf8($nodo->get_nombre_completo());
    my @p = split(' ', $nombre);
    # Tomamos solo el primer nombre y el primer apellido
    my $nombre_corto = (scalar @p > 1) ? "$p[0]\\n$p[1]" : $nombre;

    $txt .= "    $id [label=\"" . $nodo->get_numero_colegio() . "\\n" . $nombre_corto . "\"];\n";
    
    if (defined $nodo->get_left()) {
        my $izq_id = $nodo->get_left()->get_numero_colegio(); $izq_id =~ s/-/_/g;
        $txt .= "    $id -> $izq_id;\n";
        $txt .= _recorrer_avl_dot($nodo->get_left());
    }
    if (defined $nodo->get_right()) {
        my $der_id = $nodo->get_right()->get_numero_colegio(); $der_id =~ s/-/_/g;
        $txt .= "    $id -> $der_id;\n";
        $txt .= _recorrer_avl_dot($nodo->get_right());
    }
    return $txt;
}

# 2. REPORTE ÁRBOL BST (Equipos Médicos)
sub generar_bst {
    my ($class, $arbol) = @_;
    my $dot = "digraph G {\n    node [shape=box, style=filled, fillcolor=lightyellow];\n";
    $dot .= _recorrer_bst_dot($arbol->{root});
    $dot .= "}";
    _escribir_y_compilar("reporte_bst", $dot);
}

sub _recorrer_bst_dot {
    my ($nodo) = @_;
    return "" if !defined $nodo;
    my $txt = "";
    my $id = $nodo->get_codigo(); $id =~ s/-/_/g;
    
    $txt .= "    $id [label=\"" . $nodo->get_codigo() . "\\n" . $nodo->get_nombre() . "\"];\n";
    
    if (defined $nodo->get_left()) {
        my $izq_id = $nodo->get_left()->get_codigo(); $izq_id =~ s/-/_/g;
        $txt .= "    $id -> $izq_id;\n";
        $txt .= _recorrer_bst_dot($nodo->get_left());
    }
    if (defined $nodo->get_right()) {
        my $der_id = $nodo->get_right()->get_codigo(); $der_id =~ s/-/_/g;
        $txt .= "    $id -> $der_id;\n";
        $txt .= _recorrer_bst_dot($nodo->get_right());
    }
    return $txt;
}

# 3. REPORTE ÁRBOL B 
sub generar_arbol_b {
    my ($class, $arbol) = @_;
    my $dot = "digraph G {\n    node [shape=record];\n";
    $dot .= _recorrer_b_dot($arbol->{root});
    $dot .= "}";
    _escribir_y_compilar("reporte_arbol_b", $dot);
}

sub _recorrer_b_dot {
    my ($nodo) = @_;
    return "" if !defined $nodo;
    
    my $id = "nodo" . sprintf("%x", $nodo); # ID único basado en dirección de memoria
    my $claves_ref = $nodo->get_claves();
    my $label = "{";
    
    # NODO SEGMENTADO. 
    for my $i (0..$#{$claves_ref}) {
        $label .= "<f$i> " . $claves_ref->[$i]->{codigo};
        $label .= " | " if $i < $#{$claves_ref};
    }
    $label .= "}";


    my $color = scalar(@$claves_ref) >= 3 ? "yellow" : "palegreen";
    my $txt = "    $id [label=\"$label\", style=filled, fillcolor=$color];\n";

    # Hijos
    my $hijos_ref = $nodo->get_hijos();
    for my $i (0..$#{$hijos_ref}) {
        my $hijo_id = "nodo" . sprintf("%x", $hijos_ref->[$i]);
        $txt .= "    $id:f0 -> $hijo_id;\n";
        $txt .= _recorrer_b_dot($hijos_ref->[$i]);
    }
    return $txt;
}

# --- FUNCIONES AUXILIARES ---
sub _escribir_y_compilar {
    my ($nombre, $contenido) = @_;
    mkdir "reportes" unless -d "reportes";
    open my $fh, ">", "reportes/$nombre.dot" or return;
    print $fh $contenido;
    close $fh;
    system("dot -Tpng reportes/$nombre.dot -o reportes/$nombre.png");
}


# --- 4. REPORTE MATRIZ DISPERS
sub generar_matriz {
    my ($class, $matriz) = @_;
    
    my $dot = "digraph SparseMatrix {\n";
    $dot .= "    node [shape=box, fontname=\"Arial\"];\n";
    $dot .= "    rankdir=TB;\n";
    $dot .= "    nodesep=0.6;\n";
    $dot .= "    ranksep=0.6;\n";
    
    # Nodo Raíz
    $dot .= "    Mt [label=\"Matriz\", style=filled, fillcolor=grey, group=0];\n";

    # --- 1. CABECERAS DE COLUMNA (Fabricantes)
    my $col = $matriz->{lista_cols};
    if (defined $col) {
        $dot .= "    { rank=same; Mt; ";
        while (defined $col) {
            my $cid = "C" . $col->get_label();
            $dot .= "$cid [label=\"" . $col->get_nombre_real() . "\", group=" . ($col->get_label() + 1) . ", style=filled, fillcolor=lightblue]; ";
            $col = $col->get_next();
        }
        $dot .= "}\n";
        
        $col = $matriz->{lista_cols};
        my $prev = "Mt";
        while (defined $col) {
            my $cid = "C" . $col->get_label();
            $dot .= "    $prev -> $cid;\n";
            $prev = $cid;
            $col = $col->get_next();
        }
    }

    # 2. CABECERAS DE FILA (Proveedores) y NODOS DE DATOS
    my $row = $matriz->{lista_filas};
    my $prev_row = "Mt";
    while (defined $row) {
        my $rid = "R" . $row->get_label();
        $dot .= "    $rid [label=\"" . $row->get_nombre_real() . "\", group=0, style=filled, fillcolor=lightyellow];\n";
        $dot .= "    $prev_row -> $rid;\n";
        $prev_row = $rid;

        my $curr = $row->get_right();
        while (defined $curr) {
            my $nid = "N_" . $curr->get_fila() . "_" . $curr->get_col();
            $dot .= "    $nid [label=\"" . $curr->get_valor() . "\", shape=circle, style=filled, fillcolor=white, group=" . ($curr->get_col() + 1) . "];\n";
            $curr = $curr->get_right();
        }

        # Alinear fila horizontalmente
        $dot .= "    { rank=same; $rid; ";
        $curr = $row->get_right();
        while (defined $curr) {
             $dot .= "N_" . $curr->get_fila() . "_" . $curr->get_col() . "; ";
             $curr = $curr->get_right();
        }
        $dot .= "}\n";

        # Enlaces horizontales (Fila -> Datos)
        my $prev_n = $rid;
        $curr = $row->get_right();
        while (defined $curr) {
            my $nid = "N_" . $curr->get_fila() . "_" . $curr->get_col();
            $dot .= "    $prev_n -> $nid [constraint=false];\n";
            $prev_n = $nid;
            $curr = $curr->get_right();
        }
        $row = $row->get_next();
    }

    # ENLACES VERTICALES (Columnas 
    $col = $matriz->{lista_cols};
    while (defined $col) {
        my $prev_v = "C" . $col->get_label();
        my $curr_v = $col->get_down(); 
        while (defined $curr_v) {
            my $nid = "N_" . $curr_v->get_fila() . "_" . $curr_v->get_col();
            $dot .= "    $prev_v -> $nid;\n";
            $prev_v = $nid;
            $curr_v = $curr_v->get_down();
        }
        $col = $col->get_next();
    }
    
    $dot .= "}\n";
    _escribir_y_compilar("reporte_matriz", $dot);
}

# 5. REPORTE PROVEEDORES (Lista Doble Circular) ---
sub generar_proveedores {
    my ($class, $lista) = @_;
    my $dot = "digraph G {\n    rankdir=LR;\n    node [shape=box, style=filled, fillcolor=lightpink];\n";
    
    my $nodos = $lista->obtener_lista_proveedores();
    if (scalar(@$nodos) > 0) {
        for my $i (0..$#$nodos) {
            my $curr = $nodos->[$i];
            my $nit = $curr->get_nit(); $nit =~ s/-/_/g;
            my $sig = $curr->get_siguiente()->get_nit(); $sig =~ s/-/_/g;
            my $ant = $curr->get_anterior()->get_nit(); $ant =~ s/-/_/g;
            
            $dot .= "    $nit [label=\"NIT: " . $curr->get_nit() . "\\n" . $curr->get_nombre() . "\"];\n";
            # Flechas dobles para representar la lista doble circular
            $dot .= "    $nit -> $sig [color=blue, constraint=true];\n";
            $dot .= "    $nit -> $ant [color=red, constraint=false];\n";
        }
    }
    $dot .= "}";
    _escribir_y_compilar("reporte_proveedores", $dot);
}

1;