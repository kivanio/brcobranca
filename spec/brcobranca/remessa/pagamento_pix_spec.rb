# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::PagamentoPix do
  let(:pagamento) do
    subject.class.new(
      valor: 199.9,
      data_vencimento: Date.parse('2015-06-25'),
      nosso_numero: 123,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP',
      chave_pix: '12345678901',
      tipo_chave_pix: 'cpf',
      valor_maximo_pix: 199.9,
      valor_minimo_pix: 199.9
    )
  end

  context 'validacoes' do
    it 'deve ser invalido se nao possuir chave pix' do
      pagamento.chave_pix = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix não pode estar em branco.')
    end

    it 'deve ser invalido se nao possuir tipo de chave pix' do
      pagamento.tipo_chave_pix = nil
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Tipo chave pix não pode estar em branco.')
    end

    it 'deve ser invalido se tipo de chave pix nao for um dos aceitos' do
      pagamento.tipo_chave_pix = 'invalido'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages.join(' ')).to include('Tipo chave pix precisa ser um dos seguintes: ')
    end

    it 'deve ser invalido se tipo de chave cpf e chave pix nao tiver 11 digitos' do
      pagamento.tipo_chave_pix = 'cpf'
      pagamento.chave_pix = '123'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix deve ter 11 dígitos.')
    end

    it 'deve ser invalido se tipo de chave cnpj e chave pix nao tiver 14 digitos' do
      pagamento.tipo_chave_pix = 'cnpj'
      pagamento.chave_pix = '123'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix deve ter 14 caracteres.')
    end

    it 'deve ser invalido se tipo de chave email e chave pix nao for um email' do
      pagamento.tipo_chave_pix = 'email'
      pagamento.chave_pix = '123'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix não é válido.')
    end

    it 'deve ser invalido se tipo de chave telefone e chave pix nao for um telefone' do
      pagamento.tipo_chave_pix = 'telefone'
      pagamento.chave_pix = '984324896'
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix deve estar no formato +55DDNNNNNNNNN.')
    end

    it 'deve ser invalido se tipo de chave chave aleatoria e chave pix tiver mais de 77 caracteres' do
      pagamento.tipo_chave_pix = 'chave_aleatoria'
      pagamento.chave_pix = 'a' * 78
      expect(pagamento.invalid?).to be true
      expect(pagamento.errors.full_messages).to include('Chave pix deve ter entre 1 e 77 caracteres.')
    end
  end

  context 'formatacoes dos valores' do
    it 'formata valor maximo pix' do
      expect(pagamento.formata_valor_maximo_pix).to eq '0000000019990'
    end

    it 'formata valor minimo pix' do
      expect(pagamento.formata_valor_minimo_pix).to eq '0000000019990'
    end

    it 'formata percentual maximo pix' do
      expect(pagamento.formata_percentual_maximo_pix).to eq '10000'
    end

    it 'formata percentual minimo pix' do
      expect(pagamento.formata_percentual_minimo_pix).to eq '10000'
    end
  end
end
