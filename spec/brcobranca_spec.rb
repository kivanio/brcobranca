require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Brcobranca" do
  it "Validar opções padrão" do
    Brcobranca::Config::OPCOES[:gerador].should eql('rghost')
    Brcobranca::Config::OPCOES[:tipo].should eql('pdf')
  end
end