use Test::More tests => 38, 'die';

use FindBin qw( $Bin );

BEGIN { use_ok 'Bio::DB::HTS::VCF'; }

{
  # Test sweep functions
  my $sweep = Bio::DB::HTS::VCF::Sweep->new(filename => $Bin . "/data/test.vcf.gz");
  my $h = $sweep->header ;

  my $row = $sweep->next_row();
  is $row->chromosome($h), "19", "Chromosome value read" ;
  #This should one day be fixed to 2 - but the HTSlib API always returns 0 at the moment
  #is $row->num_filters(), "2", "Number of filters read" ;
  #Once that is corrected, also add a test for the filters themselves

  $row = $sweep->previous_row();
  is $row->chromosome($h), "X", "Chromosome value read" ;
  is $row->position(), 10, "Position value read" ;
  is $row->quality(), 10, "Quality value read" ;

  $row = $sweep->previous_row();
  is $row->reference(), "T", "Quality value read" ;

  $row = $sweep->previous_row();
  is $row->id(), "microsat1", "ID value read" ;
  is $row->num_alleles(), 2, "Number of alleles value read" ;
  my $a_team = $row->get_alleles() ;
  isa_ok($a_team, 'ARRAY');
  is_deeply $a_team, ['GA', 'GAC'], 'alleles are correct';

  $sweep->close() ;
}

{
  # Test standard functions
  ok my $v = Bio::DB::HTS::VCF->new( filename => $Bin . "/data/test.vcf.gz" ), "file open";
  is $v->num_variants(), 9, 'correct number of variants identified in file';

  my $h = $v->header();
  is $h->version(), "VCFv4.0", "VCF Header version matches" ;
  is $h->num_samples(), 3, "Number of samples" ;
  is_deeply $h->get_sample_names(), ['NA00001','NA00002','NA00003'], "sample names correct" ;
  is $h->num_seqnames(), 3, "Number of seqnames" ;
  is_deeply $h->get_seqnames(), ['19','20','X'], "sequence names correct" ;

  ok my $row = $v->next(), "Next row";
  is $row->chromosome($h), "19", "Chromosome value read" ;
  is $row->position(), "111", "Position value read" ;
  is $row->id(), "testid", "ID value read" ;
  is $row->num_filters(), 2, "Num Filters OK" ;
  is $row->has_filter($h,"DP50"), 1, "Actual Filter present" ;
  is $row->has_filter($h,"."), 0, "PASS filter absent" ;
  is $row->get_variant_type(1),1, "Variant type matches" ;

  my $info_result ;
  $row->get_info($h,"AF") ;
  isa_ok($info_result, 'ARRAY');
  is_deeply $info_result, [1], 'info flag read correctly';

  $info_result = $row->get_info($h,"AF") ;
  isa_ok($info_result, 'ARRAY');
  is_deeply $info_result, [0.5], 'info float read correctly';

  $info_result = $row->get_info($h,"TT") ;
  isa_ok($info_result, 'ARRAY');
  is_deeply $info_result, ['STR1,STR2'], 'info strings read correctly';

  $info_result = $row->get_info($h,"NS") ;
  isa_ok($info_result, 'ARRAY');
  is_deeply $info_result, [3], 'info ints read correctly';

  Bio::DB::HTS::VCF::Row->destroy($row) ;

  ok $row = $v->next(), "Next row";
  is $row->chromosome($h), "19", "Chromosome value read" ;
  is $row->position(), "112", "Position value read" ;
  is $row->quality(), "10", "Quality value read" ;
  is $row->reference(), "A", "Reference value read" ;
  is $row->num_alleles(), 1, "Num Alleles" ;
  is $row->is_snp(), 1, "Is SNP" ;
  my $a_team = $row->get_alleles() ;
  isa_ok($a_team, 'ARRAY');
  is_deeply $a_team, ['G'], 'alleles are correct';
  is $row->num_filters(), 1, "Num Filters OK" ;
  is $row->has_filter($h,"PASS"), 1, "PASS Filter present" ;
  is $row->has_filter($h,"DP50"), 0, "Actual Filter absent" ;
  is $row->has_filter($h,"sdkjsdf"), -1, "Made up filter not existing" ;
  Bio::DB::HTS::VCF::Row->destroy($row) ;
  $v->close();
}
