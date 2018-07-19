# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::Calculo do
  it 'Calcula módulo 10' do
    expect { ''.modulo10 }.to raise_error(ArgumentError)
    expect { ' '.modulo10 }.to raise_error(ArgumentError)
    expect(0.modulo10).to be(0)
    expect('0'.modulo10).to be(0)
    expect('001905009'.modulo10).to be(5)
    expect('4014481606'.modulo10).to be(9)
    expect('0680935031'.modulo10).to be(4)
    expect('29004590'.modulo10).to be(5)
    expect('341911012'.modulo10).to be(1)
    expect('3456788005'.modulo10).to be(8)
    expect('7123457000'.modulo10).to be(1)
    expect('00571234511012345678'.modulo10).to be(8)
    expect('001905009'.modulo10).to be_a_kind_of(Integer)
    expect(1_905_009.modulo10).to be(5)
    expect(4_014_481_606.modulo10).to be(9)
    expect(680_935_031.modulo10).to be(4)
    expect(29_004_590.modulo10).to be(5)
    expect(1_905_009.modulo10).to be_a_kind_of(Integer)
  end

  it 'Multiplicador' do
    expect('85068014982'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(255)
    expect('05009401448'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(164)
    expect('12387987777700168'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(460)
    expect('34230'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(55)
    expect('258281'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(118)
    expect('5444'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be_a_kind_of(Integer)
    expect('000000005444'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be_a_kind_of(Integer)
    expect(85_068_014_982.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(255)
    expect(5_009_401_448.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(164)
    expect(5444.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(61)
    expect(1_129_004_590.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be(162)
    expect(5444.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9])).to be_a_kind_of(Integer)
    expect { '2582fd81'.multiplicador(fatores: [2, 3, 4, 5, 6, 7, 8, 9]) }.to raise_error(ArgumentError)
    expect { 5444.multiplicador }.to raise_error(ArgumentError)
  end

  describe 'módulo 11 de 9 até 2' do
    def modulo_11_de_9_ate_2(numero)
      numero.modulo11
    end

    it 'Calcula o resultado' do
      expect(modulo_11_de_9_ate_2('85068014982')).to be(9)
      expect(modulo_11_de_9_ate_2('05009401448')).to be(1)
      expect(modulo_11_de_9_ate_2('12387987777700168')).to be(2)
      expect(modulo_11_de_9_ate_2('4042')).to be(8)
      expect(modulo_11_de_9_ate_2('61900')).to be(0)
      expect(modulo_11_de_9_ate_2('0719')).to be(6)
      expect(modulo_11_de_9_ate_2('000000005444')).to be(5)
      expect(modulo_11_de_9_ate_2('5444')).to be(5)
      expect(modulo_11_de_9_ate_2('01129004590')).to be(3)
      expect(modulo_11_de_9_ate_2('15735')).to be(10)
      expect(modulo_11_de_9_ate_2('777700168')).to be(0)
      expect(modulo_11_de_9_ate_2('77700168')).to be(3)
      expect(modulo_11_de_9_ate_2('00015448')).to be(2)
      expect(modulo_11_de_9_ate_2('15448')).to be(2)
      expect(modulo_11_de_9_ate_2('12345678')).to be(9)
      expect(modulo_11_de_9_ate_2('34230')).to be(0)
      expect(modulo_11_de_9_ate_2('258281')).to be(3)
      expect(modulo_11_de_9_ate_2(85_068_014_982)).to be(9)
      expect(modulo_11_de_9_ate_2(5_009_401_448)).to be(1)
      expect(modulo_11_de_9_ate_2(12_387_987_777_700_168)).to be(2)
      expect(modulo_11_de_9_ate_2(4042)).to be(8)
      expect(modulo_11_de_9_ate_2(61_900)).to be(0)
      expect(modulo_11_de_9_ate_2(719)).to be(6)
      expect(modulo_11_de_9_ate_2(5444)).to be(5)
      expect(modulo_11_de_9_ate_2(1_129_004_590)).to be(3)
    end

    it 'Retorna o tipo correto' do
      expect(modulo_11_de_9_ate_2(5444)).to be_a_kind_of(Integer)
      expect(modulo_11_de_9_ate_2('5444')).to be_a_kind_of(Integer)
      expect(modulo_11_de_9_ate_2('000000005444')).to be_a_kind_of(Integer)
    end
  end

  describe 'Módulo 11 de 9 até 2 trocando 10 por X' do
    def modulo_11_de_9_ate_2_map_10_X(numero)
      numero.modulo11(mapeamento: { 10 => 'X' })
    end

    it 'Calcula o resultado' do
      expect(modulo_11_de_9_ate_2_map_10_X('85068014982')).to be(9)
      expect(modulo_11_de_9_ate_2_map_10_X('05009401448')).to be(1)
      expect(modulo_11_de_9_ate_2_map_10_X('12387987777700168')).to be(2)
      expect(modulo_11_de_9_ate_2_map_10_X('4042')).to be(8)
      expect(modulo_11_de_9_ate_2_map_10_X('61900')).to be(0)
      expect(modulo_11_de_9_ate_2_map_10_X('0719')).to be(6)
      expect(modulo_11_de_9_ate_2_map_10_X('000000005444')).to be(5)
      expect(modulo_11_de_9_ate_2_map_10_X('5444')).to be(5)
      expect(modulo_11_de_9_ate_2_map_10_X('01129004590')).to be(3)
      expect(modulo_11_de_9_ate_2_map_10_X('15735')).to eql('X')
    end

    it 'Retorna o tipo correto' do
      expect(modulo_11_de_9_ate_2_map_10_X('15735')).to be_a_kind_of(String)
      expect(modulo_11_de_9_ate_2_map_10_X('5444')).to be_a_kind_of(Integer)
      expect(modulo_11_de_9_ate_2_map_10_X('000000005444')).to be_a_kind_of(Integer)
    end

    it { expect { modulo_11_de_9_ate_2_map_10_X '2582fd81' }.to raise_error(ArgumentError) }
  end

  describe 'Módulo 11 de 2 até 9' do
    def modulo_11_de_2_ate_9(numero)
      numero.modulo11(
        multiplicador: (2..9).to_a,
        mapeamento: { 0 => 1, 10 => 1, 11 => 1 }
      ) { |total| 11 - (total % 11) }
    end

    it 'Calcula o resultado' do
      expect(modulo_11_de_2_ate_9('0019373700000001000500940144816060680935031')).to be(3)
      expect(modulo_11_de_2_ate_9('3419166700000123451101234567880057123457000')).to be(6)
      expect(modulo_11_de_2_ate_9('7459588800000774303611264424020000000002674')).to be(4)
      expect(modulo_11_de_2_ate_9('7459588800000580253611264424020000000003131')).to be(1)
      expect(modulo_11_de_2_ate_9(19_373_700_000_001_000_500_940_144_816_060_680_935_031)).to be(3)
    end

    it 'Retorna o tipo correto' do
      expect(modulo_11_de_2_ate_9(19_373_700_000_001_000_500_940_144_816_060_680_935_031)).to be_a_kind_of(Integer)
      expect(modulo_11_de_2_ate_9('0019373700000001000500940144816060680935031')).to be_a_kind_of(Integer)
    end

    it { expect { modulo_11_de_2_ate_9 '2582fd81' }.to raise_error(ArgumentError) }
  end

  # Ex: Sicoob
  describe 'Módulo 11 com multiplicadores 3, 7, 9, 1, trocando 11 e 10 por 0' do
    def modulo_11_com_3_7_9_1_map_10_e_10_por_0(numero)
      numero.modulo11(
        multiplicador: [3, 7, 9, 1],
        mapeamento: { 10 => 0, 11 => 0 }
      ) { |t| 11 - (t % 11) }
    end

    it { expect(modulo_11_com_3_7_9_1_map_10_e_10_por_0('000100000000190000045')).to be(4) }
    it { expect(modulo_11_com_3_7_9_1_map_10_e_10_por_0('442300000520270100183')).to be(4) }
    it { expect(modulo_11_com_3_7_9_1_map_10_e_10_por_0('442300000520270100184')).to be(1) }
  end

  # Ex: Bradesco
  describe 'Módulo 11 de 2 até 7 trocando 10 por P e 11 por 0' do
    def modulo_11_de_2_ate_7_map_10_P_e_11_0(numero)
      numero.modulo11(
        multiplicador: [2, 3, 4, 5, 6, 7],
        mapeamento: { 10 => 'P', 11 => 0 }
      ) { |total| 11 - (total % 11) }
    end

    it 'Calcula o resultado' do
      expect(modulo_11_de_2_ate_7_map_10_P_e_11_0('19669')).to eql('P')
      expect(modulo_11_de_2_ate_7_map_10_P_e_11_0('19694')).to be(0)
    end
  end

  it 'Calcula a soma dos digitos de um número com mais de 1 algarismo' do
    expect(11.soma_digitos).to be(2)
    expect(8.soma_digitos).to be(8)
    expect('11'.soma_digitos).to be(2)
    expect('8'.soma_digitos).to be(8)
    expect(0.soma_digitos).to be(0)
    expect(11.soma_digitos).to be_a_kind_of(Integer)
    expect('11'.soma_digitos).to be_a_kind_of(Integer)
  end

  describe '#duplo_digito' do
    it { expect(111.duplo_digito).to eql('50') }
    it { expect(8.duplo_digito).to eql('33') }
    it { expect('111'.duplo_digito).to eql('50') }
    it { expect('8'.duplo_digito).to eql('33') }
    it { expect(0.duplo_digito).to eql('00') }
    it { expect(19_669.duplo_digito).to eql('28') }
    it { expect('00000032000272012924021'.duplo_digito).to eql('79') }
    it { expect('00000033000272012924021'.duplo_digito).to eql('65') }
    it { expect('9194'.duplo_digito).to eql('38') }
  end
end
