require 'spec_helper'

describe Princely do
  let(:html_doc) { "<html><body>Hello World</body></html>"}
  before {stub_const("File", stub(:executable? => true, :dirname => "/", :expand_path => "", :basename => "in_rails"))}

  it "generates a PDF from HTML" do
    stub_const("Rails", stub(:root => stub(:join => "log"), :logger => stub(:info => "")))
    pdf = Princely.new(:path => "/some/fake/path")
    pdf.stub(:prince_command_result => "%PDF-1.4 #{"x" * 100} %%EOF")
    pdf = pdf.pdf_from_string html_doc
    pdf.should start_with("%PDF-1.4")
    pdf.rstrip.should end_with("%%EOF")
    pdf.length.should > 100
  end

  describe "executable" do
    it "raises an error if path does not exist" do
      stub_const("File", stub(:executable? => false))
      expect { Princely.new(:path => "/some/fake/path") }.to raise_error
    end

    it "raises an error if blank" do
      expect { Princely.new(:path => "") }.to raise_error
    end
  end

  describe "logger" do
    it "defaults to STDOUT" do
      prince = Princely.new(:path => "/some/fake/path")
      prince.logger.should == Princely::StdoutLogger
    end

    it "can be set" do
      LoggerClass = Class.new
      prince = Princely.new(:logger => LoggerClass.new, :path => "/some/fake/path")
      prince.logger.should be_an_instance_of LoggerClass
    end
  end

  describe "log_file" do
    it "defaults in Rails" do
      stub_const("Rails", stub(:root => stub(:join => "rails log"), :logger => stub(:info => "")))
      prince = Princely.new(:path => "/some/fake/path")
      prince.log_file.to_s.should == 'rails log'
    end

    it "defaults outside of Rails" do
      File.stub(:dirname).and_return('outside_rails')
      prince = Princely.new(:path => "/some/fake/path")
      prince.log_file.should == File.expand_path('outside_rails/log/prince.log')
    end
  end

  describe "exe_path" do
    let(:prince) { Princely.new(:path => "/some/fake/path") }

    before(:each) do
      prince.stub(:log_file).and_return('/tmp/test_log')
      prince.exe_path = "/tmp/fake"
    end

    it "appends default options" do
      prince.exe_path.should == "/tmp/fake --input=html --server --log=/tmp/test_log "
    end

    it "adds stylesheet paths" do
      prince.style_sheets = " -s test.css "
      prince.exe_path.should == "/tmp/fake --input=html --server --log=/tmp/test_log  -s test.css "
    end
  end

  describe "find_prince_executable" do
    let(:prince) { Princely.new(:path => "/some/fake/path") }

    it "returns a path for windows" do
      prince.stub(:ruby_platform).and_return('mswin32')
      prince.find_prince_executable.should == "C:/Program Files/Prince/Engine/bin/prince"
    end

    it "returns a path for OS X" do
      prince.stub(:ruby_platform).and_return('x86_64-darwin12.0.0')
      prince.find_prince_executable.should == `which prince`.chomp
    end
  end
end