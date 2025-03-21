# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab444::Itau do
  let(:chave_nfe) { '12345678901234567890123456789012345678901234' }
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
                                       data_vencimento: Date.current,
                                       nosso_numero: 123,
                                       documento: 6969,
                                       documento_sacado: '12345678901',
                                       nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                                       endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
                                       bairro_sacado: 'São josé dos quatro apostolos magros',
                                       cep_sacado: '12345678',
                                       cidade_sacado: 'Santa rita de cássia maria da silva',
                                       codigo_multa: '1',
                                       percentual_multa: 2.00,
                                       uf_sacado: 'SP',
                                       chave_nfe: chave_nfe)
  end
  let(:params) do
    { carteira: '123',
      agencia: '1234',
      conta_corrente: '12345',
      digito_conta: '1',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      documento_cedente: '12345678910',
      pagamentos: [pagamento] }
  end
  let(:itau) { subject.class.new(params) }

  context 'monta remessa' do
    context 'detalhe' do
        it 'informacoes devem estar posicionadas corretamente no detalhe' do
            detalhe = itau.monta_detalhe pagamento, 2
            expect(detalhe[37..61]).to eq '6969'.ljust(25)
            expect(detalhe[62..69]).to eq '00000123' # nosso numero
            expect(detalhe[120..125]).to eq Date.current.strftime('%d%m%y') # data de vencimento
            expect(detalhe[126..138]).to eq '0000000019990' # valor do titulo
            expect(detalhe[142..146]).to eq '00000' # agência cobradora
            expect(detalhe[156..157]).to eq '00' # instrução 1
            expect(detalhe[158..159]).to eq '00' # instrução 2
            expect(detalhe[220..233]).to eq '00012345678901' # documento do pagador
            expect(detalhe[234..263]).to eq 'PABLO DIEGO JOSE FRANCISCO DE ' # nome do pagador
            expect(detalhe[400..443]).to eq chave_nfe                        # Chave da Nota Fiscal               [401..444]  x(044)
        end

        it 'informacoes devem estar posicionadas corretamente no detalhe opcional de multa' do
            detalhe_multa = itau.monta_detalhe_multa pagamento, 3
            # Significado                        Posição     Picture
            expect(detalhe_multa[0]).to eq '2'                                # Identificação do reg. transação    [001..001]  9(001)
            expect(detalhe_multa[1]).to eq '1'                                # Código da multa                    [002..002]  X(001)
            expect(detalhe_multa[2..9]).to eq Date.current.strftime('%d%m%Y') # Data da multa                      [003..010]  9(008)
            expect(detalhe_multa[10..22]).to eq '0000000000200'               # Valor da multa                     [011..023]  9(013)
            expect(detalhe_multa[23..393]).to eq ''.rjust(371, ' ')           # Complemento                        [024..394]  X(370)
            expect(detalhe_multa[394..399]).to eq '000003'                    # Número sequencial                  [395..400]  9(006)
        end
      end
  
      context 'arquivo' do
        before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
  
        after { Timecop.return }
  
        it { expect(itau.gera_arquivo).to eq(read_remessa('remessa-itau-cnab444.rem', itau.gera_arquivo)) }
      end
  end
end
