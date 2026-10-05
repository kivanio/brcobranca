# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::Template::Prawn do
  let(:attributes) do
    {
      valor: 135.0,
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      sacado_endereco: 'Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      nosso_numero: '777700168',
      instrucao1: 'Primeira instrução',
      instrucao7: 'Sétima instrução'
    }
  end

  let(:boletos) do
    [
      Brcobranca::Boleto::BancoBrasil.new(attributes),
      Brcobranca::Boleto::Bradesco.new(attributes),
      Brcobranca::Boleto::Itau.new(attributes.merge(convenio: '12345', nosso_numero: '12345678'))
    ]
  end

  let(:boleto) { boletos.first.extend(described_class) }

  # Os logotipos em PNG só são usados quando o gerador configurado é :prawn
  around do |example|
    gerador_original = Brcobranca.configuration.gerador
    Brcobranca.configuration.gerador = :prawn
    example.run
  ensure
    Brcobranca.configuration.gerador = gerador_original
  end

  describe '.lote' do
    it 'gera um PDF com uma página por boleto' do
      pdf = described_class.lote(boletos, formato: :pdf)

      expect(pdf).to start_with('%PDF')
      expect(described_class.lote(boletos, formato: :prawn).page_count).to eq(3)
    end

    it 'não guarda estado no receptor' do
      described_class.lote(boletos, formato: :pdf)

      expect(described_class.instance_variables).to be_empty
    end

    context 'com formato não suportado' do
      it 'levanta NotImplementedError' do
        expect { described_class.lote(boletos, formato: :gif) }.to raise_error(NotImplementedError)
      end
    end
  end

  describe 'métodos dinâmicos' do
    it 'gera o PDF com to_pdf' do
      expect(boleto.to_pdf).to start_with('%PDF')
    end

    it 'retorna o documento Prawn com to_prawn' do
      expect(boleto.to_prawn).to be_a(Prawn::Document)
    end

    it 'gera o PDF com to(:pdf)' do
      expect(boleto.to(:pdf)).to start_with('%PDF')
    end

    it 'não altera as opções recebidas' do
      opcoes = { formato: :pdf }
      boleto.to_pdf(opcoes)

      expect(opcoes).to eq(formato: :pdf)
    end

    it 'não responde a conversões implícitas' do
      expect(boleto).not_to respond_to(:to_ary)
      expect([[boleto]].flatten).to eq([boleto])
    end

    it 'não guarda o documento no boleto' do
      boleto.to_pdf

      expect(boleto.instance_variables).not_to include(:@doc, :@boleto)
    end
  end

  context 'com QR Code PIX' do
    it 'gera o PDF' do
      boleto.emv = '00020101021226870014br.gov.bcb.pix2565qrcodepix.bb.com.br/pix/v2/cobv/0000000000000000000000000000'

      expect(boleto.to_pdf).to start_with('%PDF')
    end
  end
end
