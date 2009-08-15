require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Brcobranca
  module Boleto
    module Template
      describe Util do
        it "should get correct file" do
          boleto_novo = BancoBanespa.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoBradesco.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoBrasil.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoHsbc.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoItau.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoReal.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false

          boleto_novo = BancoUnibanco.new
          File.exist?(boleto_novo.monta_logo).should be_true
          File.stat(boleto_novo.monta_logo).zero?.should be_false
          
          boleto_novo = Brcobranca::Boleto::Base.new
          boleto_novo.monta_logo.should be_false
        end
      end
    end
  end
end