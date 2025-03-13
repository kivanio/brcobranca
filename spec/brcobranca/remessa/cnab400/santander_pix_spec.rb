# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::SantanderPix do
  let(:pagamento) do
    Brcobranca::Remessa::PagamentoPix.new(
      valor: 199.9,
      data_vencimento: Date.current,
      codigo_multa: '4',
      percentual_multa: '2.00',
      valor_mora: '8.00',
      cod_primeira_instrucao: '06',
      dias_protesto: '6',
      nosso_numero: 123,
      documento: 6969,
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'SP',
      tipo_chave_pix: 'cpf',
      chave_pix: '12345678910',
      tipo_pagamento_pix: '00',
      quantidade_pagamentos_pix: 1,
      tipo_valor_pix: '2', # 1 - percentual, 2 - valor
      valor_maximo_pix: 199.9,
      percentual_maximo_pix: 100.0,
      valor_minimo_pix: 199.9,
      percentual_minimo_pix: 100.0,
      txid_pix: nil
    )
  end

  let(:params) do
    {
      codigo_transmissao: '17777751042700080112',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      agencia: '8888',
      conta_corrente: '000002997',
      digito_conta: '8',
      pagamentos: [pagamento]
    }
  end

  let(:santander) { subject.class.new(params) }

  context 'monta remessa' do
    it_behaves_like 'cnab400 PIX'

    context 'detalhe pix' do
      it 'informacoes devem estar posicionadas corretamente no detalhe' do
        detalhe = santander.monta_detalhe_pix pagamento, 1
        detalhe = "X#{detalhe}" # Adiciona um caractere para contar a partir do 1

        expect(detalhe[1..1]).to eq '8'                               # Código do Registro
        expect(detalhe[2..3]).to eq '00'                              # Tipo de Pagamento
        expect(detalhe[4..5]).to eq '01'                              # Quantidade de Pagamentos possíveis
        expect(detalhe[6..6]).to eq '2'                               # Tipo do Valor Informado
        expect(detalhe[7..19]).to eq '0000000019990'                  # Valor Máximo
        expect(detalhe[20..24]).to eq '10000'                         # Percentual Máximo
        expect(detalhe[25..37]).to eq '0000000019990'                 # Valor Mínimo
        expect(detalhe[38..42]).to eq '10000'                         # Percentual Mínimo
        expect(detalhe[43..43]).to eq '1'                             # Tipo de Chave DICT
        expect(detalhe[44..120]).to eq '12345678910'.ljust(77, ' ')   # Código Chave DICT
        expect(detalhe[121..155]).to eq ''.ljust(35, ' ')             # Código de Identificação do Qr Code
        expect(detalhe[156..394]).to eq ''.ljust(239, ' ')            # Reservado (uso banco)
        expect(detalhe[395..400]).to eq '000001'                      # numero do registro no arquivo
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }

      after { Timecop.return }

      it { expect(santander.gera_arquivo).to eq(read_remessa('remessa-santander-cnab400-pix.rem', santander.gera_arquivo)) }
    end
  end
end
