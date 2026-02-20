package Graphviz;
use strict;
use warnings;

# ==========================================
# 1. REPORTE INVENTARIO (Lista Doble)
# ==========================================
sub generar_reporte_inventario {
    my ($lista) = @_;
    
    my $nombre_archivo = "reportes/inventario";
    my $ruta_dot = "$nombre_archivo.dot";
    my $ruta_png = "$nombre_archivo.png";
    
    mkdir "reportes" unless -d "reportes";

    open(my $fh, '>', $ruta_dot) or die "Error creando DOT: $!";

    print $fh "digraph G {\n";
    print $fh "    rankdir=LR;\n"; 
    print $fh "    node [shape=record, fontname=\"Arial\"];\n";
    
    if ($lista->esta_vacia) {
        print $fh "    NodoVacio [label=\"Inventario Vacio\"];\n";
    } 
    else {
        my $actual = $lista->primero;
        
        # Nodos
        while (defined $actual) {
            my $color = "palegreen"; 
            if ($actual->stock < $actual->minimo) { $color = "salmon"; }
            elsif ($actual->vencimiento lt "2027-01-01") { $color = "gold"; }

            my $label = "{" . $actual->codigo . " | " . $actual->nombre . "\\nStock: " . $actual->stock . "}";
            print $fh "    " . $actual->codigo . " [label=\"$label\", style=filled, fillcolor=$color];\n";
            $actual = $actual->siguiente;
        }

        # Conexiones
        $actual = $lista->primero;
        while (defined $actual) {
            if (defined $actual->siguiente) {
                print $fh "    " . $actual->codigo . " -> " . $actual->siguiente->codigo . ";\n";
            }
            if (defined $actual->anterior) {
                print $fh "    " . $actual->codigo . " -> " . $actual->anterior->codigo . " [style=dashed, color=grey];\n"; 
            }
            $actual = $actual->siguiente;
        }
    }
    print $fh "}\n";
    close($fh);
    
    system("dot -Tpng $ruta_dot -o $ruta_png");
    print "Reporte Inventario generado: $ruta_png\n";
}

# ==========================================
# 2. REPORTE PROVEEDORES (Lista Circular de Listas)
# ==========================================
sub generar_reporte_proveedores {
    my ($lista_prov) = @_;
    
    my $nombre_archivo = "reportes/proveedores";
    my $ruta_dot = "$nombre_archivo.dot";
    my $ruta_png = "$nombre_archivo.png";
    
    mkdir "reportes" unless -d "reportes";

    open(my $fh, '>', $ruta_dot) or die "Error creando DOT: $!";
    
    print $fh "digraph G {\n";
    print $fh "    rankdir=TB;\n"; 
    print $fh "    node [shape=box, style=filled, fontname=\"Arial\"];\n";
    
    if ($lista_prov->esta_vacia) {
        print $fh "    Vacio [label=\"Sin Proveedores\"];\n";
    }
    else {
        my $actual = $lista_prov->primero;
        my $primero = $lista_prov->primero;
        
        # Subgrafo horizontal (Proveedores)
        print $fh "    { rank=same;\n";
        do {
            print $fh "        \"Prov_" . $actual->nit . "\" [label=\"Prove: " . $actual->nombre . "\\nNIT: " . $actual->nit . "\", fillcolor=lightblue, group=" . $actual->nit . "];\n";
            $actual = $actual->siguiente;
        } while ($actual != $primero);
        print $fh "    }\n";

        # Conexiones Circulares
        $actual = $lista_prov->primero;
        do {
            my $sig = $actual->siguiente;
            print $fh "    \"Prov_" . $actual->nit . "\" -> \"Prov_" . $sig->nit . "\" [constraint=false, color=blue];\n";
            $actual = $actual->siguiente;
        } while ($actual != $primero);

        # Listas Verticales (Entregas)
        $actual = $lista_prov->primero;
        do {
            my $entrega = $actual->primera_entrega;
            my $padre = "Prov_" . $actual->nit;
            
            while (defined $entrega) {
                my $id_entrega = "Ent_" . $actual->nit . "_" . $entrega->factura;
                print $fh "    \"$id_entrega\" [label=\"Fact: " . $entrega->factura . "\\nMed: " . $entrega->codigo_med . "\\nCant: " . $entrega->cantidad . "\", fillcolor=lightgrey, group=" . $actual->nit . "];\n";
                print $fh "    \"$padre\" -> \"$id_entrega\";\n";
                $padre = $id_entrega;
                $entrega = $entrega->siguiente;
            }
            $actual = $actual->siguiente;
        } while ($actual != $primero);
    }
    print $fh "}\n";
    close($fh);
    
    system("dot -Tpng $ruta_dot -o $ruta_png");
    print "Reporte Proveedores generado: $ruta_png\n";
}

# ==========================================
# 3. REPORTE SOLICITUDES (Lista Circular Doble)
# ==========================================
sub generar_reporte_solicitudes {
    my ($lista_sol) = @_;
    
    my $nombre_archivo = "reportes/solicitudes";
    my $ruta_dot = "$nombre_archivo.dot";
    my $ruta_png = "$nombre_archivo.png";
    
    mkdir "reportes" unless -d "reportes";

    open(my $fh, '>', $ruta_dot) or die "Error: $!";
    
    print $fh "digraph G {\n";
    print $fh "    rankdir=LR;\n"; 
    print $fh "    node [shape=circle, style=filled, color=lightblue, fontname=\"Arial\"];\n";
    
    if ($lista_sol->esta_vacia) {
        print $fh "    Vacio [label=\"Sin Solicitudes Pendientes\", shape=box];\n";
    }
    else {
        my $actual = $lista_sol->primero;
        
        # Nodos
        do {
            my $label = "ID: " . $actual->id . "\\n" . $actual->departamento . "\\nMed: " . $actual->codigo_med;
            my $color = "lightblue";
            if ($actual->prioridad =~ /Alta/i) { $color = "salmon"; }
            
            print $fh "    Sol_" . $actual->id . " [label=\"$label\", fillcolor=$color];\n";
            $actual = $actual->siguiente;
        } while ($actual != $lista_sol->primero);
        
        # Conexiones
        $actual = $lista_sol->primero;
        do {
            my $sig = $actual->siguiente;
            my $ant = $actual->anterior;
            
            # Flecha Siguiente
            print $fh "    Sol_" . $actual->id . " -> Sol_" . $sig->id . " [weight=1];\n";
            # Flecha Anterior
            print $fh "    Sol_" . $actual->id . " -> Sol_" . $ant->id . " [color=grey, style=dashed, constraint=false];\n";
            
            $actual = $actual->siguiente;
        } while ($actual != $lista_sol->primero);
        
        # Label Total
        my $count = 0;
        my $temp = $lista_sol->primero;
        do { $count++; $temp = $temp->siguiente; } while ($temp != $lista_sol->primero);
        
        print $fh "    label=\"Total Solicitudes Pendientes: $count\";\n";
        print $fh "    labelloc=\"b\";\n";
    }
    print $fh "}\n";
    close($fh);
    
    system("dot -Tpng $ruta_dot -o $ruta_png");
    print "Reporte Solicitudes generado: $ruta_png\n";
}

# ==========================================
# 4. REPORTE MATRIZ DISPERSA
# ==========================================
sub generar_reporte_matriz {
    my ($matriz) = @_;
    
    my $nombre_archivo = "reportes/matriz_dispersa";
    my $ruta_dot = "$nombre_archivo.dot";
    my $ruta_png = "$nombre_archivo.png";
    
    open(my $fh, '>', $ruta_dot) or die "Error creando DOT: $!";
    
    print $fh "digraph SparseMatrix {\n";
    print $fh "    node [shape=box, fontname=\"Arial\"];\n";
    print $fh "    rankdir=TB;\n";
    print $fh "    nodesep=0.5;\n";
    print $fh "    ranksep=0.5;\n";

    # Raíz 0,0
    print $fh "    Mt [label=\"Matriz\", style=filled, fillcolor=grey, group=0];\n";

    # CABECERAS COLUMNA
    my $col = $matriz->{lista_cols};
    if (defined $col) {
        print $fh "    { rank=same; Mt; ";
        while (defined $col) {
            my $cid = "C_" . $col->get_label();
            print $fh "$cid [label=\"" . $col->get_nombre_real() . "\", group=" . ($col->get_label() + 1) . ", style=filled, fillcolor=lightblue]; ";
            $col = $col->get_next();
        }
        print $fh "}\n";
        
        # Enlaces Columna
        $col = $matriz->{lista_cols};
        my $prev = "Mt";
        while (defined $col) {
            my $cid = "C_" . $col->get_label();
            print $fh "    $prev -> $cid;\n";
            $prev = $cid;
            $col = $col->get_next();
        }
    }

    # CABECERAS FILA Y DATOS
    my $row = $matriz->{lista_filas};
    my $prev_row_head = "Mt";

    while (defined $row) {
        my $rid = "R_" . $row->get_label();
        print $fh "    $rid [label=\"" . $row->get_nombre_real() . "\", group=0, style=filled, fillcolor=lightyellow];\n";
        print $fh "    $prev_row_head -> $rid;\n";
        $prev_row_head = $rid;

        # Nodos de esta fila
        my $curr = $row->get_right();
        while (defined $curr) {
            my $nid = "N_" . $curr->get_fila() . "_" . $curr->get_col();
            print $fh "    $nid [label=\"Q" . $curr->get_valor() . "\", shape=circle, style=filled, fillcolor=white, width=0.8, group=" . ($curr->get_col() + 1) . "];\n";
            $curr = $curr->get_right();
        }

        # Alinear Fila
        print $fh "    { rank=same; $rid; ";
        $curr = $row->get_right();
        while (defined $curr) {
             print $fh "N_" . $curr->get_fila() . "_" . $curr->get_col() . "; ";
             $curr = $curr->get_right();
        }
        print $fh "}\n";

        # Enlaces Horizontales
        my $prev_node = $rid;
        $curr = $row->get_right();
        while (defined $curr) {
            my $nid = "N_" . $curr->get_fila() . "_" . $curr->get_col();
            print $fh "    $prev_node -> $nid [constraint=false];\n";
            $prev_node = $nid;
            $curr = $curr->get_right();
        }
        $row = $row->get_next();
    }

    # ENLACES VERTICALES
    $col = $matriz->{lista_cols};
    while (defined $col) {
        my $prev_v = "C_" . $col->get_label();
        my $curr_v = $col->get_down();
        while (defined $curr_v) {
            my $nid = "N_" . $curr_v->get_fila() . "_" . $curr_v->get_col();
            print $fh "    $prev_v -> $nid;\n";
            $prev_v = $nid;
            $curr_v = $curr_v->get_down();
        }
        $col = $col->get_next();
    }

    print $fh "}\n";
    close($fh);
    
    system("dot -Tpng $ruta_dot -o $ruta_png");
    print "Reporte Matriz generado: $ruta_png\n";
}

1;