# -*- encoding: utf-8 -*-
require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab400::Banrisul do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 199.9,
      data_vencimento: Date.current,
      nosso_numero: 22832563,
      documento: '1',
      documento_sacado: '12345678901',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      percentual_multa: 2.0,
      uf_sacado: 'SP')
  end
  let(:params) do
    {
      carteira: '1',
      agencia: '1102',
      convenio: '1102900015046',
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      sequencial_remessa: '1',
      pagamentos: [pagamento]
    }
  end

  let(:banrisul) { subject.class.new(params) }

  context 'validacoes dos campos' do
    context '@agencia' do
      it 'deve ser inválido se não possuir uma agência' do
        objeto = subject.class.new(params.merge!(agencia: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Agencia não pode estar em branco.')
      end

      it 'deve ser inválido se a agência tiver mais de 4 dígitos' do
        banrisul.agencia = '12345'
        expect(banrisul.invalid?).to be true
        expect(banrisul.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@convenio' do
      it 'deve ser inválido se não possuir um convênio' do
        objeto = subject.class.new(params.merge!(convenio: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Convenio não pode estar em branco.')
      end

      it 'deve ser inválido se o convenio tiver mais de 7 dígitos' do
        banrisul.convenio = '12345678901234'
        expect(banrisul.invalid?).to be true
        expect(banrisul.errors.full_messages).to include('Convenio deve ter 13 dígitos.')
      end
    end

    context '@carteira' do
      it 'deve ser inválido se não possuir uma carteira' do
        objeto = subject.class.new(params.merge!(carteira: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Carteira não pode estar em branco.')
      end

      it 'deve ser inválido se a carteira tiver mais de 1 dígito' do
        banrisul.carteira = '123'
        expect(banrisul.invalid?).to be true
        expect(banrisul.errors.full_messages).to include('Carteira deve ter 1 dígito.')
      end
    end

    context '@sequencial_remessa' do
      it 'deve ser inválido se não possuir um num. sequencial de remessa' do
        objeto = subject.class.new(params.merge!(sequencial_remessa: nil))
        expect(objeto.invalid?).to be true
        expect(objeto.errors.full_messages).to include('Sequencial remessa não pode estar em branco.')
      end

      it 'deve ser inválido se sequencial de remessa tiver mais de 8 dígitos' do
        banrisul.sequencial_remessa = '12345678'
        expect(banrisul.invalid?).to be true
        expect(banrisul.errors.full_messages).to include('Sequencial remessa deve ter 7 dígitos.')
      end
    end
  end

  context 'formatacoes dos valores' do
    it 'código do banco deve ser 041' do
      expect(banrisul.cod_banco).to eq '041'
    end

    it 'nome do banco deve ser BANRISUL com 15 posicoes' do
      nome_banco = banrisul.nome_banco
      expect(nome_banco.size).to eq 15
      expect(nome_banco.strip).to eq 'BANRISUL'
    end

    it 'complemento deve ter 294 caracteres com as informações nas posições corretas' do
      complemento = banrisul.complemento
      expect(complemento.size).to eq 294
    end

    it 'info_conta deve ter 20 posicoes' do
      expect(banrisul.info_conta.size).to eq 20
    end

    it 'código do cedente deve ter as informações nas posicoes corretas' do
      id_empresa = banrisul.codigo_cedente
      expect(id_empresa[0..3]).to eq '1102'        # agência
      expect(id_empresa[4..10]).to eq '9000150'    # convênio
      expect(id_empresa[11..12]).to eq '46'        # dígitos do convênio
    end

    it 'calcula o dígito verificador do nosso número' do
      expect(banrisul.digito_nosso_numero(22832563)).to eq("51")
    end
  end

  context 'monta remessa' do
    it_behaves_like 'cnab400'

    context 'header' do
      it 'informações devem estar posicionadas corretamente no header' do
        header = banrisul.monta_header
        expect(header[1]).to eq '1'                      # tipo operação (1 = remessa)
        expect(header[2..8]).to eq 'REMESSA'             # literal da operação
        expect(header[26..45]).to eq banrisul.info_conta # informações da conta
        expect(header[76..78]).to eq '041'               # código do banco
      end
    end

    context 'detalhe' do
      it 'informações devem estar posicionadas corretamente no detalhe' do
        detalhe = banrisul.monta_detalhe pagamento, 1
        expect(detalhe[0]).to eq '1'                                                 # tipo do registro
        expect(detalhe[1..16]).to eq ''.rjust(16, ' ')                               # brancos
        expect(detalhe[17..29]).to eq '1102900015046'                                # código do cedente
        expect(detalhe[30..36]).to eq ''.rjust(7, ' ')                               # brancos
        expect(detalhe[37..61]).to eq '1'.ljust(25, ' ')                             # num. controle
        expect(detalhe[62..69]).to eq '22832563'                                     # nosso número
        expect(detalhe[70..71]).to eq '51'                                           # dígitos nosso número
        expect(detalhe[72..103]).to eq ''.rjust(32, ' ')                             # mensagem bloqueto
        expect(detalhe[104..106]).to eq ''.rjust(3, ' ')                             # branco
        expect(detalhe[107]).to eq '1'                                               # carteira
        expect(detalhe[108..109]).to eq '01'                                         # código da ocorrência
        expect(detalhe[110..119]).to eq '1'.ljust(10, ' ')                           # seu número
        expect(detalhe[120..125]).to eq Date.current.strftime('%d%m%y')                # data de vencimento
        expect(detalhe[126..138]).to eq '0000000019990'                              # valor do documento
        expect(detalhe[139..141]).to eq '041'                                        # banco cobrador
        expect(detalhe[142..146]).to eq ''.rjust(5, ' ')                             # brancos
        expect(detalhe[147..148]).to eq '08'                                         # tipo de documento (08 - Cobrança Credenciada Banrisul - CCB)
        expect(detalhe[149]).to eq 'N'                                               # código de aceite
        expect(detalhe[150..155]).to eq Date.current.strftime('%d%m%y')                # data de emissão
        expect(detalhe[156..157]).to eq '18'                                         # código da 1a instrução
        expect(detalhe[158..159]).to eq '00'                                         # código da 2a instrução
        expect(detalhe[160]).to eq ' '                                               # código da mora
        expect(detalhe[161..172]).to eq ''.rjust(12, ' ')                            # valor ao dia ou mensal de juros
        expect(detalhe[173..178]).to eq ''.rjust(6, '0')                             # data para concessão do desconto
        expect(detalhe[179..191]).to eq ''.rjust(13, '0')                            # valor do desconto a ser concedido
        expect(detalhe[192..204]).to eq ''.rjust(13, '0')                            # valor do iof
        expect(detalhe[205..217]).to eq ''.rjust(13, '0')                            # valor do abatimento
        expect(detalhe[218..219]).to eq '01'                                         # tipo de insc. do pagador
        expect(detalhe[220..233]).to eq '00012345678901'                             # num. da insc. do pagador
        expect(detalhe[234..268]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA'        # nome do pagador
        expect(detalhe[274..313]).to eq 'RUA RIO GRANDE DO SUL Sao paulo Minas ca'   # endereço do pagador
        expect(detalhe[314..320]).to eq ''.rjust(7, ' ')                             # brancos
        expect(detalhe[321..323]).to eq '020'                                        # multa
        expect(detalhe[324..325]).to eq '00'                                         # num. dias para a multa após o vencimento
        expect(detalhe[326..333]).to eq '12345678'                                   # cep do pagador
        expect(detalhe[334..348]).to eq 'Santa rita de c'                            # cidade do pagador
        expect(detalhe[349..350]).to eq 'SP'                                         # uf do pagador
        expect(detalhe[351..354]).to eq '0000'                                       # taxa ao dia para pag. antecipado
        expect(detalhe[355]).to eq ' '                                               # branco
        expect(detalhe[356..368]).to eq ''.rjust(13, '0')                            # valor para cálc. do desconto
        expect(detalhe[369..370]).to eq '00'                                         # dias para protesto
        expect(detalhe[371..393]).to eq ''.rjust(23, ' ')                            # brancos
      end
    end

    context 'arquivo' do
      before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }
      after { Timecop.return }

      it { expect(banrisul.gera_arquivo).to eq(read_remessa('remessa-banrisul-cnab400.rem', banrisul.gera_arquivo)) }
    end
  end
end
