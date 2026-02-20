package Graphviz;
use strict;
use warnings;

# --- REPORTE 1: INVENTARIO (Lista Doble) ---
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

# --- REPORTE 2: PROVEEDORES (Lista Circular de Listas) ---
sub generar_reporte_proveedores {
    my ($lista_prov) = @_;
    
    my $nombre_archivo = "reportes/proveedores";
    my $ruta_dot = "$nombre_archivo.dot";
    my $ruta_png = "$nombre_archivo.png";
    
    mkdir "reportes" unless -d "reportes"; # Asegurar carpeta

    open(my $fh, '>', $ruta_dot) or die "Error creando DOT: $!";
    
    print $fh "digraph G {\n";
    print $fh "    rankdir=TB;\n"; # Top to Bottom para ver las listas colgando
    print $fh "    node [shape=box, style=filled, fontname=\"Arial\"];\n";
    
    if ($lista_prov->esta_vacia) {
        print $fh "    Vacio [label=\"Sin Proveedores\"];\n";
    }
    else {
        my $actual = $lista_prov->primero;
        my $primero = $lista_prov->primero;
        
        # Subgrafo para alinear los proveedores horizontalmente
        print $fh "    { rank=same;\n";
        do {
            print $fh "        \"Prov_" . $actual->nit . "\" [label=\"Prove: " . $actual->nombre . "\\nNIT: " . $actual->nit . "\", fillcolor=lightblue];\n";
            $actual = $actual->siguiente;
        } while ($actual != $primero);
        print $fh "    }\n";

        # Conexiones Circulares (Horizontales)
        $actual = $lista_prov->primero;
        do {
            my $sig = $actual->siguiente;
            print $fh "    \"Prov_" . $actual->nit . "\" -> \"Prov_" . $sig->nit . "\" [constraint=false, color=blue];\n";
            $actual = $actual->siguiente;
        } while ($actual != $primero);

        # Listas Internas (Verticales - Entregas)
        $actual = $lista_prov->primero;
        do {
            my $entrega = $actual->primera_entrega;
            my $padre = "Prov_" . $actual->nit;
            
            while (defined $entrega) {
                my $id_entrega = "Ent_" . $actual->nit . "_" . $entrega->factura;
                print $fh "    \"$id_entrega\" [label=\"Fact: " . $entrega->factura . "\\nMed: " . $entrega->codigo_med . "\\nCant: " . $entrega->cantidad . "\", fillcolor=lightgrey];\n";
                
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

1; 