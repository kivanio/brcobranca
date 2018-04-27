# -*- encoding: utf-8 -*-
#

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Banrisul do #:nodoc:[all]
  let(:valid_attributes) do
    {
      data_vencimento: Date.parse('2015-06-26'),
      valor: 1278.90,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '1102',
      conta_corrente: '1454204',
      nosso_numero: '22832563',
      convenio: '9000150',
      digito_convenio: '46'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new

    expect(boleto_novo.banco).to eql('041')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_vencimento).to eql(Date.current)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(0.0)
    expect(boleto_novo.valor_documento).to eq(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.carteira).to eql('2')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.banco).to eql('041')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_processamento).to eql(Date.current)
    expect(boleto_novo.data_vencimento).to eql(Date.parse('2015-06-26'))
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to be(1)
    expect(boleto_novo.valor).to eq(1278.9)
    expect(boleto_novo.valor_documento).to eq(1278.9)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('01454204')
    expect(boleto_novo.agencia).to eql('1102')
    expect(boleto_novo.nosso_numero).to eql('22832563')
    expect(boleto_novo.nosso_numero_boleto).to eql('22832563-51')
    expect(boleto_novo.carteira).to eql('2')
    expect(boleto_novo.codigo_barras).to eql('04191647100001278902111029000150228325634059')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('04192.11107 29000.150226 83256.340593 1 64710000127890')
  end

  it 'Não permitir gerar boleto com atributos inválido' do
    boleto_novo = described_class.new
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.count).to be(5)
  end

  it 'Montar nosso_numero_boleto' do
    valid_attributes[:nosso_numero] = '00009274'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00009274-22')

    valid_attributes[:nosso_numero] = '00009194'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('00009194-38')

    valid_attributes[:nosso_numero] = '22832563'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('22832563-51')
  end

  it 'Montar codio de barras' do
    valid_attributes[:nosso_numero] = '22832563'
    valid_attributes[:data_vencimento] = Date.parse('2000-07-04')
    valid_attributes[:valor] = 550.0
    valid_attributes[:agencia] = '1102'
    valid_attributes[:conta_corrente] = '00099999'
    valid_attributes[:convenio] = '9000150'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('04198100100000550002111029000150228325634059')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('04192.11107 29000.150226 83256.340593 8 10010000055000')

    valid_attributes[:nosso_numero] = '00009274'
    valid_attributes[:data_vencimento] = Date.parse('2000-07-04')
    valid_attributes[:valor] = 550.00
    valid_attributes[:agencia] = '1102'
    valid_attributes[:conta_corrente] = '00099999'
    valid_attributes[:convenio] = '9000150'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('04194100100000550002111029000150000092744028')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('04192.11107 29000.150002 00927.440289 4 10010000055000')

    valid_attributes[:nosso_numero] = '00009194'
    valid_attributes[:data_vencimento] = Date.parse('2000-07-04')
    valid_attributes[:valor] = 550.00
    valid_attributes[:agencia] = '1102'
    valid_attributes[:conta_corrente] = '00099999'
    valid_attributes[:convenio] = '9000150'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('04198100100000550002111029000150000091944023')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('04192.11107 29000.150002 00919.440230 8 10010000055000')

    valid_attributes[:nosso_numero] = '03408099'
    valid_attributes[:data_vencimento] = Date.parse('2017-01-12')
    valid_attributes[:valor] = 1216.00
    valid_attributes[:agencia] = '0016'
    valid_attributes[:conta_corrente] = '00099999'
    valid_attributes[:convenio] = '0164640'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('04192703700001216002100160164640034080994027')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('04192.10018 60164.640033 40809.940279 2 70370000121600')

  end

  it 'Montar agencia_conta_boleto' do
    valid_attributes[:convenio] = '9000150'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.agencia_conta_boleto).to eql('1102 / 900015.0.46')

    valid_attributes[:convenio] = '8505610'
    valid_attributes[:digito_convenio] = '99'
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.agencia_conta_boleto).to eql('1102 / 850561.0.99')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:nosso_numero] = '240'

    boleto_novo = described_class.new(valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close

      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    valid_attributes[:valor] = 135.00
    valid_attributes[:data_vencimento] = Date.parse('2008-02-03')
    valid_attributes[:nosso_numero] = '240'

    boleto_novo = described_class.new(valid_attributes)

    %w(pdf jpg tif png).each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new(['foobar.', format])
      tmp_file.puts file_body
      tmp_file.close

      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
