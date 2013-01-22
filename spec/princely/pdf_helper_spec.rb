require File.dirname(__FILE__) + '/../spec_helper'

describe "PdfHelper" do
  module RailsMod
    def render(options = nil, *args, &block)
      "render in RailsMod"
    end
    def send_data(*args)
      "sent"
    end
  end

  class Test
    include RailsMod
    include PdfHelper
  end

  subject {Test.new}

  it "render without options should call super" do
    subject.render.should == "render in RailsMod"
  end

  it "renders with options" do
    Princely.stub(:new => stub(:add_style_sheets => "", :pdf_from_string => ""))
    stub_const("Rails", stub(:public_path => ""))
    subject.stub(:render_to_string => "")
    subject.render({:pdf => "file_name", :template => "controller/action.pdf.erb"}).should == "sent"
  end

  it "renders with the correct asset file path for the stylesheets" do
    princly = stub(:pdf_from_string => "")
    Princely.stub(:new => princly)
    subject.stub(:render_to_string => "", :config => stub(:stylesheets_dir => "/"))
    stub_const("Rails", stub(:application => stub(:assets => false), :public_path => ""))
    princly.should_receive(:add_style_sheets).with("/test.css")
    subject.render({:pdf => "file_name", :template => "controller/action.pdf.erb", :stylesheets => ["test.css"]}).should == "sent"
  end
end