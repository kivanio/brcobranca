require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

module Brcobranca
  module Boleto
    module Template
      describe Rghost do

        before(:each) do
          @valid_attributes = {
            :especie_documento => "DM",
            :moeda => "9",
            :data_documento => Date.today,
            :dias_vencimento => 1,
            :aceite => "S",
            :quantidade => 1,
            :valor => 0.0,
            :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
            :cedente => "Kivanio Barbosa",
            :documento_cedente => "12345678912",
            :sacado => "Claudio Pozzebom",
            :sacado_documento => "12345678900",
            :agencia => "4042",
            :conta_corrente => "61900",
            :convenio => 12387989,
            :numero_documento => "777700168"
          }
        end

        it "Gerar boleto nos formatos válidos" do
          @valid_attributes[:valor] = 135.00
          @valid_attributes[:data_documento] = Date.parse("2008-02-01")
          @valid_attributes[:dias_vencimento] = 2
          @valid_attributes[:convenio] = 1238798
          @valid_attributes[:numero_documento] = "7777700168"
          boleto_novo = BancoBrasil.new(@valid_attributes)
          boleto_novo.should be_instance_of(BancoBrasil)
          boleto_novo.monta_codigo_43_digitos.should eql("0019377100000135000000001238798777770016818")
          boleto_novo.codigo_barras.should eql("00193377100000135000000001238798777770016818")
          boleto_novo.codigo_barras.linha_digitavel.should eql("00190.00009 01238.798779 77700.168188 3 37710000013500")
          boleto_novo.conta_corrente_dv.should eql(0)

          %w| pdf jpg tif png ps |.each do |format|
            file_body=boleto_novo.to(format.to_sym)
            tmp_file=Tempfile.new("foobar." << format)
            tmp_file.puts file_body
            tmp_file.close
            File.exist?(tmp_file.path).should be_true
            File.stat(tmp_file.path).zero?.should be_false
            File.delete(tmp_file.path).should eql(1)
            File.exist?(tmp_file.path).should be_false
          end
          file_body=boleto_novo.to
          tmp_file=Tempfile.new("foobar.")
          tmp_file.puts file_body
          tmp_file.close
          File.exist?(tmp_file.path).should be_true
          File.stat(tmp_file.path).zero?.should be_false
          File.delete(tmp_file.path).should eql(1)
          File.exist?(tmp_file.path).should be_false
        end
      end
    end
  end
end