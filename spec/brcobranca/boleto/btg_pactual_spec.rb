# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::BtgPactual do
  # Dados da mascara de boleto do kit de homologacao (docs/BtgPactual).
  let(:valid_attributes) do
    {
      valor: 200.00,
      data_documento: Date.parse('2021-11-23'),
      data_vencimento: Date.parse('2021-12-11'),
      cedente: 'NOME DO BENEFICIARIO',
      documento_cedente: '12345678000195',
      sacado: 'NOME PAGADOR',
      sacado_documento: '12345678900',
      agencia: '50',
      conta_corrente: '388685',
      carteira: '1',
      nosso_numero: '6380'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('208')
    expect(boleto_novo.banco_dv).to eql('1')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.carteira).to eql('01')
  end

  it 'Normaliza o tamanho dos campos' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.agencia).to eql('0050')
    expect(boleto_novo.conta_corrente).to eql('0388685')
    expect(boleto_novo.carteira).to eql('01')
    expect(boleto_novo.nosso_numero).to eql('00000006380')
  end

  it 'Montar código de barras e linha digitável conforme a máscara do BTG' do
    boleto_novo = described_class.new(valid_attributes)

    expect(boleto_novo.codigo_barras_segunda_parte).to eql('0050010000000638003886850')
    expect(boleto_novo.codigo_barras).to eql('20895883100000200000050010000000638003886850')
    expect(boleto_novo.codigo_barras.linha_digitavel).to eql('20890.05009 10000.000637 80038.868503 5 88310000020000')
  end

  it 'Não permitir gerar boleto com atributos inválidos' do
    boleto_novo = described_class.new(valid_attributes.merge(nosso_numero: '123456789012'))
    expect { boleto_novo.codigo_barras }.to raise_error(Brcobranca::BoletoInvalido)
    expect(boleto_novo.errors.full_messages).to include('Nosso numero deve ser menor ou igual a 11 dígitos.')
  end

  describe 'dígito verificador do nosso número (seção 4.4.4 do manual)' do
    let(:boleto_novo) { described_class.new(valid_attributes) }

    it 'calcula o exemplo do manual' do
      boleto_novo.nosso_numero = '87319177389'
      expect(boleto_novo.nosso_numero_dv).to be(3)
    end

    it 'calcula o exemplo da calculadora do kit' do
      boleto_novo.nosso_numero = '1288'
      expect(boleto_novo.nosso_numero_dv).to be(6)
    end

    it 'usa P quando o resto é 1' do
      boleto_novo.carteira = '06'
      boleto_novo.nosso_numero = '525'
      expect(boleto_novo.nosso_numero_dv).to eql('P')
    end

    it 'usa 0 quando o resto é 0' do
      boleto_novo.carteira = '19'
      boleto_novo.nosso_numero = '6'
      expect(boleto_novo.nosso_numero_dv).to be(0)
    end
  end

  it 'Montar nosso_numero_boleto no formato da máscara' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('001/6380-4')
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(valid_attributes)
    expect(boleto_novo.agencia_conta_boleto).to eql('0050 / 0388685')
  end

  describe 'Busca logotipo do banco' do
    it_behaves_like 'busca_logotipo'
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    boleto_novo = described_class.new(valid_attributes)
    assinaturas = {
      'pdf' => ['%PDF'.b],
      'jpg' => ["\xFF\xD8\xFF".b],
      'tif' => ["II*\x00".b, "MM\x00*".b],
      'png' => ["\x89PNG\r\n\x1A\n".b]
    }

    assinaturas.each do |formato, inicios|
      conteudo = boleto_novo.send(:"to_#{formato}")
      expect(conteudo).to be_a(String)
      expect(inicios).to include(conteudo.b[0, inicios.first.size]), "#{formato} sem a assinatura esperada"
    end
  end
end
