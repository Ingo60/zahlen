#!/usr/bin/perl -w

use strict;
#use lib ("/home/iw/sw/plib");

use Comb;

our %P = ();
our $pmin = 0;
our $pmax = 0;
our $pabs = 0;	# absolute P samples

package Zahl;

@Zahl::ISA=qw(Exporter);
@Zahl::EXPORT=qw();

sub new {
	my $that  = shift;
	my $class = ref($that) || $that;
	my $self  = {qw(h 0 age 0 ages 0 mina 9999 maxa 0 getippt 0 periode 0)};
	$self->{'zahl'} = shift;
	bless $self, $class;
	return $self;
}

sub h { shift->{'h'}; }
sub q { my $self = shift; return $self->h / (1+$self->age); }
sub age { shift->{'age'}; }
sub periode { shift->{periode}; }
sub mina { shift->{'mina'}; }
sub maxa { shift->{'maxa'}; }
sub getippt { shift->{'getippt'}; }
sub zahl { shift->{'zahl'}; }

sub altert { shift->{'age'}++; }

sub click { shift->{periode}++; }

sub gezogen {
	my $self = shift;

	$self->{'mina'} = $self->{'age'}
		if $self->{'age'} < $self->{'mina'};
	$self->{'maxa'} = $self->{'age'}
		if $self->{'age'} > $self->{'maxa'};
	$self->{'ages'} += $self->{'age'};
	$self->{'age'} = 0;
	if ($self->h) {
		$P{$self->periode} = 0 unless defined $P{$self->periode};
		$P{$self->periode} ++;
		$pabs ++;
	}
	$self->{periode} = 0;
	$self->{'h'}  += 1;
}

sub avage {
	my $self = shift;
	return $self->{'h'} ? $self->{'ages'} / $self->{'h'} : $self->{'age'};
}


package main;
use strict;


my $selftest = 0;
my $verbose = 0;
our $Z = [];
my $Pairs = [];
my $Tripel = [];
my $Quads = [];
my $N = 4;
my $Ziehung = 0;


sub intsort { $a <=> $b; }
sub qsort { $Z->[$a]->q <=> $Z->[$b]->q; }
sub asort { $Z->[$b]->age <=> $Z->[$a]->age; }
sub hsort { $Z->[$a]->h <=> $Z->[$b]->h; }
use strict;


sub schema {
	&neuertip12ausX(0..14);
}


sub ziehung {
	my @z = @_;
	my $i;

	my %zset;

	# print "new: ";
	foreach $i(@z) {
		$zset{$i} = 1;
		# print " $i" if $Z->[$i]->age > 5;
	}
	# print "\n";

	#	Alle Zahlen altern um eine Woche
	foreach $i(1..49) { $Z->[$i]->altert; }


	#
	#	gezogene Zahlen registrieren
	#
	foreach $i(@z) {
		#
		#	Alle Zahlen erhöhen ihre Periode
		#
		foreach my $j(1..49) {	$Z->[$j]->click unless $i==$j; }
		$Z->[$i]->gezogen;
	}

	# print "out: ";
	foreach $i(1..49) {
		# print " $i" if $Z->[$i]->age == 6;
	}
	# print "\n";
	#
	#	Registriere Paare
	#
	# my $pairs = comb(2, sort @ziehung);
	# foreach $c(@{$pairs}) { $c->hash($Pairs); }
	#
	#	Registriere Tripel
	#
	my $pairs = comb(3, sort @z);
	my $c;
	foreach $c(@{$pairs}) { $c->hash($Tripel); }
	#
	#	Registriere Quads
	#
	#$pairs = comb(4, sort @z);
	# my $c;
	#foreach $c(@{$pairs}) { $c->hash($Quads); }

	$Ziehung += 1;
	return @z;
}

#
#	Initialisiere Zahlen
#
foreach (0..49) {
	$Z->[$_] = new Zahl $_;
}

sub neuertip12ausX6 {
	my @qz = @_;
	my @sechser = map { Comb->new(sort intsort @$_) } @{comb(6, @qz)};
	my @neu = ();
	my $n = 12;
	my $limit = 6;
	my %nz = map { $_ => 0 } @qz;

	foreach my $t(@sechser) {
		next if grep { $nz{$_} >= $limit } @$t;
		$nz{$_} ++ foreach @$t;
		push @neu, $t;
	}

	die "Nicht genug Zahlen für $n Tips " if scalar @neu < $n;
	# @neu = sort { $b->[0] <=> $a->[0] } @neu;
	pop @neu while scalar @neu > $n;

	@neu = sort {
		$a->[0] <=> $a->[0]
		|| $a->[1] <=> $b->[1]
		|| $a->[2] <=> $b->[2]
		|| $a->[3] <=> $b->[3]
		|| $a->[4] <=> $b->[4]
		|| $a->[5] <=> $b->[5] } @neu;

	open(S,">tips.txt");
	print S "# {@qz}\r\n";
	foreach my $t(@neu) {
		printf S "%3d%3d%3d%3d%3d%3d\r\n",
			(map { $t->[$_] } 0..5);
			# (map { Pz($t->[$_])/100 } 1..6),
			#$t->[0];
	}
	close(S);
	print STDERR "\n";
}

sub neuertipNausX {
	my $n = shift;
	my @qz = @_;
	my $sechser = [];	# = comb(6, @qz);
	my $t;
	my $c;
	my @neu = ();
	my $quads = [];
	my $drei0 = 0;

	foreach $t(@{comb(6, @qz)}) {
		push @$sechser, new Comb sort intsort @$t;
	}
	sechs:
	while (scalar @$sechser) {
		#die "Ich brauche mehr Zahlen ... " if 0==@$sechser;
		$t = shift @$sechser;
		my $s = 0;
		$s += Pc(@$_) foreach @{comb(4, @$t)};
		unshift @$t, $s;
		#unshift @$t, Pc(@$t);
		push @neu, $t;
		#my $noldq = 0;
		#my $v = comb($N, @$t);

		#foreach $c(@$v) {
		#	if ($c->isin($quads)) {
		#		# print "{", join(" ", @$t), "} scheidet aus, da [",
		#		# 	join(" ", @$c), "] schon bedient.\n";
		#		next sechs;
		#	}
		#}
		#foreach $c(@$v) { $c->hash($quads); }

		#
		#
		#
		#$v = comb($N-1, @$t);
		#foreach $c(@$v) {
		#	$noldq += $c->isin($Tripel);
		#}
		#print STDERR map(sprintf("%3d", $_), @$t), "\t($noldq alte 3er)\t",
		#	scalar @$sechser, "\n"
		#if $verbose;
		#unshift @$t, $noldq;
		#push @neu, $t;
		#$drei0++ if $noldq == 0;
		#last if $drei0 == $n;
	}

	die "Nicht genug Zahlen für $n Tips " if scalar @neu < $n;
	@neu = sort { $b->[0] <=> $a->[0] } @neu;
	pop @neu while scalar @neu > $n;
	#@neu = sort { $a->[1] <=> $b->[1]
	#	|| $a->[2] <=> $b->[2]
	#	|| $a->[3] <=> $b->[3]
	#	|| $a->[4] <=> $b->[4]
	#	|| $a->[5] <=> $b->[5]
	#	|| $a->[6] <=> $b->[6] } @neu;
	# foreach $t(@neu) { shift @$t; };

	open(S,">tips.txt");
	print S "# {@qz}\r\n";
	foreach $t(@neu) {
		printf S "%3d%3d%3d%3d%3d%3d\t# 4er = %g\r\n",
			(map { $t->[$_] } 1..6),
			# (map { Pz($t->[$_])/100 } 1..6),
			$t->[0];
	}
	close(S);
	print STDERR "\n";
}

our $konto = 0;
our %gewinn = ();
our $ntips = 0;

sub auswertung {
	my %quoten = (	"3" => 10,
					"3z" => 80,
					"4" => 120,
					"4z" => 5500,
					"5" => 110000,
					"5z" => 700000,
					"6" => 1_300_000 );
	my @zahlen = @_;
	my %zie;
	my %getippt = ();
	my $tip = @ARGV==1 ? $ARGV[0] : "tips.txt";
	my $zz = 0;
	my $tno = 0;
	$zz = pop @zahlen if scalar @zahlen == 7;
	map { $zie{$_} = 1; } @zahlen;
	open(TIP, $tip) || die "Can't open $tip $!\n";
	my $x = int(-M $tip);
	if ($x > 21) {
		printf STDERR "reading from $tip, $x days old\n" if $verbose;
	} else {
		printf STDERR "reading from $tip\n" if $verbose;
	}
	print "Ziehung $Ziehung: @zahlen ZZ $zz\n";
	while (<TIP>) {
		/^#/ && next;
		if (/(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/) {
			$tno++;
			$ntips ++;
			# $konto -= 1.25;
			my $n = 0;
			my $mitz = 0;
			my @win = ();
			my @tip = ($1+0, $2+0, $3+0, $4+0, $5+0, $6+0);
			my $i;
			for ($i=0; $i < @tip; $i++) {
				if ($zie{"$tip[$i]"}) {
					push @win, $tip[$i];
				}
				if ($tip[$i] == $zz) {
					$mitz = 1;
				}
				$getippt{0+$tip[$i]} = 1;
			}
			if (scalar @win > 2) {
				printf "Tip $tno\t($1 $2 $3 $4 $5 $6)\t[@win]\t%der%s",
					scalar @win,
					$mitz ? " mit Zusatzzahl\n" : "\n";
				$i = scalar @win;
				$i .= "z" if $mitz;
				$konto += $quoten{$i};
				$gewinn{$i} = 0 unless defined $gewinn{$i};
				$gewinn{$i} ++;
			}
		}
		else {
			warn "Zeile $. in tips.txt falsch.\n";
		}
	}
	close TIP;

	$" = " ";
	print "Getippt:",
		(map { sprintf "%3d%s", $_, $zie{$_} || $zz==$_ ? "*" : "" } sort intsort keys %getippt), "\n"
	if 1|| $verbose;
	return $konto;
}

# my $his = $ARGV[0] eq "-h";
# shift @ARGV if $his;

sub lies_alte_zahlen {
	my @ziehung = ();
	# chdir($ENV{"HOME"});
	open(ZAHLEN, "zahlen.txt") || die "Can't open zahlen.txt $!\n";
	print STDERR "Ich lese die früher gezogenen Zahlen  " if $verbose;
	while (<ZAHLEN>) {
		/^#/ && next;
		s/^\s*//;
		s/\s*#.*//;		# allow comments
		if (/(\d+)(\s+\d+){5,6}/) {
			#print STDERR sprintf("%4d", $.), "\b\b\b\b" if $verbose;
			@ziehung = ziehung(split);
			if ($selftest) {
				findperioden();
				auswertung(@ziehung);
				neuertip12ausX6(ichnehme());
			}
		}
		else {
			warn "Zeile $. in zahlen.txt falsch!\n";
		}
	}
	print STDERR "$.\n" if $verbose;
	close ZAHLEN;
	return @ziehung;
}

our @sp = ();
our $spn = 0;

sub findperioden() {
	# Finde die küzeste Folge von Perioden, deren summiertes Vorkommen
	# 20% des Gesamtvorkommens ausmacht.
	@sp = keys %P;
	$spn = 0;
	return if @sp == 0;
	for my $p(sort intsort keys %P) {
		my @p20 = ($p);
		my $pn = $P{$p};
		my $pp = $p+1;
		while ($pn < $pabs/5 && defined $P{$pp}) {
			push @p20, $pp;
			$pn += $P{$pp};
			$pp++;
		}
		last if $pn < $pabs/5;	# kriegen wir nicht mehr zusammen
		if (scalar @p20 < scalar @sp
				|| scalar @p20 == scalar @sp && $pn >= $spn) {
			@sp = @p20;
			$spn = $pn;
		}
	}
	$pmin = $sp[0]; $pmax = $sp[-1];
	return;
}

sub statistik {
	my %zie  = ();
	map { $zie{$_} = 1; } @_;
	my $hmin = 999999;
	my $hsum = 0;
	my $asum = 0;
	my $qsum = 0;
	my $qav  = 0;
	my $hmax = 0;
	my $amin = 0;
	my $amax = 0;
	my $i;
	my $j;

	for ($i=1; $i<50; $i++) {
		$hsum += $Z->[$i]->h;
		$asum += $Z->[$i]->age;
		$hmin = $Z->[$i]->h if ($Z->[$i]->h < $hmin);
		$hmax = $Z->[$i]->h if ($Z->[$i]->h > $hmax);
		$amax = $Z->[$i]->age if ($Z->[$i]->age > $amax);
		$qsum += $Z->[$i]->q;
		#	printf "age(%d)=%d ", $i, $age{"$i"};
	}
	$qav = $qsum / 49;

	my $hav = int($hsum/49);

	printf "Durchschnitt Häufigkeit %5g, Durchschnitt Alter %5g\n",
		$hav, $asum/49;

	my @zahlen = ();
	my @qz = ();


	printf "<%4d mal  ", $hav-10;
	print map { sprintf("%2d%s ", $_, $zie{$_}?"*":" ") } sort hsort grep { $Z->[$_]->h < $hav-10 } 1..49;
	print "\n";
	for ($j=$hav-10; $j<=$hav+10; $j++) {
		my @z = grep { $Z->[$_]->h == $j } 1..49;
		next unless scalar @z;
		printf " %4d mal  ", $j;
		print map { sprintf("%2d%s ", $_, $zie{$_}?"*":" ") } @z;
		print "\n";
	}
	printf ">%4d mal  ", $hav+10;
	print map { sprintf("%2d%s ", $_, $zie{$_}?"*":" ") } sort hsort grep { $Z->[$_]->h > $hav+10 } 1..49;
	print "\n";

	print "\n";

	printf "letztesmal gezogen: (Durchschnitt %5g)\n", $asum/49;

	for($j=int($amax); $j>=0; $j--) {
		my @z = grep { $Z->[$_]->age == $j } 1..49;
		next unless scalar @z;
		printf "vor %3d Wochen  ", $j;
		print map { sprintf("%2d%s ", $_, $zie{$_}?"*":" ") } @z;
		print "\n";
	}
	print "\n";

	my @spz = sort intsort keys %P;
	my $avp = 0;
	foreach my $p(keys %P) {
		$avp += $p*$P{$p};
	}
	$avp /= $pabs;
	print "min Periode ", $spz[0],
		 ", max Periode ", $spz[-1],
		 ", Avg ", int ($avp+0.5),
		 ", Perioden ", scalar @spz, "\n";


	findperioden();


	print "$spn von $pabs Wiederauftritten ",
		sprintf("(%5.2f%%)", $spn*100/$pabs),
		" geschah mit folgenden Perioden:\n";
	foreach my $p(@sp) {
		my $n = $P{$p};
		my $pct = $n*100/$pabs;
		printf "P%3d %5.2f%% X%s\n", $p, $pct, "-" x (($n-int($pabs/100))/3);
	}

	return grep {  $Z->[$_]->h   < $hsum/49
				&& $Z->[$_]->age > $asum/49 } 1..49;
}

sub samstag {
	my %xx = ();
	my @r  = ();

	while (scalar @r < 7) {
		my $i = 1+int (49*rand);
		next if ($xx{$i});
		push @r, $i;
		$xx{$i} = 1;
	}
	return @r;
}

sub simulate {
	my $max = shift;
	my $neu = shift;
	$" = " ";
	$verbose = 0;
	my $s = time;
	my $k = 0;
	my $p = 0;
	# map  { $s += ord($_); } split(//, `ps -ef`);
	# srand($s);
	lies_alte_zahlen();
	while ($Ziehung < $max) {
		my @z = ziehung(samstag());
		$k -= 20;
		$k += auswertung(@z);
		neuertip12ausX6(sort qsort (1..49)) if $neu;
	}
	continue {
		if (($k <=> 0) != $p) {
			printf "Konto %7.2f\n", $k;
			$p = $k <=> 0;
		}
	}
	statistik('a'..'f');
	printf "Konto %7.2f\n", $k;
	exit;
}

sub selftest {
	$selftest = 1;
	lies_alte_zahlen();
	foreach my $ga(sort keys %gewinn) {
		my $g = $ga;
		$g =~ s/[3456]/$&er/;
		$g =~ s/z$/ mit Zusatzzahl/;
		printf "%4d\t$g\n", $gewinn{$ga};
	}
	printf " Gewinnsumme ca. %7.2f\n", $konto;
	printf "-Einsatz 1.25    %7.2f\n", $ntips*1.25;
	printf "Rest             %7.2f\n", $konto - $ntips*1.25;
	exit;
}

sub ichnehmerand() {
	my %qz = ();

	while (scalar keys %qz < 10) {
		$qz{1+int(rand(49))} = 1;

	}

	my @qz = keys %qz;
	print "Gut, ich nehme {@qz}\n";
	return @qz;
}

sub ichnehmealt() {
	my @hz = sort hsort (1..49);
	print "{@hz[0..11]}\tseltene Zahlen\n" if $verbose;
	my @az = sort asort (1..49);
	print "{@az[0..11]}\talte Zahlen\n" if $verbose;
	my @qz = ();
	my %qz = ();
	my %pz = ();
	foreach (1..49) {
		my $p = $Z->[$_]->periode;
		$pz{$_} = 0;
		next unless $Z->[$_]->h;
		$pz{$_} += 1 if $p >= $pmin && $p <= $pmax;			# 1st
		$p++; $pz{$_} += 1 if $p >= $pmin && $p <= $pmax;	# 2nd
		$p++; $pz{$_} += 1 if $p >= $pmin && $p <= $pmax;	# 3rd
		$p++; $pz{$_} += 1 if $p >= $pmin && $p <= $pmax;	# 4th
		$p++; $pz{$_} += 1 if $p >= $pmin && $p <= $pmax;	# 5th
		$p++; $pz{$_} += 1 if $p >= $pmin && $p <= $pmax;	# 6th
	} ;
	my @qq = sort { $pz{$b} <=> $pz{$a} } keys %pz;
	print "{@qq[0..11]}\tZahlen mit Periode\n" if $verbose;
	#print "Wieviele Scheine? [1] ";
	#$nt = <STDIN>;
	#chop($nt);
	#$nt = 1 unless $nt =~ m/\d+/;
	my $nt = 1;

	$qz{$hz[0]} = 1;$qz{$hz[1]} = 1;$qz{$hz[2]} = 1;
	@qz = @hz[0..2];
	my $z;
	$z = shift @az; unless ($qz{$z}) { $qz{$z} = 1; push @qz, $z; }
	$z = shift @az; unless ($qz{$z}) { $qz{$z} = 1; push @qz, $z; }
	$z = shift @az; unless ($qz{$z}) { $qz{$z} = 1; push @qz, $z; }

	while (scalar @qz < 12+$nt) {
		$z = shift @qq; unless ($qz{$z}) { $qz{$z} = 1; push @qz, $z; }
	}
	#my @sqz = sort intsort keys %qz;
	print "Gut, ich nehme {@qz}\n";
	return @qz;
}

sub Px($) {
	my $p = shift;
	return 0 unless $P{$p};
	return $P{$p}*100/$pabs;
}

sub Pz($) {
	my $z = shift;
	my $p = $Z->[$z]->periode;
	return Px($p) + Px($p+1) + Px($p+2) + Px($p+3) + Px($p+4) + Px($p+5);
}

sub Pc(@) {
	my $p = 1;
	$p *= Pz($_)/100 foreach @_;
	return $p;
}

sub ichnehmeneu() {
	my @pct = ();
	my @az = sort asort (1..49);

	print "{@az[0..11]}\talte Zahlen\n" if $verbose;

	foreach my $z(1..49) {
		my $p = $Z->[$z]->periode;
		$pct[$z] = Px($p) + Px($p+1) + Px($p+2) + Px($p+3) + Px($p+4) + Px($p+5);
		printf "%4d %5.2f%%", $z, $pct[$z] if $verbose;
		print "\n" if $verbose && $z%7 == 0;
	}
	my @qq = sort { $pct[$b] <=> $pct[$a] } 1..49;
	pop @qq while scalar @qq > 13;
	my @oqq = @qq;

	my %qz = ();
	map { $qz{$_} = 1; } @qq;
	while (scalar keys %qz < 16) {
		my $z = shift @az;
		next if defined $qz{$z};
		$qz{$z} = 1;
		push @qq, $z;
	}
	print "Gut, ich nehme neu {@qq}\n";
	#print map { sprintf(" %5.2f%%", $pct[$_]) } @oqq;
	#print "\n";
	return @qq;
}

sub ichnehme() { return ichnehmeneu(); }


sub main {
	$" = " ";
	$verbose = !$selftest;
	my @ziehung = lies_alte_zahlen();
	my @zahlen  = statistik(@ziehung);

	auswertung(@ziehung);

	#print "Neuen Tip machen?";
	#my $nt = <STDIN>;

	#if ($nt =~ /j|y/) {
		neuertip12ausX6(ichnehme);
	#}
}

if (@ARGV < 2) { main; exit 0; }
while (@ARGV > 1) {
	my $ev = shift @ARGV;
	eval $ev or die "$@";
}
