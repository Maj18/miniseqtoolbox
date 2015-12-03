#-*-Perl-*-

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.t'

use strict;
use ExtUtils::MakeMaker;
use File::Temp qw(tempfile);
use FindBin '$Bin';
use constant TEST_COUNT => 268;

use lib "$Bin/../lib","$Bin/../blib/lib","$Bin/../blib/arch";

BEGIN {
  # to handle systems with no installed Test module
  # we include the t dir (where a copy of Test.pm is located)
  # as a fallback
  eval { require Test; };
  if( $@ ) {
    use lib 't';
  }
  use Test;
  plan test => TEST_COUNT;
}

use Bio::DB::HTS;
use Bio::DB::HTS::AlignWrapper;

{
  ## Tests by keiranmraine@gmail.com (kr2@sanger.ac.uk) for fixing alignments with hard + soft clips
  # 49 tests

  # !! not-forced ref-seq

  my @read_pos = ([1,120], # 120M
                  [61,120], # 60S60M
                  [1,60], # 60M60H
                  [1,120], # 120M
                  [31,90], # 30H30S60M
                  [1,30], # 30M30S60H
                  [1,30], # 10M10N20M30S60H (N ref skip)
                  );
  my @ref_pos = ( [61, 180],
                  [1081, 1140],
                  [961, 1020],
                  [61, 180],
                  [1081, 1140],
                  [961, 990],
                  [961, 1000],
                  );
  my @read_padded = (
    [ 'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG'],
    [ '------------------------------------------------------------TGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA',
      '                                                            ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGATGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA'],
    [ 'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA'],
    [ 'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG'],
    [ '------------------------------TGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA',
      '                              ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'CATAACTATGAAGAGACTATTGCCAGATGATGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA'],
    [ 'ACATGAGATTATTAGGAAATGCTTTACTGT------------------------------',
      '||||||||||||||||||||||||||||||                              ',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA'],
    [ 'ACATGAGATT----------GCTTTACTGTCATAACTATG------------------------------',
      '||||||||||          ||||||||||||||||||||                              ',
      'ACATGAGATT----------GCTTTACTGTCATAACTATGGAAGAGACTATTGCCAGATGATGTCCATGT'],
  );

  my $sam     = Bio::DB::HTS->new(  -bam => "$Bin/data/ex2.bam",
                                    -fasta => "$Bin/data/ex1.fa",
                                  );
  my $bam = $sam->hts_file ;
  my $record=0;
  while(my $a = $bam->read1)
  {
    ok($a->query->start, $read_pos[$record]->[0], "Check query start $record");
    ok($a->query->end, $read_pos[$record]->[1], "Check query end $record");

    ok($a->start, $ref_pos[$record]->[0], "Check ref pos start $record");
    ok($a->start, $ref_pos[$record]->[0], "Check ref pos end $record");

    my $aw = Bio::DB::HTS::AlignWrapper->new($a, $sam);
    my ($ref, $match, $query) = $aw->padded_alignment;
    ok($ref, $read_padded[$record]->[0], "Check padded_alignment ref $record");
    ok($match, $read_padded[$record]->[1], "Check padded_alignment match $record");
    ok($query, $read_padded[$record]->[2], "Check padded_alignment query $record");
    $record++;
  }
}

{
  ## Tests by keiranmraine@gmail.com (kr2@sanger.ac.uk) for fixing alignments with hard + soft clips
  # 49 tests

  # !! FORCED refseq ref-seq

  my @read_pos = ([1,120], # 120M
                  [61,120], # 60S60M
                  [1,60], # 60M60H
                  [1,120], # 120M
                  [31,90], # 30H30S60M
                  [1,30], # 30M30S60H
                  [1,30], # 10M10N20M30S60H (N ref skip) # changes
                  );
  my @ref_pos = ( [61, 180],
                  [1081, 1140],
                  [961, 1020],
                  [61, 180],
                  [1081, 1140],
                  [961, 990],
                  [961, 1000],
                  );
  my @read_padded = (
    [ 'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG'],
    [ '------------------------------------------------------------TGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA',
      '                                                            ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGATGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA'],
    [ 'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA'],
    [ 'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG',
      '||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'GTGGACCCTGCAGCCTGGCTGTGGGGGCCGCAGTGGCTGAGGGGTGCAGAGCCGAGTCACGGGGTTGCCAGCACAGGGGCTTAACCTCTGGTGACTGCCAGAGCTGCTGGCAAGCTAGAG'],
    [ '------------------------------TGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA',
      '                              ||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||',
      'CATAACTATGAAGAGACTATTGCCAGATGATGTCCATGTACACACGCTGTCCTATGTACTTATCATGACTCTATCCCAAATTCCCAATTA'],
    [ 'ACATGAGATTATTAGGAAATGCTTTACTGT------------------------------',
      '||||||||||||||||||||||||||||||                              ',
      'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATGAAGAGACTATTGCCAGATGA'],
    [ 'ACATGAGATTATTAGGAAATGCTTTACTGTCATAACTATG------------------------------',
      '||||||||||          ||||||||||||||||||||                              ',
      'ACATGAGATT----------GCTTTACTGTCATAACTATGGAAGAGACTATTGCCAGATGATGTCCATGT'],
  );

  my $sam     = Bio::DB::HTS->new(  -bam => "$Bin/data/ex2.bam",
                                    -fasta => "$Bin/data/ex1.fa",
                                    -force_refseq => 1,
                                  );
  my $bam = $sam->bam;
  my $record=0;
  while(my $a = $bam->read1) {
    ok($a->query->start, $read_pos[$record]->[0], "Check query start $record");
    ok($a->query->end, $read_pos[$record]->[1], "Check query end $record");

    ok($a->start, $ref_pos[$record]->[0], "Check ref pos start $record");
    ok($a->start, $ref_pos[$record]->[0], "Check ref pos end $record");

    my $aw = Bio::DB::HTS::AlignWrapper->new($a, $sam);
    my ($ref, $match, $query) = $aw->padded_alignment;
    ok($ref, $read_padded[$record]->[0], "Check padded_alignment ref $record");
    ok($match, $read_padded[$record]->[1], "Check padded_alignment match $record");
    ok($query, $read_padded[$record]->[2], "Check padded_alignment query $record");
    $record++;
  }
}

{
  ## Following tests added by malcolm_cook@stowers.org while
  ## diagnosing, patching "incomplete cigar/split alignments
  ## processing of multi-gaps"
  ## (https://sourceforge.net/tracker/?func=detail&aid=3083769&group_id=27707&atid=391291)
  my $bamfile = "$Bin/data/dm3_3R_4766911_4767130.sam.sorted.bam";
  my $sam     = Bio::DB::HTS->new( -bam => $bamfile,
				   -split_splices => 1,
				   -autoindex => 1,
				 );
  ok($sam);
  ok($sam->split_splices);
  my @alignments = $sam->get_features_by_location("3R");
  ok (75,@alignments,"count of alignments in $bamfile");
  my @e3 = grep {my $c = $_->cigar_str; $c =~ /^\d+M124N3M91N\d+M$/} @alignments;
  ok (9, @e3,	"count of spliced alignments which 'take' the 3bp exon according to CIGAR string");
  my @e3_parts=map {[$_->get_SeqFeatures]} @e3;
  ok($#e3,$#e3_parts,"all have split splices");
  ok((grep {grep {$_->start == 4767036
		    && $_->end == 4767038
		      && $_->hit->seq eq "GCT"
		    } @$_} @e3_parts),@e3_parts,
     "split alignments harboring the 3bp exon");
  ok((grep {grep {$_->end == 4766911 &&
		    do {my $h = $_->hit->seq;
			$h =~ m/GCT$/;
		      }} @$_} @e3_parts),@e3_parts,
     "split alignments having a part (exon) that ends at 4766911 (the donor of the upstream exon)" );
  ok((grep {grep {$_->start == 4767130 &&
		    do {my $h = $_->hit->seq;
			$h =~ m/^TCTTC/;
		      }} @$_} @e3_parts), @e3_parts,
     # This is the test that fails without the patch that motivated
     # these tests.  Prior to patch, 4767006 was the incorrectly computed value
     # for the start of the downstream exon, due to incorrect cigar processing when
     # an alignment spanned multiple introns.
     "split alignments having a part (exon) that starts at 4767130 (the acceptor of the downstream exon)" );
}

# low level tests (defined in lib/Bio/DB/Sam.xs)
{
    my $bamfile = "$Bin/data/ex1.bam";
    my $bam     = Bio::DB::HTSfile->open($bamfile);
    ok($bam);

    my $header  = $bam->header;
    my $targets = $header->n_targets;
    ok($targets,2);

    my $target_names = $header->target_name;
    ok($target_names);
    ok(scalar @$target_names,2);
    ok($target_names->[0],'seq1');

    my $target_lens = $header->target_len;
    ok($target_lens);
    ok(scalar @$target_lens,2);
    ok($target_lens->[0],1575);

    my $text = $header->text;
    ok(length $text > 0);

    my $c = "\@CO\tThis is a comment\n";
    $header->text($c);
    ok($header->text,$c);

    my $fai  = Bio::DB::HTS::Fai->open("$Bin/data/ex1.fa");
    my $seq  = $fai->fetch('seq2:51-1000');
    ok(length $seq,950);

    my $count;
    while (my $b = $bam->read1) {
	$count++;
    }
    ok($count,3307);

    my @result = $header->parse_region('seq2:51-1000');
    ok($result[0],1);
    ok($result[1],50);
    @result    = $header->parse_region('seq_invalid:51-1000');
    ok(scalar @result,0);

    my $index = Bio::DB::HTSfile->index($bamfile,1);
    ok($index);

    my @a;
    my $print_region = sub {
	my($alignment,$data) = @_;
	push @a,$alignment;
	return;
    };

    $index->fetch($bam,$header->parse_region('seq2'),$print_region,"foobar");
    ok(scalar @a > 1);

    my %matches;
    my $fetch_back = sub {
	my ($tid,$pos,$p) = @_;
	my $p1 = $pos+1;
	my $r = $fai->fetch($header->target_name->[$tid].":$p1-$p1");
	for my $pileup (@$p) {
	    my $b    = $pileup->b;
	    my $qpos = $pileup->qpos;
	    my $base = $pileup->indel == 0 ? substr($b->qseq,$qpos,1)
                      :$pileup->indel >  0 ? '*'
                      : '-';
	    $matches{matched}++ if $r eq $base;
	    $matches{total}++;
	}
    };

    $index->pileup($bam,$header->parse_region('seq2:1-100'),$fetch_back);
    ok($matches{matched}/$matches{total} > 0.99);

    # try to get coverage
    my $coverage = $index->coverage($bam,
				   $header->parse_region('seq2'),
				    100,
				    9000
	);
    ok(scalar @$coverage,100);
    my @c = sort {$a<=>$b} @$coverage;
    ok($c[0]  >= 0);
    ok($c[-1] < 1000);

    undef $bam;
    $bam     = Bio::DB::HTSfile->open($filename);
    ok($bam);

    $header  = $bam->header;
    $targets = $header->n_targets;
    ok($targets,2);

    $target_names = $header->target_name;
    ok($target_names);
    ok(scalar @$target_names,2);
    ok($target_names->[0],'seq1');

    $target_lens = $header->target_len;
    ok($target_lens);
    ok(scalar @$target_lens,2);
    ok($target_lens->[0],1575);

    # try removing and regenerating index
    unlink "$Bin/data/ex1.bam.bai";
    ok(Bio::DB::HTSfile->index($bamfile,1));
    ok(-e "$Bin/data/ex1.bam.bai");

}

# high level tests (defined in lib/Bio/DB/Sam.pm)
for my $use_fasta (0,1) {
    my $sam = Bio::DB::HTS->new(-fasta=>"$Bin/data/ex1.fa",
			        -bam  =>"$Bin/data/ex1.bam",
				-expand_flags => 1,
				-autoindex => 1,
				-force_refseq => $use_fasta,
	);
    ok($sam);
    ok($sam->n_targets,2);

    ok($sam->length('seq1'),1575);
    ok(join $sam->seq_ids,'seq1 seq2');

    my $seg = $sam->segment('seq1');
    ok($seg);
    ok($seg->length,1575);
    my $seq = $seg->seq;
    ok($seq->isa('Bio::PrimarySeq'));
    ok(length $seq->seq,1575);

    my $fh = $sam->tam_fh;
    ok($fh);
    my $samline = <$fh>;
    ok($samline =~ /^B7_591:4:96:693:509/);
    $fh->close;

    my ($readname) = $samline =~ /^(\S+)/;
    my ($f) = $sam->get_features_by_name($readname);
    ok($f);
    chomp($samline);
    ok($f->tam_line,$samline);

    my $dummy = eval {Bio::DB::HTS->new(-fasta=>"invalid_path.txt",
					-bam  =>"invalid_path.txt")};
    ok($dummy,undef);
    ok($@ =~ /does not exist/);

    my @alignments =
	$sam->get_features_by_location(
	    -seq_id => 'seq2',
	    -start  => 500,
	    -end    => 800
	);
    ok(scalar @alignments,442);
    ok($alignments[0]->seq_id,'seq2');

    ok(scalar @{$alignments[0]->qscore},length $alignments[0]->dna);

    my @keys = $alignments[0]->get_all_tags;
    ok(scalar @keys,18);
    ok($alignments[0]->get_tag_values('MF'),18);

    my %att  = $alignments[0]->attributes;
    ok(scalar(keys %att),18);
    ok($alignments[0]->cigar_str,'35M');

    $sam->expand_flags(0);
    @keys = $alignments[0]->get_all_tags;
    ok(scalar @keys,7);

    my $query = $alignments[0]->query;
    ok($query);
    ok($query->start,1);
    ok($query->end,35);
    ok($query->length,35);
    ok($query->dna,$alignments[0]->dna);
    ok($alignments[0]->strand,-1);
    ok($query->strand,-1);

    my $target = $alignments[0]->target;
    ok($target);
    ok($target->start,35);
    ok($target->end,1);
    ok($target->length,35);
    ok($target->dna,reversec($alignments[0]->dna));

    ok($alignments[0]->get_tag_values('FLAGS'),$alignments[0]->flag_str);

    my @pads = $alignments[0]->padded_alignment;
    ok(@pads,3);
    ok($pads[0],$pads[2]);
    ok($pads[1]=~tr/|/|/,length($pads[0]));

    my @f = $sam->features(-name=>'EAS114_45:2:1:1140:1206');
    ok(scalar @f,2);

    @f    = $sam->features(-filter=> sub {
	                       my $a = shift;
			       return 1 if $a->display_name eq 'EAS114_45:2:1:1140:1206';
			   });
    ok(scalar @f,2);

    @f = $sam->features(-seq_id  => 'seq2',
			-filter  => sub {
			    my $a = shift;
			    return 1 if $a->display_name =~ /^EAS114/;
			});
    ok(scalar @f,306);
    @f = $sam->features(-filter  => sub {
			    my $a = shift;
			    return 1 if $a->display_name =~ /^EAS114/;
			});
    ok(scalar @f,534);

    @f   = $sam->features(-name=>'EAS114_45:2:1:1140:1206',
			  -tags=>{FIRST_MATE=>1});
    ok(scalar @f,1);

    # try iteration
    my $i = $sam->get_seq_stream(
	-seq_id => 'seq2',
	-start  => 500,
	-end    => 800
	);
    ok($i);
    my $count = 0;
    while ($i->next_seq) { $count++ }
    ok($count,442);

    # try tam fh retrieval
    $fh = $sam->get_seq_fh(
	-seq_id => 'seq2',
	-start  => 500,
	-end    => 800,
	);
    $count = 0;
    $count++ while <$fh>;
    ok($count,442);
    $fh->close;

    $i = $sam->get_seq_stream(); # all features!
    ok($i);
    $count = 0;
    while ($i->next_seq) { $count++ }
    ok($count,3307);

    $i = $sam->get_seq_stream(-max_features=>200,-seq_id=>'seq1');
    ok ($i);
    $count = 0;
    while ($i->next_seq) { $count++ }
    ok($count,200);
    ok($sam->last_feature_count,1482);

    # try the read_pair aggregation
    my @pairs = $sam->features(-type=>'read_pair',
			       -seq_id => 'seq2');
    ok(scalar @pairs,939);

    # try coverage
    my @coverage = $sam->features(-type   => 'coverage',
				  -seq_id => 'seq2');
    ok(scalar @coverage,1);
    my ($c) = $coverage[0]->get_tag_values('coverage');
    ok($c);
    ok($c->[0],3);
    ok($c->[1],4);
    ok($coverage[0]->type,"coverage:1584");

    # test high level API version of pileup
    my %matches;
    my $fetch_back = sub {
	my ($seqid,$pos,$p) = @_;
	my $r = $sam->segment($seqid,$pos,$pos)->dna;
	for my $pileup (@$p) {
	    my $a    = $pileup->alignment;
	    my $qpos = $pileup->qpos;
	    my $dna  = $a->query->dna;
	    my $base = $pileup->indel == 0 ? substr($dna,$qpos,1)
                      :$pileup->indel >  0 ? '*'
                      : '-';
	    $matches{matched}++ if $r eq $base;
	    $matches{total}++;
	}
    };

    $sam->pileup('seq2:1-100',$fetch_back);
    ok($matches{matched}/$matches{total} > 0.99);
}

exit 0;

sub reversec {
    my $dna = shift;
    $dna    =~ tr/gatcGATC/ctagCTAG/;
    return scalar reverse $dna;
}


__END__
# this is not a unit test, but a piece of demo to show cigar string
# processing
    for my $a (@alignments) {
	warn $a->display_name,' :: ',$a->flag_str,' :: ',
	$a->start,'..',$a->end,' ',' mpos=',$a->mate_start,' ins=',$a->isize,
	' qlen=',$a->cigar2qlen,
	' [',$a->strand,'/',$a->mstrand,']',
	' ',
	$a->cigar_str,
	' ',
	$a->mate_start,'..',$a->mate_end,
	"\n";
    }
