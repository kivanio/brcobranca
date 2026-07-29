# frozen_string_literal: true

require "spec_helper"

RSpec.describe Brcobranca::Remessa::Cnab240::Itau do
  # rubocop:disable Layout/LineLength
  let(:pagamento) do
    Brcobranca::Remessa::Pagamento.new(valor: 123.45,
                                       data_vencimento: Date.current,
                                       nosso_numero: 12_345_678,
                                       documento: 9999,
                                       documento_sacado: "12345678901",
                                       nome_sacado: 'PABLO DIEGO JOSÉ FRANCISCO,!^.?\/@  DE PAULA JUAN NEPOMUCENO MARÍA DE LOS REMEDIOS CIPRIANO DE LA SANTÍSSIMA TRINIDAD RUIZ Y PICASSO',
                                       endereco_sacado: 'RUA RIO GRANDE DO SUL,!^.?\/@ São paulo Minas caçapa da silva junior',
                                       bairro_sacado: "São josé dos quatro apostolos magros",
                                       cep_sacado: "12345678",
                                       cidade_sacado: "Santa rita de cássia maria da silva",
                                       uf_sacado: "SP",
                                       numero: "123",
                                       codigo_baixa: "3",
                                       dias_baixa: "0")
  end
  # rubocop:enable Layout/LineLength
  let(:params) do
    { empresa_mae: "EMPRESA TESTE LTDA",
      documento_cedente: "28254225000193",
      agencia: "1234",
      conta_corrente: "12345",
      carteira: "175",
      sequencial_remessa: "1",
      pagamentos: [pagamento] }
  end
  let(:itau) { subject.class.new(params) }

  context "validacoes" do
    context "@agencia" do
      it "deve ser invalido se a agencia tiver mais de 4 digitos" do
        itau.agencia = "12345"
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).
          to include("Agencia deve ter 4 dígitos.")
      end
    end

    context "@conta_corrente" do
      it "deve ser invalido se a conta_corrente tiver mais de 5 digitos" do
        itau.conta_corrente = "123456"
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).
          to include("Conta corrente deve ter 5 dígitos.")
      end
    end

    context "@carteira" do
      it "deve ser invalido se a carteira tiver mais de 3 digitos" do
        itau.carteira = "1234"
        expect(itau.invalid?).to be true
        expect(itau.errors.full_messages).
          to include("Carteira deve ter 3 dígitos.")
      end
    end
  end

  context "formatacoes" do
    it "codigo do banco deve ser 341" do
      expect(itau.cod_banco).to eq "341"
    end

    it "nome do banco deve ser BANCO ITAU SA com 30 posicoes" do
      nome_banco = itau.nome_banco
      expect(nome_banco.size).to eq 30
      expect(nome_banco[0..12]).to eq "BANCO ITAU SA"
    end

    it "versao do layout do arquivo deve ser 040" do
      expect(itau.versao_layout_arquivo).to eq "040"
    end

    it "versao do layout do lote deve ser 030" do
      expect(itau.versao_layout_lote).to eq "030"
    end

    it "agencia e conta corrente devem ser preenchidas com zeros a esquerda" do
      itau.agencia = "1"
      itau.conta_corrente = "2"
      expect(itau.agencia).to eq "0001"
      expect(itau.conta_corrente).to eq "00002"
    end

    it "DAC agencia/conta deve ser calculado pelo modulo 10" do
      expect(itau.agencia_conta_corrente_dv).to eq "1"
    end

    it "DAC nosso numero deve ser calculado pelo modulo 10" do
      expect(itau.nosso_numero_dv(pagamento)).to eq "5"
    end

    it "DAC nosso numero considera 8 posicoes mesmo se informado mais curto" do
      pagamento.nosso_numero = 7
      itau.carteira = "168" # carteira da excecao (so carteira/nosso_numero)
      expect(itau.nosso_numero_dv(pagamento)).to eq "0"
    end

    it "nosso numero e cortado para 8 posicoes se mais longo (own_number)" do
      pagamento.nosso_numero = "0000000002"
      expect(itau.formata_nosso_numero(pagamento)).to eq "00000002"
      expect(itau.nosso_numero_dv(pagamento)).to eq "9"
    end

    it "info conta deve retornar as informacoes nas posicoes corretas" do
      info_conta = itau.info_conta
      expect(info_conta.size).to eq 20
      expect(info_conta[0]).to eq "0"
      expect(info_conta[1..4]).to eq "1234"
      expect(info_conta[6..12]).to eq "".rjust(7, "0")
      expect(info_conta[13..17]).to eq "12345"
      expect(info_conta[19]).to eq "1"
    end

    it "codigo convenio e convenio lote devem retornar espacos em branco" do
      expect(itau.codigo_convenio).to eq "".rjust(20, " ")
      expect(itau.convenio_lote).to eq "".rjust(20, " ")
    end

    it "complemento header deve ter 29 posicoes" do
      expect(itau.complemento_header.size).to eq 29
    end
  end

  context "geracao remessa" do
    before { Timecop.freeze(Time.local(2015, 7, 14, 16, 15, 15)) }

    after { Timecop.return }

    context "header arquivo" do
      it "header arquivo deve ter 240 posicoes" do
        expect(itau.monta_header_arquivo.size).to eq 240
      end

      it "header arquivo deve ter as informacoes nas posicoes corretas" do
        header = itau.monta_header_arquivo
        expect(header[0..2]).to eq itau.cod_banco # cod. do banco
        expect(header[17]).to eq "2" # tipo inscricao do cedente
        expect(header[18..31]).to eq "28254225000193" # documento do cedente
        expect(header[32..51]).to eq "".rjust(20, " ") # codigo do convenio
        expect(header[52..71]).to eq itau.info_conta # informacoes da conta
        expect(header[72..101]).to eq "EMPRESA TESTE LTDA".ljust(30, " ")
        expect(header[102..131]).to eq itau.nome_banco # nome do banco
        expect(header[157..162]).to eq "000001" # sequencial de remessa
        expect(header[163..165]).to eq itau.versao_layout_arquivo
      end
    end

    context "header lote" do
      it "header lote deve ter 240 posicoes" do
        expect(itau.monta_header_lote(1).size).to eq 240
      end

      it "header lote deve ter as informacoes nas posicoes corretas" do
        header = itau.monta_header_lote(1)
        expect(header[0..2]).to eq itau.cod_banco # cod. do banco
        expect(header[3..6]).to eq "0001" # numero do lote
        expect(header[8]).to eq "R" # tipo de operacao
        expect(header[9..10]).to eq "01" # codigo do servico
        expect(header[11..12]).to eq "00" # uso exclusivo servico
        expect(header[13..15]).to eq itau.versao_layout_lote
        expect(header[17]).to eq "2" # tipo inscricao do cedente
        expect(header[18..32]).to eq "028254225000193" # documento do cedente
        expect(header[33..52]).to eq "".rjust(20, " ") # convenio lote
        expect(header[53..72]).to eq itau.info_conta # informacoes da conta
        expect(header[73..102]).to eq "EMPRESA TESTE LTDA".ljust(30, " ")
        expect(header[183..190]).to eq "00000001" # sequencial de remessa
      end
    end

    context "segmento P" do
      it "segmento P deve ter 240 posicoes" do
        expect(itau.monta_segmento_p(pagamento, 1, 2).size).to eq 240
      end

      it "segmento P deve ter as informacoes nas posicoes corretas" do
        segmento_p = itau.monta_segmento_p(pagamento, 1, 2)
        expect(segmento_p[0..2]).to eq itau.cod_banco # codigo do banco
        expect(segmento_p[3..6]).to eq "0001" # numero do lote
        expect(segmento_p[7]).to eq "3" # tipo de registro
        expect(segmento_p[8..12]).to eq "00002" # sequencial do registro no lote
        expect(segmento_p[13]).to eq "P" # cod. segmento
        expect(segmento_p[15..16]).to eq "01" # cod. movimento remessa
        expect(segmento_p[18..21]).to eq itau.agencia # agencia
        expect(segmento_p[30..34]).to eq itau.conta_corrente # conta corrente
        expect(segmento_p[36]).to eq itau.agencia_conta_corrente_dv
        expect(segmento_p[37..39]).to eq itau.carteira # carteira
        expect(segmento_p[40..47]).to eq "12345678" # nosso numero
        expect(segmento_p[48]).to eq itau.nosso_numero_dv(pagamento)
        expect(segmento_p[77..84]).to eq Date.current.strftime("%d%m%Y")
        expect(segmento_p[85..99]).to eq "000000000012345" # valor do titulo
        expect(segmento_p[106..107]).to eq itau.especie_titulo
        expect(segmento_p[108]).to eq "N" # aceite
        expect(segmento_p[109..116]).to eq Date.current.strftime("%d%m%Y")
        expect(segmento_p[141]).to eq "0" # codigo do desconto
        expect(segmento_p[142..149]).to eq "00000000" # data de desconto
        expect(segmento_p[150..164]).to eq "".rjust(15, "0") # valor do desconto
        expect(segmento_p[165..179]).to eq "".rjust(15, "0") # valor do IOF
        expect(segmento_p[180..194]).to eq "".rjust(15, "0")
      end

      it "segmento P deve ter as informacoes sobre o protesto e a baixa" do
        pagamento.codigo_protesto = "3"
        pagamento.dias_protesto = "6"
        segmento_p = itau.monta_segmento_p(pagamento, 1, 2)

        expect(segmento_p[220]).to eq "3" # codigo para protesto
        expect(segmento_p[221..222]).to eq "06" # prazo para protesto
        expect(segmento_p[223]).to eq "3" # codigo para baixa
        expect(segmento_p[224..225]).to eq "00" # prazo para baixa
      end

      it "segmento P mantem 240 posicoes com nosso numero de +8 digitos" do
        pagamento.nosso_numero = "0000000002" # own_number do Odoo, 10 digitos
        segmento_p = itau.monta_segmento_p(pagamento, 1, 2)

        expect(segmento_p.size).to eq 240
        expect(segmento_p[40..47]).to eq "00000002" # cortado p/ 8 posicoes
      end

      it "segmento P mantem 240 posicoes com o dias_baixa padrao " \
         "de Pagamento (3 digitos, sem informar prazo de baixa)" do
        pagamento_sem_dias_baixa = Brcobranca::Remessa::Pagamento.new(
          valor: 123.45,
          data_vencimento: Date.current,
          nosso_numero: 12_345_678,
          documento_sacado: "12345678901",
          nome_sacado: "FULANO DE TAL",
          endereco_sacado: "RUA TESTE",
          bairro_sacado: "BAIRRO",
          cep_sacado: "12345678",
          cidade_sacado: "CIDADE",
          uf_sacado: "SP"
        )
        segmento_p = itau.monta_segmento_p(pagamento_sem_dias_baixa, 1, 2)

        expect(segmento_p.size).to eq 240
        expect(segmento_p[224..225]).to eq "00" # cortado p/ 2 posicoes
      end
    end

    context "segmento Q" do
      it "segmento Q deve ter 240 posicoes" do
        expect(itau.monta_segmento_q(pagamento, 1, 3).size).to eq 240
      end

      it "segmento Q deve ter as informacoes nas posicoes corretas" do
        segmento_q = itau.monta_segmento_q(pagamento, 1, 3)
        expect(segmento_q[0..2]).to eq itau.cod_banco # codigo do banco
        expect(segmento_q[3..6]).to eq "0001" # numero do lote
        expect(segmento_q[8..12]).to eq "00003" # numero do registro no lote
        expect(segmento_q[13]).to eq "Q" # cod. segmento
        expect(segmento_q[15..16]).to eq "01" # cod. movimento remessa
        expect(segmento_q[17]).to eq "1" # tipo inscricao pagador
        expect(segmento_q[18..32]).to eq "000012345678901"
        nome = "PABLO DIEGO JOSE FRANCISCO DE PAULA JUAN"[0..29]
        expect(segmento_q[33..62]).to eq nome
        expect(segmento_q[63..72]).to eq "".rjust(10, " ") # brancos
        expect(segmento_q[128..132]).to eq "12345" # CEP do pagador
        expect(segmento_q[133..135]).to eq "678" # sufixo CEP do pagador
        expect(segmento_q[151..152]).to eq "SP" # UF do pagador
      end
    end

    context "segmento R" do
      it "segmento R deve ter 240 posicoes (layout padrao da classe base)" do
        expect(itau.monta_segmento_r(pagamento, 1, 4).size).to eq 240
      end
    end

    context "trailer lote" do
      it "trailer lote deve ter 240 posicoes" do
        expect(itau.monta_trailer_lote(1, 4).size).to eq 240
      end
    end

    context "trailer arquivo" do
      it "trailer arquivo deve ter 240 posicoes" do
        expect(itau.monta_trailer_arquivo(1, 6).size).to eq 240
      end
    end

    context "monta lote" do
      it "retorno de lote deve ser uma colecao com os registros" do
        lote = itau.monta_lote(1)

        expect(lote.is_a?(Array)).to be true
        expect(lote.count).to be 5 # header, p, q, r, trailer
      end
    end

    context "gera arquivo" do
      it "deve falhar se o objeto for invalido" do
        expect { subject.class.new.gera_arquivo }.
          to raise_error(Brcobranca::RemessaInvalida)
      end

      it "remessa deve conter os registros mais as quebras de linha" do
        remessa = itau.gera_arquivo

        expect(remessa.size).to eq 1694
        # quebras de linha
        expect(remessa[240..241]).to eq "\r\n"
        expect(remessa[482..483]).to eq "\r\n"
        expect(remessa[724..725]).to eq "\r\n"
        expect(remessa[966..967]).to eq "\r\n"
        expect(remessa[1208..1209]).to eq "\r\n"
      end

      it {
        expect(itau.gera_arquivo).
          to eq(read_remessa("remessa-itau-cnab240.rem", itau.gera_arquivo))
      }
    end
  end
end
