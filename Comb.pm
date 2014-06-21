#!/usr/local/bin/perl -w
package Comb;
require Exporter;
@Comb::ISA=qw(Exporter);
@Comb::EXPORT=qw(comb pcomb ncomb);

# Anzahl der 1 Bits in einem Integer
sub bits {
	my $i = shift;
	my $b = 0;
	while ($i) { $b++ if $i&1; $i>>=1; }
	return $b;
}

sub new {
    my $that  = shift;
    my $class = ref($that) || $that;
    my $self  = [];
	my $i;

	push @{$self}, @_;
    bless $self, $class;
    return $self;
}

sub hash {
	my $self = shift;
	my $aref = shift;

	my $index;

	return unless scalar @$self;
	my @x = @$self;
	my $li = pop @x;
	foreach $index(@x) {
		$aref->[$index] = [] unless defined $aref->[$index];
		$aref = $aref->[$index];
	}
	$aref->[$li] = 0 unless defined $aref->[$li];
	return $aref->[$li] += 1;
}

sub isin {
	my $self = shift;
	my $aref = shift;

	my $index;

	return 0 unless scalar @$self;
	my @x = @$self;
	my $li = pop @x;
	foreach $index(@x) {
		return 0 unless defined $aref->[$index];
		$aref = $aref->[$index];
	}
	return 0 unless defined $aref->[$li];
	return $aref->[$li];
}

sub ncomb {
	my $n = shift;
	my $aus = shift;
	my $res = 0;

	return 0 if $n < 1 || $n > $aus;
	return 1 if $n == $aus;
	return $aus if $n == 1;
	while ($aus >= $n) {
		$res += ncomb($n-1, --$aus);
	}
	return $res;
}

sub comb {
	my $n = shift;
	my @aus = @_;
	my $res = [];
	my $e;

	die "Out of range 1..N (n=$n) " if $n < 1;
	if ($n == 1) {
		return [ map { new Comb $_ } @aus ];
	}

	while (scalar @aus >= $n) {
		my $f = shift @aus;
		my $rsub = comb($n-1, @aus);
		foreach $e(@{$rsub}) {
			unshift @{$e}, $f;
			push @{$res}, $e;
		}
	}
	push @{$res}, (new Comb @aus) if scalar @aus == $n;
	return $res;
}

sub pcomb {
	my $x = shift;
	my $i;

	foreach $i(@{$x}) {
		print join(" ", @{$i}), "\n";
	}
	print "Gesamt ", scalar @{$x}, "\n";
}
1;
