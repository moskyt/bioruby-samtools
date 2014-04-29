$: << File.expand_path(File.dirname(__FILE__) + '/../lib')
$: << File.expand_path('.')
require 'rubygems'
require 'ffi'
require "test/unit"
require "bio/db/sam"
require "bio/db/sam/sam"
require "bio/db/pileup"
require "bio/db/vcf"

class TestBioDbSam < Test::Unit::TestCase

  #Set up the paths
  def setup
    @test_folder                = "test/samples/small"
    @testTAMFile                = @test_folder + "/test.tam"
    @testBAMFile                = @test_folder + "/testu.bam"
    @testReference              = @test_folder + "/test_chr.fasta"
    
  end
  
  #Removing the index files
  def teardown
    begin
      File.delete(@testReference + ".fai")
      #p "deleted: " + @testReference + ".fai "
    rescue
    end
    begin
      File.delete(@testBAMFile + ".fai")
      #p "deleted: " + @testBAMFile + ".bai "
    rescue
    end
  end

  def default_test
    #puts $LOAD_PATH
    assert(true, "Unit test test")
  end

  def test_openSAMFile
    bamfile                      = Bio::DB::SAM::Tools.samopen(@testTAMFile,"r",nil)
    Bio::DB::SAM::Tools.samclose(bamfile)
    assert(true, "file open and closed")
  end

  def test_new_class_empty
    begin
      bam                        = Bio::DB::Sam.new({})
      assert(false, "Should fail while opening without parameters")
    rescue Bio::DB::Exception => e
      #puts e.message
      assert(true, e.message)
    end
  end

  def test_new_class_empty_invalid_path
    begin
      sam                        = Bio::DB::Sam.new({:bam=>"INVALID"})
      sam.open
      sam.close
      assert(false, "Should fail with an invalid path")
    rescue Bio::DB::Exception => e
      #puts e.message
      assert(true, e.message)
    end
  end

  def test_class_text_read_no_faidx
    sam                          = Bio::DB::Sam.new({:tam=>@testTAMFile})
    sam.open
    sam.close
    assert(true, "file open and closed with the class")
  end

  def test_class_text_read_no_close

    fam                          = Bio::DB::Sam.new({:tam=>@testTAMFile})
    fam.open
    fam                          = nil   
    ObjectSpace.garbage_collect

    assert(true, "file openend but not closed")
  end

  def test_class_binary_read_no_close

    Bio::DB::Sam.new({:bam=>@testBAMFile}).open
    ObjectSpace.garbage_collect
    assert(true, "BINARY file openend but not closed")  
  end

  def test_read_coverage
     sam       = Bio::DB::Sam.new({:bam=>@testBAMFile, :fasta=>@testReference})
     sam.open
  	File.open( @test_folder +"/ids2.txt", "r") do |file|
  	  #puts "file opened"
  	  file.each_line{|line|
        fetching = line.split(' ')[0]
        #puts "fetching: " + fetching
  	    sam.load_reference
    	  seq = sam.fetch_reference(fetching, 0, 16000)
  #	  puts seq 
  #	  puts seq.length
  	  als = sam.fetch(fetching, 0, seq.length) 
     #      p als
  	  if als.length() > 0 then
  	      # p fetching
          #      p als
  	    end
           }

  	end
    sam.close
   assert(true, "Finish")
  end
#  def test_read_TAM_as_BAM
#    begin
#      sam                          = Bio::DB::Sam.new({:bam=>@testTAMFile})
#      sam.open
#      sam.close
#      assert(false, "Should raise an exception for reading a BAM as TAM") 
#    rescue Bio::DB::Exception => e
#      assert(true, "Properly handled")
#    end 
#  end

# def test_read_BAM_as_TAM
#    begin
#      sam                          = Bio::DB::Sam.new({:tam=>@testBAMFile})
#      sam.open
#      sam.close
#      assert(false, "Should raise an exception for reading a BAM as TAM") 
#    rescue Bio::DB::Exception => e
#      assert(true, "Properly handled")
#    end 
#  end

  def test_bam_load_index
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    index = sam.load_index
    sam.close
    assert(true, "BAM index loaded")
    #  attach_function :bam_index_build, [ :string ], :int
    #  attach_function :bam_index_load, [ :string ], :pointer
    #  attach_function :bam_index_destroy, [ :pointer ], :void
  end

  def test_tam_load_index
    begin
      sam       = Bio::DB::Sam.new({:tam=>@testTAMFile})
      sam.open
      sam.load_index
      sam.close
      assert(false, "TAM index loaded")
    rescue Bio::DB::Exception => e
      assert(true, "Unable to load an index for a TAM file")
    end
  end

  def test_read_segment
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    als = sam.fetch("chr_1", 0, 500)
    #p als 
    sam.close
    assert(true, "Seems it ran the query")
    #node_7263       238     60 has 550+, query from 0 to 500, something shall come.... 
  end

=begin ##these tests are correct-ish but the functionality isnt implemented yet ... 
  def test_read_invalid_reference
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    begin
      als = sam.fetch("Chr1", 0, 500)
      #p als 
      sam.close
      assert(false, "Seems it ran the query")
    rescue Bio::DB::Exception => e
      #p e
      assert(true, "Exception generated and catched")
    end
  end

  def test_read_invalid_reference_start_coordinate
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    begin
      als = sam.fetch("chr", -1, 500)
      #p als 
      sam.close
      assert(false, "Seems it ran the query")
    rescue Bio::DB::Exception => e
      #p e
      assert(true, "Exception generated and catched")
    end
  end

  def test_read_invalid_reference_end_coordinate
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    begin
      als = sam.fetch("chr", 0, 50000)
      #p als 
      sam.close
      assert(false, "Seems it ran the query")
    rescue  Bio::DB::Exception => e
      #p e
      assert(true, "Exception generated and catched")
    end
  end
 
  def test_read_invalid_reference_swaped_coordinates
    sam       = Bio::DB::Sam.new({:bam=>@testBAMFile})
    sam.open
    begin
      als = sam.fetch("chr", 500, 0)
      #p als 
      sam.close
      assert(false, "Seems it ran the query")
    rescue  Bio::DB::Exception => e
      #p e
      assert(true, "Exception generated and catched")
    end
  end
=end 
  def test_fasta_load_index
    sam = Bio::DB::Sam.new({:fasta=>@testReference})
    sam.load_reference
    seq = sam.fetch_reference("chr_1", 0, 500)
    #p seq 
    sam.close
    assert(true, "The reference was loaded")
  end
  
  def test_fasta_load_index
    sam = Bio::DB::Sam.new({:fasta=>@testReference})
    sam.load_reference
    begin
      seq = sam.fetch_reference("chr1", 0, 500)
      #p "Error seq:"+ seq 
      sam.close
      assert(false, "The reference was loaded")
    rescue Bio::DB::Exception => e
      #p e
      assert(true,  "The references was not loaded")
    end
  end
  
  def test_load_feature
    
    fs = Feature.find_by_bam("chr_1", 0, 500,@testBAMFile)
    
    #p fs
    assert(true, "Loaded as features")
  end
  
  def test_avg_coverage
    sam = Bio::DB::Sam.new(:fasta=>@testReference, :bam=>@testBAMFile )
    sam.open
    cov = sam.average_coverage("chr_1", 60, 30)
    #p "Coverage: " + cov.to_s
    sam.close
    assert(true, "Average coverage ran")
    assert(3 == cov, "The coverage is 3")
  end
  

  def test_chromosome_coverage
    sam = Bio::DB::Sam.new({:fasta=>@testReference, :bam=>@testBAMFile })
    sam.open
    covs = sam.chromosome_coverage("chr_1", 0, 60)
    #p "Coverage: "
    #p covs
    #puts "POS\tCOV"
    covs.each_with_index{ |cov, i| puts "#{i}\t#{cov}" }
    sam.close
    assert(true, "Average coverage ran")
    #assert(3 == cov, "The coverage is 3")
  end
  
  #test whether the call to mpileup works and returns 10 objects of class pileup
  def test_mpileup
    sam = Bio::DB::Sam.new(:fasta=>@testReference, :bam=>@testBAMFile )
    pileup_list = []
    sam.mpileup(:region => "chr_1:100-109") do |pile|
      #next unless pile.ref_name == 'chr_1' ##required because in the test environment stdout gets mixed in with the captured stdout in the function and non pileup lines are passed...
      pileup_list << pile
    end
    assert_equal(10,pileup_list.length)
    pileup_list.each  do |p|
      assert_kind_of(Bio::DB::Pileup, p)
    end
  end
  
  #test whether the call to experimental mpileup_plus returns vcf or pileup objects appropriately
  #return ten objects of each class according to set of :g option
  def test_mpileup_plus
    sam = Bio::DB::Sam.new(:fasta=>@testReference, :bam=>@testBAMFile)
    list = []
    sam.mpileup_plus(:region => "chr_1:100-109") do |pile|
      list << pile
    end
    assert_equal(10,list.length)
    list.each {|p| assert_kind_of(Bio::DB::Pileup, p)}
    vcf_list = []
    sam.mpileup_plus(:region => "chr_1:100-109", :g => true) do |vcf|
      vcf_list << vcf
    end
    assert_equal(10,vcf_list.length)
    vcf_list.each {|p| assert_kind_of(Bio::DB::Vcf, p)}
  end
  
  # test whether command line calls to mpileup are correctly escaped
  def test_mpileup_escaping
    test_dir = File.join('test','samples','pipe_char')
    sam = Bio::DB::Sam.new(
      :fasta => File.join(test_dir,'test_chr.fasta'),
      :bam => File.join(test_dir, 'test.bam')
    )
    pileup_list = []
    sam.mpileup(:region => "gi|123|chr_1:100-109") do |pile|
      pileup_list << pile
    end
    assert_equal(10,pileup_list.length)
    pileup_list.each  do |p|
      assert_kind_of(Bio::DB::Pileup, p)
    end
  end
  
  # test whether command line calls to mpileup are correctly escaped
  def test_mpileup_error_reporting
    test_dir = File.join('test','samples','pipe_char')
    sam = Bio::DB::Sam.new(
      :fasta => File.join(test_dir,'does_not_exist.fasta'),
      :bam => File.join(test_dir, 'test.bam')
    )
    assert_raise Bio::DB::Exception do
      pileup_list = []
      sam.mpileup(:region => "gi|123|chr_1:100-109") do |pile|
        pileup_list << pile
      end
    end
  end

  #test whether the call to mpileup returns a vcf object if :g => true is used on the command-line
#  def test_vcf

#    sam = Bio::DB::Sam.new(:fasta=>@testReference, :bam=>@testBAMFile )
#        sam.mpileup(:region => "chr_1:100-109", :u => true ) do |p|
#        $stderr.puts "p is #{p}"
#        assert_kind_of(String,p)
#    end
#  end
  def test_indexstats

    sam = Bio::DB::Sam.new(:bam => @testBAMFile, :fasta => @testReference)
    assert_equal({"chr_1"=>{:length=>69930, :mapped_reads=>0, :unmapped_reads=>0},
                  "*"=>{:length=>0, :mapped_reads=>0, :unmapped_reads=>0}
                 }, sam.index_stats)
  end
  
  def test_each_reference
    sam = Bio::DB::Sam.new(:bam => @testBAMFile, :fasta => @testReference)
    sam.each_reference do |name, length|
      next if name == '*'
      assert_equal name, "chr_1"
      assert_equal length, 69930
    end
  end
  
  def test_view
    sam = Bio::DB::Sam.new(:bam => @testBAMFile, :fasta => @testReference)
    sam.open 
    count = 0
    sam.view() do |aln|
      count = count +1
    end
    assert_equal count, 9
  end
  
  def test_view_b
    sam = Bio::DB::Sam.new(:bam =>"/Users/macleand/Desktop/AT1/realigned.bam", :fasta => "/Users/macleand/src/data/ash_dieback/chalara_fraxinea/Kenninghall_wood_KW1/assemblies/gDNA/KW1_assembly_version1/Chalara_fraxinea_TGAC_s1v1_scaffolds.fa")
    sam.open 
    count = 0
    sam.view_b do |aln|

      count = count +1
    end
    puts "count is: #{count}"
    assert_equal count, 9
  end
  
#  def test_view_big
#    puts "...woot"
#    sam = Bio::DB::Sam.new(:bam => "/Users/macleand/Desktop/AT1/realigned.bam", :fasta => "/Users/macleand/src/data/ash_dieback/chalara_fraxinea/Kenninghall_wood_KW1/assemblies/gDNA/KW1_assembly_version1/Chalara_fraxinea_TGAC_s1v1_scaffolds.fa")
#    sam.open
#    sam.view do |aln|
#      puts aln
#    end
#  end
  
end

class Feature 
attr_reader :start, :end, :strand, :sequence, :quality

def initialize(a={})
  #p a
  @start = a[:start]
  @end = a[:enf]
  @strand = a[:strand]
  @sequence = a[:sequence]
  @quality = a[:quality]
end

def self.find_by_bam(reference,start,stop,bam_file_path)
  
  sam = Bio::DB::Sam.new({:bam=>bam_file_path})
  features = []
  sam.open
  
  fetchAlignment = Proc.new do |a|
    a.query_strand ? strand = '+'  : strand = '-'
    features << Feature.new({:start=>a.pos,:end=>a.calend,:strand=>strand,:sequence=>a.seq,:quality=>a.qual})
  end
  sam.fetch_with_function(reference, start, stop, fetchAlignment)
  sam.close
  features
end
end
