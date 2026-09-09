# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::PessoaLookup::Resolver do
  subject(:resolver) { described_class.new(fonte) }

  let(:fonte) { instance_double(Brcobranca::PessoaLookup::CpfCnpjComBrLookup) }

  let(:dados_cpf) do
    {
      documento: '12345678909', nome: 'Fulano de Tal', logradouro: 'Rua A',
      numero: '100', complemento: 'Apto 03', bairro: 'Centro',
      cep: '99999123', cidade: 'Sao Paulo', uf: 'SP'
    }
  end

  let(:dados_cnpj) do
    {
      documento: '11222333000181', nome: 'TOKEN TEST LTDA', logradouro: 'Rua A',
      numero: '1', complemento: 'Sala 1', bairro: 'Centro',
      cep: '00000111', cidade: 'Montes Claros', uf: 'MG'
    }
  end

  describe '#por_cpf' do
    before { allow(fonte).to receive(:consultar_cpf).with('12345678909').and_return(dados_cpf) }

    it 'no formato :cnab devolve campos granulares' do
      atributos = resolver.por_cpf('12345678909', formato: :cnab)

      expect(atributos[:documento_sacado]).to eq('12345678909')
      expect(atributos[:nome_sacado]).to eq('Fulano de Tal')
      expect(atributos[:endereco_sacado]).to eq('Rua A, 100, Apto 03')
      expect(atributos[:bairro_sacado]).to eq('Centro')
      expect(atributos[:cep_sacado]).to eq('99999123')
      expect(atributos[:cidade_sacado]).to eq('Sao Paulo')
      expect(atributos[:uf_sacado]).to eq('SP')
    end

    it 'no formato :boleto achata o endereço numa única string' do
      atributos = resolver.por_cpf('12345678909', formato: :boleto)

      expect(atributos[:sacado]).to eq('Fulano de Tal')
      expect(atributos[:sacado_documento]).to eq('12345678909')
      expect(atributos[:sacado_endereco]).to eq('Rua A, 100, Apto 03, Centro, 99999123, Sao Paulo, SP')
    end
  end

  describe '#por_cnpj' do
    before { allow(fonte).to receive(:consultar_cnpj).with('11222333000181').and_return(dados_cnpj) }

    it 'no formato :cnab devolve campos granulares' do
      atributos = resolver.por_cnpj('11222333000181', formato: :cnab)

      expect(atributos[:documento_sacado]).to eq('11222333000181')
      expect(atributos[:nome_sacado]).to eq('TOKEN TEST LTDA')
      expect(atributos[:cidade_sacado]).to eq('Montes Claros')
    end
  end

  describe '#por_documento' do
    it 'detecta CPF por 11 dígitos' do
      allow(fonte).to receive(:consultar_cpf).and_return(dados_cpf)

      resolver.por_documento('123.456.789-09')

      expect(fonte).to have_received(:consultar_cpf)
    end

    it 'detecta CNPJ por 14 caracteres' do
      allow(fonte).to receive(:consultar_cnpj).and_return(dados_cnpj)

      resolver.por_documento('11.222.333/0001-81')

      expect(fonte).to have_received(:consultar_cnpj)
    end

    it 'levanta DocumentoInvalido para tamanho inesperado' do
      expect { resolver.por_documento('123') }
        .to raise_error(Brcobranca::PessoaLookup::DocumentoInvalido)
    end

    it 'não trata como CPF um documento de 11 posições com letras' do
      allow(fonte).to receive(:consultar_cpf)

      expect { resolver.por_documento('ABCDEFGHIJK') }
        .to raise_error(Brcobranca::PessoaLookup::DocumentoInvalido)
      expect(fonte).not_to have_received(:consultar_cpf)
    end
  end

  describe 'CNPJ alfanumérico' do
    let(:dados_alfa) { dados_cnpj.merge(documento: '12ABC34501DE35') }

    before { allow(fonte).to receive(:consultar_cnpj).and_return(dados_alfa) }

    it 'rejeita no formato :cnab, que só aceita posições numéricas' do
      expect { resolver.por_cnpj('12ABC34501DE35', formato: :cnab) }
        .to raise_error(Brcobranca::PessoaLookup::DocumentoInvalido)
    end

    it 'aceita no formato :boleto' do
      atributos = resolver.por_cnpj('12ABC34501DE35', formato: :boleto)

      expect(atributos[:sacado_documento]).to eq('12ABC34501DE35')
    end
  end

  describe 'formato inválido' do
    it 'levanta ArgumentError' do
      allow(fonte).to receive(:consultar_cpf).and_return(dados_cpf)

      expect { resolver.por_cpf('12345678909', formato: :xml) }
        .to raise_error(ArgumentError)
    end
  end

  describe 'integração com Remessa::Pagamento' do
    before { allow(fonte).to receive(:consultar_cpf).and_return(dados_cpf) }

    it 'produz atributos válidos para um Pagamento' do
      atributos = resolver.por_cpf('12345678909', formato: :cnab)
      pagamento = Brcobranca::Remessa::Pagamento.new(
        atributos.merge(nosso_numero: '1', data_vencimento: Date.current, valor: 100.0)
      )

      expect(pagamento).to be_valid
    end
  end
end
