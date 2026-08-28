# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Remessa::Cnab240::Unicred do
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(
      valor: 50.0,
      data_vencimento: Date.current,
      nosso_numero: '072000031',
      numero: '00003',
      documento: 6969,
      documento_sacado: '82136760505',
      nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
      endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
      bairro_sacado: 'São josé dos quatro apostolos magros',
      cep_sacado: '12345678',
      cidade_sacado: 'Santa rita de cássia maria da silva',
      uf_sacado: 'RJ'
    )
  end

  let(:params) do
    {
      empresa_mae: 'SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA',
      agencia: '0165',
      conta_corrente: '00623',
      digito_conta: '8',
      documento_cedente: '74576177000177',
      carteira: '21',
      parametro_movimento: '001',
      sequencial_remessa: '1',
      mensagem_1: 'Campo destinado ao preenchimento no momento do pagamento.',
      mensagem_2: 'Nao receber apos o vencimento',
      pagamentos: [pagamento]
    }
  end

  let(:unicred) { subject.class.new(params) }

  before { Timecop.freeze(Time.local(2007, 7, 14, 16, 15, 15)) }

  after { Timecop.return }

  context 'validacoes' do
    context '@agencia' do
      it 'deve ser invalido se a agencia tiver mais de 4 digitos' do
        unicred.agencia = '12345'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Agencia deve ter 4 dígitos.')
      end
    end

    context '@conta_corrente' do
      it 'deve ser invalido se a conta corrente tiver mais de 12 digitos' do
        unicred.conta_corrente = '1234567890123'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Conta corrente deve ter no máximo 12 dígitos.')
      end
    end

    context '@digito_conta' do
      it 'deve ser invalido se o digito da conta nao for informado' do
        unicred.digito_conta = nil
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Digito conta não pode estar em branco.')
      end

      it 'deve ser invalido se o digito da conta tiver mais de 1 digito' do
        unicred.digito_conta = '12'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Digito conta deve ter 1 dígito.')
      end
    end

    context '@carteira' do
      it 'deve ser invalido se a carteira nao for 21' do
        unicred.carteira = '99'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Carteira não existente para este banco.')
      end
    end

    context '@parametro_movimento' do
      it 'deve ser invalido se o parametro de movimento tiver mais de 3 digitos' do
        unicred.parametro_movimento = '1234'
        expect(unicred.invalid?).to be true
        expect(unicred.errors.full_messages).to include('Parametro movimento deve ter 3 dígitos.')
      end
    end
  end

  context 'formatacoes' do
    it 'codigo do banco deve ser 136' do
      expect(unicred.cod_banco).to eq '136'
    end

    it 'nome do banco deve ser UNICRED com 30 posicoes' do
      nome_banco = unicred.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco).to eq 'UNICRED'.ljust(30, ' ')
    end

    it 'versao do layout do arquivo deve ser 085' do
      expect(unicred.versao_layout_arquivo).to eq '085'
    end

    it 'versao do layout do lote deve ser 044' do
      expect(unicred.versao_layout_lote).to eq '044'
    end

    it 'densidade de gravacao deve ser 1600 BPI' do
      expect(unicred.densidade_gravacao).to eq '01600'
    end

    it 'carteira deve ser preenchida com 2 posicoes' do
      expect(subject.class.new(params.merge(carteira: '21')).carteira).to eq '21'
    end

    it 'deve calcular o digito da agencia' do
      # modulo 11 sobre a agencia com 4 digitos: 0165 => 1
      expect(unicred.digito_agencia).to eq '1'
    end

    it 'cod. convenio deve ser filler' do
      expect(unicred.codigo_convenio).to eq ''.rjust(20, ' ')
      expect(unicred.convenio_lote).to eq ''.rjust(20, ' ')
    end

    it 'info conta deve retornar as informacoes nas posicoes corretas' do
      info_conta = unicred.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0..4]).to eq '00165' # agencia
      expect(info_conta[5]).to eq '1' # dv da agencia
      expect(info_conta[6..17]).to eq '000000000623' # conta corrente
      expect(info_conta[18]).to eq '8' # dv da conta
      expect(info_conta[19]).to eq '0' # filler
    end

    it 'complemento header deve retornar espacos em branco' do
      expect(unicred.complemento_header).to eq ''.rjust(29, ' ')
    end

    it 'uso exclusivo do banco deve conter o parametro de movimento' do
      uso_exclusivo = unicred.uso_exclusivo_banco
      expect(uso_exclusivo.size).to eq 20
      expect(uso_exclusivo[0..2]).to eq '001'
      expect(uso_exclusivo[3..19]).to eq ''.rjust(17, ' ')
    end

    it 'complemento trailer deve totalizar a cobranca simples' do
      complemento = unicred.complemento_trailer
      expect(complemento.size).to eq 217
      expect(complemento[0..5]).to eq '000001' # qtde de titulos em cobranca simples
      expect(complemento[6..22]).to eq '00000000000005000' # valor dos titulos
      expect(complemento[23..91]).to eq ''.rjust(69, '0') # demais carteiras
      expect(complemento[92..216]).to eq ''.rjust(125, ' ')
    end

    it 'formata o nosso numero com o digito verificador' do
      # mesmo digito calculado pelo boleto do Unicred
      expect(unicred.formata_nosso_numero('072000031')).to eq '00720000319'
    end
  end

  context 'geracao remessa' do
    context 'header arquivo' do
      it 'header arquivo deve ter 240 posicoes' do
        expect(unicred.monta_header_arquivo.size).to eq 240
      end

      it 'header arquivo deve ter as informacoes nas posicoes corretas' do
        header = unicred.monta_header_arquivo
        expect(header[0..2]).to eq '136' # cod. do banco
        expect(header[3..6]).to eq '0000' # lote de servico
        expect(header[7]).to eq '0' # tipo de registro
        expect(header[17]).to eq '2' # tipo inscricao do cedente
        expect(header[18..31]).to eq '74576177000177' # documento do cedente
        expect(header[32..51]).to eq ''.rjust(20, ' ') # filler
        expect(header[52..71]).to eq unicred.info_conta # informacoes da conta
        expect(header[72..101]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOG' # razao social
        expect(header[102..131]).to eq unicred.nome_banco # nome do banco
        expect(header[142]).to eq '1' # codigo remessa
        expect(header[143..150]).to eq '14072007' # data de geracao
        expect(header[151..156]).to eq '161515' # hora de geracao
        expect(header[157..162]).to eq '000001' # sequencial de remessa
        expect(header[163..165]).to eq '085' # versao do layout
        expect(header[166..170]).to eq '01600' # densidade
        expect(header[171..173]).to eq '001' # parametro de movimento
        expect(header[174..239]).to eq ''.rjust(66, ' ') # reservados e CNAB
      end
    end

    context 'header lote' do
      it 'header lote deve ter 240 posicoes' do
        expect(unicred.monta_header_lote(1).size).to eq 240
      end

      it 'header lote deve ter as informacoes nas posicoes corretas' do
        header = unicred.monta_header_lote 1
        expect(header[0..2]).to eq '136' # cod. do banco
        expect(header[3..6]).to eq '0001' # numero do lote
        expect(header[7]).to eq '1' # tipo de registro
        expect(header[8]).to eq 'R' # tipo de operacao
        expect(header[9..10]).to eq '01' # tipo de servico
        expect(header[13..15]).to eq '044' # versao do layout do lote
        expect(header[17]).to eq '2' # tipo inscricao do cedente
        expect(header[18..32]).to eq '074576177000177' # documento do cedente
        expect(header[33..52]).to eq ''.rjust(20, ' ') # filler
        expect(header[53..72]).to eq unicred.info_conta # informacoes da conta
        expect(header[73..102]).to eq 'SOCIEDADE BRASILEIRA DE ZOOLOG' # razao social
        expect(header[103..182]).to eq ''.rjust(80, ' ') # filler (mensagens vao no segmento R)
        expect(header[183..190]).to eq '00000001' # numero da remessa
        expect(header[191..198]).to eq '14072007' # data de gravacao
        expect(header[199..206]).to eq ''.rjust(8, ' ') # data do credito
        expect(header[207..239]).to eq ''.rjust(33, ' ') # filler e CNAB
      end
    end

    context 'segmento P' do
      it 'segmento P deve ter 240 posicoes' do
        expect(unicred.monta_segmento_p(pagamento, 1, 2).size).to eq 240
      end

      it 'segmento P deve ter as informacoes nas posicoes corretas' do
        segmento_p = unicred.monta_segmento_p pagamento, 1, 2
        expect(segmento_p[0..2]).to eq '136' # cod. do banco
        expect(segmento_p[3..6]).to eq '0001' # numero do lote
        expect(segmento_p[7]).to eq '3' # tipo de registro
        expect(segmento_p[8..12]).to eq '00002' # sequencial do registro no lote
        expect(segmento_p[13]).to eq 'P' # cod. do segmento
        expect(segmento_p[15..16]).to eq '01' # cod. movimento remessa
        expect(segmento_p[17..21]).to eq '00165' # agencia
        expect(segmento_p[22]).to eq '1' # dv da agencia
        expect(segmento_p[23..34]).to eq '000000000623' # conta corrente
        expect(segmento_p[35]).to eq '8' # dv da conta
        expect(segmento_p[36]).to eq '0' # filler
        expect(segmento_p[37..47]).to eq '00720000319' # nosso numero com dv
        expect(segmento_p[48..55]).to eq ''.rjust(8, ' ') # filler
        expect(segmento_p[56..57]).to eq '21' # carteira
        expect(segmento_p[62..76]).to eq '000000000006969' # numero do documento
        expect(segmento_p[77..84]).to eq '14072007' # data de vencimento
        expect(segmento_p[85..99]).to eq '000000000005000' # valor do titulo
        expect(segmento_p[100..105]).to eq ''.rjust(6, ' ') # agencia cobradora e dv
        expect(segmento_p[106..107]).to eq '00' # filler
        expect(segmento_p[108]).to eq 'N' # aceite
        expect(segmento_p[109..116]).to eq '14072007' # data de emissao
        expect(segmento_p[118..125]).to eq ''.rjust(8, '0') # filler
        expect(segmento_p[141]).to eq '0' # cod. do desconto
        expect(segmento_p[142..149]).to eq ''.rjust(8, '0') # data do desconto
        expect(segmento_p[150..164]).to eq ''.rjust(15, '0') # valor do desconto
        expect(segmento_p[165..179]).to eq ''.rjust(15, '0') # filler
        expect(segmento_p[180..194]).to eq ''.rjust(15, '0') # valor do abatimento
        expect(segmento_p[195..219]).to eq '6969'.rjust(25, ' ') # titulo na empresa
        expect(segmento_p[223]).to eq '0' # filler
        expect(segmento_p[224..226]).to eq ''.rjust(3, ' ') # filler
        expect(segmento_p[227..228]).to eq '09' # cod. da moeda
        expect(segmento_p[229..238]).to eq ''.rjust(10, '0') # numero do contrato
        expect(segmento_p[239]).to eq ' ' # CNAB
      end

      it 'segmento P deve ter as informacoes sobre o protesto' do
        pagamento.codigo_protesto = '1'
        pagamento.dias_protesto = '6'
        segmento_p = unicred.monta_segmento_p pagamento, 1, 2

        expect(segmento_p[220]).to eq '1'
        expect(segmento_p[221..222]).to eq '06'
      end
    end

    context 'segmento Q' do
      it 'segmento Q deve ter 240 posicoes' do
        expect(unicred.monta_segmento_q(pagamento, 1, 3).size).to eq 240
      end

      it 'segmento Q deve ter as informacoes nas posicoes corretas' do
        segmento_q = unicred.monta_segmento_q pagamento, 1, 3
        expect(segmento_q[0..2]).to eq '136' # cod. do banco
        expect(segmento_q[8..12]).to eq '00003' # sequencial do registro no lote
        expect(segmento_q[13]).to eq 'Q' # cod. do segmento
        expect(segmento_q[17]).to eq '1' # tipo inscricao do sacado
        expect(segmento_q[18..32]).to eq '000082136760505' # documento do sacado
        expect(segmento_q[33..72]).to eq 'PABLO DIEGO JOSE FRANCISCO DE PAULA JUAN' # nome
        expect(segmento_q[113..127]).to eq 'Sao jose dos qu' # bairro
        expect(segmento_q[128..132]).to eq '12345' # CEP
        expect(segmento_q[133..135]).to eq '678' # sufixo do CEP
        expect(segmento_q[151..152]).to eq 'RJ' # UF
      end
    end

    context 'segmento R' do
      it 'segmento R deve ter 240 posicoes' do
        expect(unicred.monta_segmento_r(pagamento, 1, 4).size).to eq 240
      end

      it 'segmento R deve ter as informacoes nas posicoes corretas' do
        segmento_r = unicred.monta_segmento_r pagamento, 1, 4
        expect(segmento_r[0..2]).to eq '136' # cod. do banco
        expect(segmento_r[8..12]).to eq '00004' # sequencial do registro no lote
        expect(segmento_r[13]).to eq 'R' # cod. do segmento
        expect(segmento_r[15..16]).to eq '01' # cod. movimento remessa
        expect(segmento_r[17..64]).to eq ''.rjust(48, '0') # filler (descontos 2 e 3)
        expect(segmento_r[65]).to eq ' ' # filler
        expect(segmento_r[66..88]).to eq ''.rjust(23, '0') # filler (multa)
        expect(segmento_r[89..98]).to eq ''.rjust(10, ' ') # informacao ao sacado
        expect(segmento_r[99..138]).to eq 'Campo destinado ao preenchimento no mome' # mensagem 1
        expect(segmento_r[139..178]).to eq 'Nao receber apos o vencimento'.ljust(40, ' ') # mensagem 2
        expect(segmento_r[179..239]).to eq unicred.complemento_r # complemento
      end
    end

    context 'trailer lote' do
      it 'trailer lote deve ter 240 posicoes' do
        expect(unicred.monta_trailer_lote(1, 5).size).to eq 240
      end

      it 'trailer lote deve ter as informacoes nas posicoes corretas' do
        trailer = unicred.monta_trailer_lote 1, 5
        expect(trailer[0..2]).to eq '136' # cod. do banco
        expect(trailer[3..6]).to eq '0001' # numero do lote
        expect(trailer[7]).to eq '5' # tipo de registro
        expect(trailer[17..22]).to eq '000005' # qtde de registros no lote
        expect(trailer[23..239]).to eq unicred.complemento_trailer
      end
    end

    context 'trailer arquivo' do
      it 'trailer arquivo deve ter 240 posicoes' do
        expect(unicred.monta_trailer_arquivo(1, 7).size).to eq 240
      end

      it 'trailer arquivo deve ter as informacoes nas posicoes corretas' do
        trailer = unicred.monta_trailer_arquivo 1, 7
        expect(trailer[0..2]).to eq '136' # cod. do banco
        expect(trailer[3..6]).to eq '9999' # lote de servico
        expect(trailer[7]).to eq '9' # tipo de registro
        expect(trailer[17..22]).to eq '000001' # qtde de lotes
        expect(trailer[23..28]).to eq '000007' # qtde de registros
        expect(trailer[29..34]).to eq '000000' # qtde de contas para conciliacao
        expect(trailer[35..239]).to eq ''.rjust(205, ' ') # CNAB
      end
    end

    context 'monta lote' do
      it 'retorno de lote deve ser uma colecao com os registros' do
        lote = unicred.monta_lote(1)

        expect(lote.is_a?(Array)).to be true
        expect(lote.count).to be 5 # header, segmento p, segmento q, segmento r e trailer
      end

      it 'contador de registros deve acrescer 1 a cada registro' do
        lote = unicred.monta_lote(1)

        expect(lote[1][8..12]).to eq '00001' # segmento P
        expect(lote[2][8..12]).to eq '00002' # segmento Q
        expect(lote[3][8..12]).to eq '00003' # segmento R
        expect(lote[4][17..22]).to eq '000005' # trailer do lote
      end
    end

    context 'gera arquivo' do
      it 'deve falhar se o objeto for invalido' do
        expect { subject.class.new.gera_arquivo }.to raise_error(Brcobranca::RemessaInvalida)
      end

      it 'remessa deve conter os registros mais as quebras de linha' do
        remessa = unicred.gera_arquivo

        expect(remessa.size).to eq 1694
        expect(remessa[240..241]).to eq "\r\n"
        expect(remessa[482..483]).to eq "\r\n"
        expect(remessa[724..725]).to eq "\r\n"
        expect(remessa[966..967]).to eq "\r\n"
        expect(remessa[1208..1209]).to eq "\r\n"
      end

      it { expect(unicred.gera_arquivo).to eq(read_remessa('remessa-unicred-cnab240.rem', unicred.gera_arquivo)) }
    end
  end
end
