# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe 'Muúltiplos boletos' do #:nodoc:[all]

  before(:each) do
    @valid_attributes = {
        :especie_documento => 'DM',
        :moeda => '9',
        :data_documento => Date.today,
        :dias_vencimento => 1,
        :aceite => 'S',
        :quantidade => 1,
        :valor => 0.0,
        :local_pagamento => 'QUALQUER BANCO ATÉ O VENCIMENTO',
        :beneficiario => 'Kivanio Barbosa',
        :documento_beneficiario => '12345678912',
        :pagador => 'Claudio Pozzebom',
        :pagador_documento => '12345678900',
        :agencia => '4042',
        :conta_corrente => '61900',
        :convenio => 12387989,
        :numero_documento => '777700168'
    }
  end

  it 'imprimir múltiplos boleto em lote' do
    boleto_1 = Brcobranca::Boleto::BancoBrasil.new(@valid_attributes)
    boleto_2 = Brcobranca::Boleto::Bradesco.new(@valid_attributes)
    boleto_3 = Brcobranca::Boleto::BancoBrasil.new(@valid_attributes)

    boletos = [boleto_1, boleto_2, boleto_3]

    %w| pdf jpg tif png ps |.each do |format|
      file_body=Brcobranca::Boleto::Base.lote(boletos, {:formato => "#{format}".to_sym})
      tmp_file=Tempfile.new('foobar.' << format)
      tmp_file.puts file_body
      tmp_file.close
      File.exist?(tmp_file.path).should be_true
      File.stat(tmp_file.path).zero?.should be_false
      File.delete(tmp_file.path).should eql(1)
      File.exist?(tmp_file.path).should be_false
    end
  end

end