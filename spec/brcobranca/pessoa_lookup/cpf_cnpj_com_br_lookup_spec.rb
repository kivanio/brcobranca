# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::PessoaLookup::CpfCnpjComBrLookup do
  subject(:fonte) { described_class.new(token: 'token_de_teste') }

  let(:corpo_cpf) do
    {
      status: 1,
      cpf: '000.000.000-00',
      nome: 'Test Token',
      endereco: 'Rua A',
      numero: '100 B',
      complemento: 'Apto 03',
      bairro: 'Centro',
      cep: '99999123',
      cidade: 'Sao Paulo',
      uf: 'SP'
    }.to_json
  end

  let(:corpo_cnpj) do
    {
      status: 1,
      cnpj: '11.222.333/0001-81',
      razao: 'TOKEN TEST LTDA',
      matrizEndereco: {
        cep: '00000111', tipo: 'Rua', logradouro: 'A', numero: '1',
        complemento: 'Sala 1', bairro: 'Centro', cidade: 'Montes Claros', uf: 'MG'
      }
    }.to_json
  end

  def resposta(classe, corpo)
    http = classe.new('1.1', classe == Net::HTTPOK ? '200' : '500', 'STATUS')
    allow(http).to receive(:body).and_return(corpo)
    http
  end

  describe '#initialize' do
    it 'exige um token' do
      expect { described_class.new(token: '') }.to raise_error(ArgumentError)
    end

    it 'usa os pacotes 3 e 5 por padrão' do
      expect(fonte.pacote_cpf).to eq(3)
      expect(fonte.pacote_cnpj).to eq(5)
    end
  end

  describe '#consultar_cpf' do
    before { allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, corpo_cpf)) }

    it 'normaliza os campos do CPF' do
      resultado = fonte.consultar_cpf('000.000.000-00')

      expect(resultado[:documento]).to eq('00000000000')
      expect(resultado[:nome]).to eq('Test Token')
      expect(resultado[:logradouro]).to eq('Rua A')
      expect(resultado[:numero]).to eq('100 B')
      expect(resultado[:cep]).to eq('99999123')
      expect(resultado[:cidade]).to eq('Sao Paulo')
      expect(resultado[:uf]).to eq('SP')
    end

    it 'monta a URL com token, pacote e documento sem máscara' do
      esperado = URI('https://api.cpfcnpj.com.br')
      allow(Net::HTTP).to receive(:start).with('api.cpfcnpj.com.br', esperado.port, hash_including(use_ssl: true))
                                         .and_return(resposta(Net::HTTPOK, corpo_cpf))

      fonte.consultar_cpf('000.000.000-00')

      expect(Net::HTTP).to have_received(:start)
    end
  end

  describe '#consultar_cnpj' do
    before { allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, corpo_cnpj)) }

    it 'normaliza os campos do CNPJ a partir de matrizEndereco' do
      resultado = fonte.consultar_cnpj('11.222.333/0001-81')

      expect(resultado[:documento]).to eq('11222333000181')
      expect(resultado[:nome]).to eq('TOKEN TEST LTDA')
      expect(resultado[:logradouro]).to eq('Rua A')
      expect(resultado[:bairro]).to eq('Centro')
      expect(resultado[:cep]).to eq('00000111')
      expect(resultado[:cidade]).to eq('Montes Claros')
      expect(resultado[:uf]).to eq('MG')
    end
  end

  describe 'tratamento de erros' do
    it 'levanta NaoEncontrado quando o status é 0' do
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, { status: 0 }.to_json))

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::NaoEncontrado)
    end

    it 'levanta Indisponivel em resposta HTTP de erro' do
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPInternalServerError, 'erro'))

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta Indisponivel com JSON ilegível' do
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, 'isto não é json'))

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta TempoEsgotado no timeout' do
      allow(Net::HTTP).to receive(:start).and_raise(Timeout::Error)

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::TempoEsgotado)
    end

    it 'levanta Indisponivel em falha de conexão' do
      allow(Net::HTTP).to receive(:start).and_raise(SocketError)

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta DocumentoInvalido para CPF com tamanho errado, sem consultar' do
      allow(Net::HTTP).to receive(:start)

      expect { fonte.consultar_cpf('123') }
        .to raise_error(Brcobranca::PessoaLookup::DocumentoInvalido)
      expect(Net::HTTP).not_to have_received(:start)
    end

    it 'levanta DocumentoInvalido para CNPJ com tamanho errado, sem consultar' do
      allow(Net::HTTP).to receive(:start)

      expect { fonte.consultar_cnpj('11.222.333/0001') }
        .to raise_error(Brcobranca::PessoaLookup::DocumentoInvalido)
      expect(Net::HTTP).not_to have_received(:start)
    end

    it 'levanta Indisponivel quando o JSON não é um objeto' do
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, [1, 2].to_json))

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta Indisponivel quando o status é 1 mas faltam campos' do
      parcial = { status: 1, cpf: '000.000.000-00', nome: 'Test Token' }.to_json
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, parcial))

      expect { fonte.consultar_cpf('00000000000') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta Indisponivel quando matrizEndereco não é um objeto, sem quebrar' do
      corpo = { status: 1, cnpj: '11.222.333/0001-81', razao: 'TOKEN TEST LTDA', matrizEndereco: [] }.to_json
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, corpo))

      expect { fonte.consultar_cnpj('11.222.333/0001-81') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end

    it 'levanta Indisponivel quando o CNPJ responde sem endereço' do
      corpo = { status: 1, cnpj: '11.222.333/0001-81', razao: 'TOKEN TEST LTDA' }.to_json
      allow(Net::HTTP).to receive(:start).and_return(resposta(Net::HTTPOK, corpo))

      expect { fonte.consultar_cnpj('11.222.333/0001-81') }
        .to raise_error(Brcobranca::PessoaLookup::Indisponivel)
    end
  end
end
