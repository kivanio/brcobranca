# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Base do
  let(:arquivo) { File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', nome_arquivo) }

  describe '#load_lines' do
    it 'retorna nil se o arquivo é nil' do
      expect(described_class.load_lines(nil)).to be_nil
    end

    context 'Banco de Brasilia' do
      subject { Brcobranca::Retorno::Cnab400::BancoBrasilia }

      let(:nome_arquivo) { 'CNAB400BANCOBRASILIA.RET' }

      it 'lê o arquivo pela classe do Banco de Brasilia' do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        described_class.load_lines(arquivo)
      end
    end

    context 'Bradesco' do
      subject { Brcobranca::Retorno::Cnab400::Bradesco }

      let(:nome_arquivo) { 'CNAB400BRADESCO.RET' }

      it 'lê o arquivo pela classe do Bradesco' do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        described_class.load_lines(arquivo)
      end
    end

    context 'Itaú' do
      subject { Brcobranca::Retorno::Cnab400::Itau }

      let(:nome_arquivo) { 'CNAB400ITAU.RET' }

      it 'lê o arquivo pela classe do Itaú' do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        described_class.load_lines(arquivo)
      end
    end

    context 'Santander' do
      subject { Brcobranca::Retorno::Cnab400::Santander }

      let(:nome_arquivo) { 'CNAB400SANTANDER.RET' }

      it 'lê o arquivo pela classe do Santander' do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        described_class.load_lines(arquivo)
      end
    end
  end
end
