# coding: utf-8
require 'couchrest-from_path/ext'
require 'fakefs/spec_helpers'

describe CouchRest::Document do
  include FakeFS::SpecHelpers
  
  def create_file(path)
    FileUtils.mkdir_p File.basename(path)
    File.open(path, 'w+') do |io|
      contents = yield io
      io.write(contents) if contents
    end
  end
  
  before(:each) do
    create_file('./db/design/_id') { '_design/User' }
    create_file('./db/design/views/all/map.js') { %q~function map(doc) { emit(doc['_id'], 1) }~ }
    create_file('./db/normal/_id') { 'normal_id' }
  end
  
  describe ".find_files" do
    before(:all) { CouchRest::Document.public_class_method  :find_files }
    after(:all)  { CouchRest::Document.private_class_method :find_files }
    
    it "should only find files" do
      CouchRest::Document.find_files('./db/design').should == ['./db/design/_id', './db/design/views/all/map.js']
    end
  end
  
  describe ".from_path" do
    subject { CouchRest::Document.from_path('./db/design') }
    
    it "should recurse into subdirectories" do
      subject['views']['all']['map.js'].should be_a String
    end
    
    it "should have read file contents of nodes" do
      subject['_id'].should == '_design/User'
    end
    
    it { should be_a CouchRest::Design }
    
    describe "normal document" do
      specify { CouchRest::Document.from_path('./db/normal').should_not be_a CouchRest::Design }
    end
    
    context "given a block" do
      it "should allow us to modify file contents" do
        doc = CouchRest::Document.from_path('./db/design') do |path, contents|
          [path, 'LAWL']
        end
        
        doc['_id'].should == 'LAWL'
        doc['views']['all']['map.js'] == 'LAWL'
      end
      
      it "should allow us to modify filename" do
        doc = CouchRest::Document.from_path('./db/design') do |path, contents|
          [path.sub(/.js\z/, ''), contents]
        end
        
        doc['views']['all']['map.js'].should be_nil
        doc['views']['all']['map'].should_not be_nil
      end
    end
  end
end

