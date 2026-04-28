package LectorJSON;
use strict;
use warnings;
use JSON::PP;

sub cargar_inventario {
    my ($class, $ruta_archivo, $lista_med, $arbol_equ, $arbol_sum, $lista_prov, $matriz) = @_;
    unless (-e $ruta_archivo) { return 0; }
    my $json_text = do { local $/ = undef; open my $fh, "<", $ruta_archivo; <$fh>; };
    my $data;
    eval { $data = JSON::PP->new->utf8(0)->decode($json_text); };
    if ($@) { return 0; }

    foreach my $prov (@{$data->{proveedor}}) {
        $lista_prov->insertar_proveedor(nit=>$prov->{nit}, nombre=>$prov->{nombre}, telefono=>$prov->{telefono}, direccion=>$prov->{direccion});

        if (exists $prov->{entrega} && ref($prov->{entrega}) eq 'ARRAY') {
            foreach my $item (@{$prov->{entrega}}) {
                
                # --- VALIDACIÓN ESTRICTA (REQUISITO PDF) ---
                if (!defined $item->{cantidad} || $item->{cantidad} < 0) {
                    print "IGNORADO: " . $item->{codigo} . " tiene cantidad invalida.\n";
                    next; # SALTAR este producto
                }

                my $tipo = uc($item->{tipo});
                eval {
                    if ($tipo eq "MEDICAMENTO") {
                        $lista_med->insertar(codigo=>$item->{codigo}, 
                        nombre=>$item->{nombre}, 
                        principio_activo=>$item->{principio_activo}, fabricante=>$item->{fabricante}, precio=>$item->{precio_unitario}, stock=>$item->{cantidad}, vencimiento=>$item->{fecha_vencimiento}, minimo=>$item->{nivel_minimo});
                    } 
                    elsif ($tipo eq "EQUIPO") {
                        $arbol_equ->insertar(codigo=>$item->{codigo}, nombre=>$item->{nombre}, fabricante=>$item->{fabricante}, precio=>$item->{precio_unitario}, cantidad=>$item->{cantidad}, fecha_ingreso=>$item->{fecha_ingreso}, minimo=>$item->{nivel_minimo});
                    } 
                    elsif ($tipo eq "SUMINISTRO") {
                        $arbol_sum->insertar(codigo=>$item->{codigo}, nombre=>$item->{nombre}, fabricante=>$item->{fabricante}, precio=>$item->{precio_unitario}, cantidad=>$item->{cantidad}, vencimiento=>$item->{fecha_vencimiento}, minimo=>$item->{nivel_minimo});
                    }

                    if (defined $matriz) {
                        $matriz->sumar_elemento(
                        $prov->{nombre},     # Fila (Proveedor)
                        $item->{fabricante},  # Columna (Fabricante)
                        $item->{cantidad}     # Valor a acumular
                    );                    }
                  $lista_prov->agregar_entrega($prov->{nit}, codigo_med=>$item->{codigo}, cantidad=>$item->{cantidad}, factura=>$prov->{numero_factura}, fecha=>$prov->{fecha_entrega});
                };
            }
        }
    }
    return 1;
}

sub cargar_usuarios {
    my ($class, $ruta_archivo, $arbol_usuarios) = @_;
    unless (-e $ruta_archivo) { return 0; }
    my $json_text = do { local $/ = undef; open my $fh, "<", $ruta_archivo; <$fh>; };
    my $data;
    eval { $data = JSON::PP->new->utf8(0)->decode($json_text); };
    if ($@) { return 0; }
    foreach my $user (@{$data->{usuarios}}) {
        $arbol_usuarios->insertar(numero_colegio=>$user->{numero_colegio}, nombre_completo=>$user->{nombre_completo}, tipo_usuario=>$user->{tipo_usuario}, departamento=>$user->{departamento}, especialidad=>$user->{especialidad}, contrasena=>$user->{contrasena});
    }
    return 1;
}
1;