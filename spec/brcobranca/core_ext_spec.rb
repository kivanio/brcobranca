# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

module Brcobranca
  describe Formatacao do
    it 'Formata o CPF' do
      98789298790.to_br_cpf.should eql('987.892.987-90')
      '98789298790'.to_br_cpf.should eql('987.892.987-90')
      '987.892.987-90'.to_br_cpf.should eql('987.892.987-90')
    end

    it 'Formata o CEP' do
      85253100.to_br_cep.should eql('85253-100')
      '85253100'.to_br_cep.should eql('85253-100')
      '85253-100'.to_br_cep.should eql('85253-100')
    end

    it 'Formata o CNPJ' do
      88394510000103.to_br_cnpj.should eql('88.394.510/0001-03')
      '88394510000103'.to_br_cnpj.should eql('88.394.510/0001-03')
      '88.394.510/0001-03'.to_br_cnpj.should eql('88.394.510/0001-03')
    end

    it 'Formata números automáticamente de acordo com o número de caracteres' do
      98789298790.formata_documento.should eql('987.892.987-90')
      '98789298790'.formata_documento.should eql('987.892.987-90')
      '987.892.987-90'.formata_documento.should eql('987.892.987-90')
      85253100.formata_documento.should eql('85253-100')
      '85253100'.formata_documento.should eql('85253-100')
      '85253-100'.formata_documento.should eql('85253-100')
      88394510000103.formata_documento.should eql('88.394.510/0001-03')
      '88394510000103'.formata_documento.should eql('88.394.510/0001-03')
      '88.394.510/0001-03'.formata_documento.should eql('88.394.510/0001-03')
      '8839'.formata_documento.should eql('8839')
      '8839451000010388394510000103'.formata_documento.should eql('8839451000010388394510000103')
    end

    it 'Monta linha digitável' do
      '00192376900000135000000001238798777770016818'.linha_digitavel.should eql('00190.00009 01238.798779 77700.168188 2 37690000013500')
      '00192376900000135000000001238798777770016818'.linha_digitavel.should be_a_kind_of(String)
      lambda { ''.linha_digitavel }.should raise_error(ArgumentError)
      lambda { '00193373700'.linha_digitavel }.should raise_error(ArgumentError)
      lambda { '0019337370000193373700'.linha_digitavel }.should raise_error(ArgumentError)
      lambda { '00b193373700bb00193373700'.linha_digitavel }.should raise_error(ArgumentError)
    end
  end

  describe Calculo do
    it 'Calcula módulo 10' do
      lambda { ''.modulo10 }.should raise_error(ArgumentError)
      lambda { ' '.modulo10 }.should raise_error(ArgumentError)
      0.modulo10.should eql(0)
      '0'.modulo10.should eql(0)
      '001905009'.modulo10.should eql(5)
      '4014481606'.modulo10.should eql(9)
      '0680935031'.modulo10.should eql(4)
      '29004590'.modulo10.should eql(5)
      '341911012'.modulo10.should eql(1)
      '3456788005'.modulo10.should eql(8)
      '7123457000'.modulo10.should eql(1)
      '00571234511012345678'.modulo10.should eql(8)
      '001905009'.modulo10.should be_a_kind_of(Fixnum)
      1905009.modulo10.should eql(5)
      4014481606.modulo10.should eql(9)
      680935031.modulo10.should eql(4)
      29004590.modulo10.should eql(5)
      1905009.modulo10.should be_a_kind_of(Fixnum)
    end

    it 'Calcula módulo 10 para o banespa' do
      '4007469108'.modulo_10_banespa.should eql(1)
      4007469108.modulo_10_banespa.should eql(1)
      '1237469108'.modulo_10_banespa.should eql(3)
      1237469108.modulo_10_banespa.should eql(3)
    end

    it 'Multiplicador' do
      '85068014982'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(255)
      '05009401448'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(164)
      '12387987777700168'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(460)
      '34230'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(55)
      '258281'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(118)
      '5444'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should be_a_kind_of(Fixnum)
      '000000005444'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should be_a_kind_of(Fixnum)
      85068014982.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(255)
      5009401448.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(164)
      5444.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(61)
      1129004590.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should eql(162)
      5444.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]).should be_a_kind_of(Fixnum)
      lambda { '2582fd81'.multiplicador([2, 3, 4, 5, 6, 7, 8, 9]) }.should raise_error(ArgumentError)
    end

    it 'Calcula módulo 11 de 9 para 2' do
      '85068014982'.modulo11_9to2.should eql(9)
      '05009401448'.modulo11_9to2.should eql(1)
      '12387987777700168'.modulo11_9to2.should eql(2)
      '4042'.modulo11_9to2.should eql(8)
      '61900'.modulo11_9to2.should eql(0)
      '0719'.modulo11_9to2.should eql(6)
      '000000005444'.modulo11_9to2.should eql(5)
      '5444'.modulo11_9to2.should eql(5)
      '01129004590'.modulo11_9to2.should eql(3)
      '15735'.modulo11_9to2.should eql(10)
      '777700168'.modulo11_9to2.should eql(0)
      '77700168'.modulo11_9to2.should eql(3)
      '00015448'.modulo11_9to2.should eql(2)
      '15448'.modulo11_9to2.should eql(2)
      '12345678'.modulo11_9to2.should eql(9)
      '34230'.modulo11_9to2.should eql(0)
      '258281'.modulo11_9to2.should eql(3)
      '5444'.modulo11_9to2.should be_a_kind_of(Fixnum)
      '000000005444'.modulo11_9to2.should be_a_kind_of(Fixnum)
      85068014982.modulo11_9to2.should eql(9)
      5009401448.modulo11_9to2.should eql(1)
      12387987777700168.modulo11_9to2.should eql(2)
      4042.modulo11_9to2.should eql(8)
      61900.modulo11_9to2.should eql(0)
      719.modulo11_9to2.should eql(6)
      5444.modulo11_9to2.should eql(5)
      1129004590.modulo11_9to2.should eql(3)
      5444.modulo11_9to2.should be_a_kind_of(Fixnum)
      lambda { '2582fd81'.modulo11_9to2 }.should raise_error(ArgumentError)
    end

    it 'Calcula módulo 11 de 9 para 2, trocando resto 10 por X' do
      '85068014982'.modulo11_9to2_10_como_x.should eql(9)
      '05009401448'.modulo11_9to2_10_como_x.should eql(1)
      '12387987777700168'.modulo11_9to2_10_como_x.should eql(2)
      '4042'.modulo11_9to2_10_como_x.should eql(8)
      '61900'.modulo11_9to2_10_como_x.should eql(0)
      '0719'.modulo11_9to2_10_como_x.should eql(6)
      '000000005444'.modulo11_9to2_10_como_x.should eql(5)
      '5444'.modulo11_9to2_10_como_x.should eql(5)
      '01129004590'.modulo11_9to2_10_como_x.should eql(3)
      '15735'.modulo11_9to2_10_como_x.should eql('X')
      '15735'.modulo11_9to2_10_como_x.should be_a_kind_of(String)
      '5444'.modulo11_9to2_10_como_x.should be_a_kind_of(Fixnum)
      '000000005444'.modulo11_9to2_10_como_x.should be_a_kind_of(Fixnum)
      lambda { '2582fd81'.modulo11_9to2_10_como_x }.should raise_error(ArgumentError)
    end

    it 'Calcula módulo 11 de 2 para 9' do
      '0019373700000001000500940144816060680935031'.modulo11_2to9.should eql(3)
      '0019373700000001000500940144816060680935031'.modulo11_2to9.should be_a_kind_of(Fixnum)
      '3419166700000123451101234567880057123457000'.modulo11_2to9.should eql(6)
      19373700000001000500940144816060680935031.modulo11_2to9.should eql(3)
      19373700000001000500940144816060680935031.modulo11_2to9.should be_a_kind_of(Fixnum)
      lambda { '2582fd81'.modulo11_2to9 }.should raise_error(ArgumentError)
    end

    it 'Calcula a soma dos digitos de um número com mais de 1 algarismo' do
      111.soma_digitos.should eql(3)
      8.soma_digitos.should eql(8)
      '111'.soma_digitos.should eql(3)
      '8'.soma_digitos.should eql(8)
      0.soma_digitos.should eql(0)
      111.soma_digitos.should be_a_kind_of(Fixnum)
      '111'.soma_digitos.should be_a_kind_of(Fixnum)
    end
  end

  describe Limpeza do
    it 'Formata Float em String' do
      1234.03.limpa_valor_moeda.should == '123403'
      1234.3.limpa_valor_moeda.should == '123430'
    end
  end

  describe CalculoData do
    it 'Calcula o fator de vencimento' do
      (Date.parse '2008-02-01').fator_vencimento.should == '3769'
      (Date.parse '2008-02-02').fator_vencimento.should == '3770'
      (Date.parse '2008-02-06').fator_vencimento.should == '3774'
    end

    it 'Formata a data no padrão visual brasileiro' do
      (Date.parse '2008-02-01').to_s_br.should == '01/02/2008'
      (Date.parse '2008-02-02').to_s_br.should == '02/02/2008'
      (Date.parse '2008-02-06').to_s_br.should == '06/02/2008'
    end

    it 'Calcula data juliana' do
      (Date.parse '2009-02-11').to_juliano.should eql('0429')
      (Date.parse '2008-02-11').to_juliano.should eql('0428')
      (Date.parse '2009-04-08').to_juliano.should eql('0989')
      # Ano 2008 eh bisexto
      (Date.parse '2008-04-08').to_juliano.should eql('0998')
    end
  end

end