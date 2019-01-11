#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
use Bio::SeqIO;

our ($opt_i, $opt_o, $opt_h);
getopts("i:o:h");
if (!$opt_i && !$opt_o && !$opt_h) {
    print "There are n\'t any tags. Print help\n\n";
    help();
}
if ($opt_h) {
    help();
}

my $infasta = $opt_i || 
    die("ARGUMENTS ERROR: -i <input_fastafile> option was not supplied.\n");
my $out = $opt_o;
my %length = ();
my $total_length = 0;
my $total_seq = 0;
my $seqio = Bio::SeqIO->new( -file => "$infasta", -format => 'fasta');
print STDERR "\n\n1) Parsing fasta file.\n\n";
while(my $seqobj = $seqio->next_seq()) {
    my $id = $seqobj->id();
    my $length = $seqobj->length();
    $total_length += $length;
    $total_seq++;
    print STDERR "\tProcessing sequence $id ($total_seq)      \r";
    $length{$id} = $length;
}
print STDERR "\n\n";
print STDERR "\n\n2) Analyzing length distribution.\n";
my ($N95l, $N90l, $N75l, $N50l, $N25l, $N95i, $N90i, $N75i, $N50i, $N25i);
my $t_n95 = $total_length * 95 / 100;
my $t_n90 = $total_length * 90 / 100;
my $t_n75 = $total_length * 75 / 100;
my $t_n50 = $total_length * 50 / 100;
my $t_n25 = $total_length * 25 / 100;
my @ord_ids = sort { $length{$b} <=> $length{$a} } keys %length;
my $l_sum = 0;
my $seq_n = 0;
foreach my $id (@ord_ids) {
    $l_sum += $length{$id};
    $seq_n++;
    if ($l_sum > $t_n25 && !$N25l) {
	$N25l = $length{$id};
	$N25i = $seq_n;
    } 
    elsif ($l_sum > $t_n50 && !$N50l) {
	
	$N50l = $length{$id};
	$N50i = $seq_n;
    }
    elsif ($l_sum > $t_n75 && !$N75l) {
	
	$N75l = $length{$id};
	$N75i = $seq_n;
    }
    elsif ($l_sum > $t_n90 && !$N90l) {
	
	$N90l = $length{$id};
	$N90i = $seq_n;
    }
    elsif ($l_sum > $t_n95 && !$N95l) {
	
	$N95l = $length{$id};
	$N95i = $seq_n;
    }
}

my $max = $length{$ord_ids[0]};
my $min = $length{$ord_ids[-1]};
my $avg = $total_length / $total_seq;

print STDOUT "\n\n==========================================================";
print STDOUT "\n= REPORT:                                                =\n";
print STDOUT "==========================================================\n";
print STDOUT "Sequence Count:\t$total_seq sequences\n";
print STDOUT "Total Length:\t$total_length bp\n";
print STDOUT "Longest sequence:\t$max bp\t(ID = $ord_ids[0])\n";
print STDOUT "Shortest sequence:\t$min bp\t\t(ID = $ord_ids[-1])\n";
print STDOUT "Average length:\t$avg bp\n";
print STDOUT "N95 length:\t$N95l bp\n";
print STDOUT "N95 index:\t$N95i sequences\n";
print STDOUT "N90 length:\t$N90l bp\n";
print STDOUT "N90 index:\t$N90i sequences\n";
print STDOUT "N75 length:\t$N75l bp\n";
print STDOUT "N75 index:\t$N75i sequences\n";
print STDOUT "N50 length:\t$N50l bp\n";
print STDOUT "N50 index:\t$N50i sequences\n";
print STDOUT "N25 length:\t$N25l bp\n";
print STDOUT "N25 index:\t$N25i sequences\n";
print STDOUT "==========================================================\n";


if (defined $out) {

    print STDERR "\n\n3) Output file enabled. Printing length.\n";

    open my $ofh, '>', $out;
    foreach my $id (@ord_ids) {
	
	print $ofh "$id\t$length{$id}\n";
    }
}
 
print STDERR "\n\nDONE\n\n";


=head2 help
  Usage: help()
  Desc: print help of this script
  Ret: none
  Args: none
  Side_Effects: exit of the script
  Example: if (!@ARGV) {
               help();
           }
=cut

sub help {
  print STDERR <<EOF;
  $0:
    Description:
       A script to get the sequence length of each sequence of a fasta file. 
 
       It will print the following stats:
       Number of sequences: Count
       Total length:        Length 
       Longest sequence:    Length   ID
       Shortest sequence:   Length   ID
       Average length:      Length
       N95:                 Length   Index
       N90:                 Length   Index
       N75:                 Length   Index
       N50:                 Length   Index
       N25:                 Length   Index
    Usage:
       
       FastaSeqStats.pl [-h] -i <input_fasta_file> [-o <output>]
    Flags:
      -i <input_fasta_file>      input fasta file (mandatory)
      -o <output_basename>       output file (by default only stats will 
                                 be printed)
      -h <help>                  print the help
     
EOF
exit (1);
}
