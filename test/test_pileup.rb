$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
$: << File.expand_path('.')
require 'rubygems'
require 'bio/db/pileup'
require "test/unit"


class TestPileup < Test::Unit::TestCase
  
  def setup
    @pu = Bio::DB::Pileup.new("seq1	279	C	23	A..T,,.,.,...,,,.,.....	;75&<<<<<<<<<=<<<9<<:<<")
    #a snp...
    @pu2 = Bio::DB::Pileup.new("seq1	279	C	23	ATTT,,.,.TTTT,,,.,TTTTT	;75&<<<<<<<<<=<<<9<<:<<")
    #an indel..
    @pu3 = Bio::DB::Pileup.new("seq2	156	*	+AG/+AG	71	252	99	11	+AG	*	3	8	0")
  end
  
  def test_non_ref_count
    assert_equal(2, @pu.non_ref_count)
  end
  
  def test_ref_count
    assert_equal(21, @pu.ref_count)
  end
  
  def test_non_refs
    assert_equal(1, @pu.non_refs[:T])
    assert_equal(1, @pu.non_refs[:A])
    assert_equal(0, @pu.non_refs[:G])
    assert_equal(0, @pu.non_refs[:C])
  end
  
  def test_ref_count
    assert_equal('T', @pu2.consensus)
  end
  
  def test_to_vcf
    @vcf = Bio::DB::Vcf.new(@pu.to_vcf)
     assert_equal('seq1', @vcf.chrom)
  end
  
  def test_indel_gt
    indel =  @pu3.send(:indel_gt)
    assert_equal('IAG', indel[0])
    assert_equal('1/1', indel[1])
  end
  
  def test_snp_gt
    snp =  @pu2.send(:snp_gt)
    assert_equal('T,', snp[0])
    assert_equal('1/2', snp[1])
  end
  
  def test_genotype_list
    gt2 = @pu2.genotype_list
    gt3 = @pu3.genotype_list
    assert_equal('T,', gt2[0])
    assert_equal('1/2', gt2[1])
    assert_equal('IAG', gt3[0])
    assert_equal('1/1', gt3[1])
  end
  
  def test_iupac_to_base
    iupac = Bio::DB::Pileup.iupac_to_base('R')
    iupac.each do |pu|
      assert_send([['A' , 'G'], :member?, pu])
    end
  end
  
end