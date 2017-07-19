# -*- encoding: utf-8 -*-

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Pagamento do
  let(:pagamento) do
    subject.class.new(valor: 199.9,
                      data_vencimento: Date.parse('2015-06-25'),
                      nosso_numero: 123,
                      documento_sacado: '12345678901',
                      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                      endereco_sacado: 'RUA RIO GRANDE DO SUL São paulo Minas caçapa da silva junior',
                      bairro_sacado: 'São josé dos quatro apostolos magros',
                      cep_sacado: '12345678',
                      cidade_sacado: 'Santa rita de cássia maria da silva',
                      uf_sacado: 'SP')
  end

  context 'validacoes' do
    context '@juros' do
      it "codigo mora pode ser nulo" do
        pagamento.cod_juros_mora = nil
        expect(pagamento.valid?).to be true
      end

      it "codigo mora deve ser 1, 2 ou 3" do
        pagamento.cod_juros_mora = '0'
        expect(pagamento.valid?).to be false

        pagamento.cod_juros_mora = '1'
        expect(pagamento.valid?).to be true

        pagamento.cod_juros_mora = '2'
        expect(pagamento.valid?).to be true

        pagamento.cod_juros_mora = '3'
        expect(pagamento.valid?).to be true

      end

      it "codigo de mora nao pode ter um valor fora da lista" do
        pagamento.cod_juros_mora = '4'
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:cod_juros_mora]).to eq ["4 não é um valor válido"]

        pagamento.cod_juros_mora = 3
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:cod_juros_mora]).to eq ["3 não é um valor válido"]
      end

      it "a data de juros pode ser nula" do
        pagamento.data_juros_mora = nil
        expect(pagamento.valid?).to be true
      end

      it "a data de juros nao pode ser menor que a data de vencimento" do
        pagamento.data_juros_mora = Date.new 2017, 1, 1
        pagamento.data_vencimento = Date.new 2017, 1, 2
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:data_juros_mora]).to eq ["não pode ser menor que data de vencimento"]
      end

      it "codigo mora pode ser nulo" do
        pagamento.codigo_multa = nil
        expect(pagamento.valid?).to be true
      end

      it "codigo da multa deve ser 1, 2" do
        pagamento.codigo_multa = '0'
        expect(pagamento.valid?).to be false

        pagamento.codigo_multa = '1'
        expect(pagamento.valid?).to be true

        pagamento.codigo_multa = '2'
        expect(pagamento.valid?).to be true

        pagamento.codigo_multa = '3'
        expect(pagamento.valid?).to be false

      end

      it "codigo da multa nao pode ter um valor fora da lista" do
        pagamento.codigo_multa = '3'
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:codigo_multa]).to eq ["3 não é um valor válido"]

        pagamento.codigo_multa = 2
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:codigo_multa]).to eq ["2 não é um valor válido"]
      end

      it "a data da multa pode ser nula" do
        pagamento.data_multa = nil
        expect(pagamento.valid?).to be true
      end

      it "a data da multa nao pode ser menor que a data de vencimento" do
        pagamento.data_multa = Date.new 2017, 1, 1
        pagamento.data_vencimento = Date.new 2017, 1, 2
        expect(pagamento.valid?).to be false
        expect(pagamento.errors[:data_multa]).to eq ["não pode ser menor que data de vencimento"]
      end
    end
  end

  context 'formatacoes dos valores' do
    context '@juros' do
      it 'formata com dados de mora nulos' do
        pagamento.cod_juros_mora = nil
        pagamento.valor_mora = 0.0
        pagamento.data_juros_mora = nil
        expect(pagamento.formata_mora).to eq '000000000000000000000000'
      end

      it 'formata com cod de mora invalido' do
        pagamento.cod_juros_mora = '4'
        pagamento.valor_mora = 156.25
        pagamento.data_juros_mora = nil
        expect(pagamento.formata_mora).to eq '000000000000000000015625'
      end

      it 'formata com data mora em branco' do
        pagamento.cod_juros_mora = '1'
        pagamento.valor_mora = 156.25
        pagamento.data_juros_mora = nil
        expect(pagamento.formata_mora).to eq '100000000000000000015625'
      end

      it 'formata com data mora' do
        pagamento.cod_juros_mora = '1'
        pagamento.valor_mora = 156.25
        pagamento.data_juros_mora = Date.new(2017,6,1)
        expect(pagamento.formata_mora).to eq '101062017000000000015625'
      end
    end
  end
end
