require File.dirname(__FILE__) + '/spec_helper.rb'

describe Brcobranca do
  it "should validate default options" do
    Brcobranca::Config::OPCOES[:gerador].should eql('rghost')
    Brcobranca::Config::OPCOES[:tipo].should eql('pdf')
  end  
end