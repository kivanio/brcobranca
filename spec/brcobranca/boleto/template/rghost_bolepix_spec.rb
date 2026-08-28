# frozen_string_literal: true

require 'spec_helper'

# O template e escolhido em Boleto::Base no momento da carga da classe, a
# partir de Brcobranca.configuration.gerador, entao nao da para trocar o
# gerador no meio da suite. Esta classe aplica o RghostBolepix do mesmo jeito
# que a Base faria - o nome Itau e necessario porque Base#logotipo resolve o
# arquivo .eps pelo nome da classe.
module BolepixTeste
  class Itau < Brcobranca::Boleto::Itau
    extend Brcobranca::Boleto::Template::RghostBolepix
    include Brcobranca::Boleto::Template::RghostBolepix
  end
end

RSpec.describe Brcobranca::Boleto::Template::RghostBolepix do
  let(:atributos) do
    {
      agencia: '0810',
      conta_corrente: '53678',
      carteira: '175',
      nosso_numero: '12345678',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      sacado_endereco: 'Rua Guarani 1, Sao Paulo, SP',
      valor: 135.00,
      data_documento: Date.parse('2026/08/01'),
      data_vencimento: Date.parse('2026/08/28')
    }
  end

  let(:emv) do
    '00020101021226880014br.gov.bcb.pix2566qrcodepix.exemplo.com.br/cobv/12345' \
      '20400005303986540510.005802BR'
  end

  let(:boleto) { BolepixTeste::Itau.new(atributos) }

  it 'e o template escolhido pelo gerador :rghost_bolepix' do
    expect(Brcobranca::Boleto::Template::Base.define_template(:rghost_bolepix)).to eq([described_class])
  end

  it 'reaproveita o desenho do template Rghost' do
    expect(described_class.include?(Brcobranca::Boleto::Template::Rghost)).to be true
  end

  it 'gera um PDF valido' do
    expect(boleto.to_pdf[0..3]).to eq '%PDF'
  end

  it 'responde aos formatos dinamicos herdados do Rghost' do
    %w[pdf jpg png].each do |formato|
      expect(boleto.send(:"to_#{formato}")).not_to be_empty
    end
  end

  context 'com EMV informado' do
    let(:boleto) { BolepixTeste::Itau.new(atributos.merge(emv: emv)) }

    it 'desenha o QRCode do PIX' do
      expect(boleto.to_ps).to include('Pague com PIX')
    end

    it 'gera um arquivo maior que o boleto sem PIX' do
      expect(boleto.to_ps.bytesize).to be > BolepixTeste::Itau.new(atributos).to_ps.bytesize
    end
  end

  context 'sem EMV' do
    it 'nao desenha o QRCode do PIX' do
      expect(boleto.to_ps).not_to include('Pague com PIX')
    end
  end

  context 'com descontos e abatimentos' do
    let(:boleto) { BolepixTeste::Itau.new(atributos.merge(descontos_e_abatimentos: 12.34)) }

    it 'mostra o valor no boleto' do
      expect(boleto.to_ps).to include('12,34')
    end
  end

  context 'sem descontos e abatimentos' do
    it 'gera o boleto normalmente' do
      expect(boleto.descontos_e_abatimentos).to be_nil
      expect(boleto.to_pdf[0..3]).to eq '%PDF'
    end
  end

  context 'quando gera um lote' do
    it 'aplica o template em todos os boletos' do
      lote = BolepixTeste::Itau.lote([BolepixTeste::Itau.new(atributos.merge(emv: emv)),
                                      BolepixTeste::Itau.new(atributos.merge(emv: emv))],
                                     formato: :ps)

      expect(lote.scan('Pague com PIX').size).to eq 2
    end
  end
end
