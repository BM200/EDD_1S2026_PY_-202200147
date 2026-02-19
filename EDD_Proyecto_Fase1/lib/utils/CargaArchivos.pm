package CargaArchivos;
use strict;
use warnings;

sub cargar_medicamentos {
    my ($lista, $ruta_archivo) = @_;
    
    unless (-e $ruta_archivo) {
        print "Error: Archivo no encontrado.\n";
        return;
    }

    open(my $fh, '<', $ruta_archivo) or die "Error abriendo archivo: $!";
    
    my $header = <$fh>; # Saltar cabecera
    my $count = 0;

    while (my $linea = <$fh>) {
        chomp $linea;
        next if $linea eq '';
        
        my @d = split(',', $linea);
        
        if (scalar(@d) >= 8) {
            # Llamada al metodo insertar de Moo
            $lista->insertar(
                codigo           => $d[0],
                nombre           => $d[1],
                principio_activo => $d[2],
                laboratorio      => $d[3],
                precio           => $d[4],
                stock            => $d[5],
                vencimiento      => $d[6],
                minimo           => $d[7]
            );
            $count++;
        }
    }
    close($fh);
    print "Cargados $count medicamentos.\n";
}
1;