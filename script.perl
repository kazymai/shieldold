#!/usr/bin/perl
@widths = (0.1, 0.2, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0);
@energies = (1.0, 2.0, 3.0, 4.5);
$stat = 20000;
$bins = 400;

$geometryfile = "PASIN.DAT";
$geometrypattern = "PASIN.PTR";

$dirname = "results3";
mkdir($dirname, 0777);

foreach $width (@widths) {
    prepare_file($width);
    foreach $energy (@energies) {
        print "Computing for width $width [cm] and energy $energy [GeV]\n";
        `root -b -q "run_en.c(${energy}, ${stat}, ${bins}, ${width})"`;
    }
}
print "DONE.";

sub prepare_file
{
    my ($width) = $_[0];
   
    unlink ($geometryfile);
    open (GEOM, ">$geometryfile") || die "Failed to open geometry file $geometryfile";
    open (PATTERN, $geometrypattern) || die "Failed to open pattern file $geometrypattern";

    while ($string = <PATTERN>)
    {
        $string =~ s/width/  $width/;
        print GEOM  $string;
    }

    close (PATTERN) || die "Failed to close pattern file $geometrypattern";
    close (GEOM) || die "Failed to close geometry file $geometryfile";
    
}
