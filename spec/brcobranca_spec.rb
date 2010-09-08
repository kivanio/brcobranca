require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Brcobranca" do
  it "Validar opções padrão" do
    Brcobranca::Config.gerador.should eql(:rghost)
    Brcobranca::Config.formato.should eql(:pdf)
  end

  # it "setar configurações" do
  #     Brcobranca::Config.setup do |config|
  #       config.gerador = :prawn
  #       # config.formato = :gif
  #     end
  #     Brcobranca::Config.gerador.should eql(:prawn)
  # Brcobranca::Config.formato.should eql(:gif)
  # end
end