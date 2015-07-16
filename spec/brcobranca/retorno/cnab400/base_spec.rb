# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::Cnab400::Base do
  let(:arquivo) { File.join(File.dirname(__FILE__), '..', '..', '..', 'arquivos', nome_arquivo) }

  describe "#load_lines" do

    context "Bradesco" do
      let(:nome_arquivo) { "CNAB400BRADESCO.RET" }

      subject { Brcobranca::Retorno::Cnab400::Bradesco }

      it "lê o arquivo pela classe do Bradesco" do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        Brcobranca::Retorno::Cnab400::Base.load_lines(arquivo)
      end
    end

    context "Itaú" do
      let(:nome_arquivo) { "CNAB400ITAU.RET" }

      subject { Brcobranca::Retorno::Cnab400::Itau }

      it "lê o arquivo pela classe do Itaú" do
        expect(subject).to receive(:load_lines).with(arquivo, {})
        Brcobranca::Retorno::Cnab400::Base.load_lines(arquivo)
      end
    end
  end
end
