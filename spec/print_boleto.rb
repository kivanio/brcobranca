#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require "brcobranca"
require "rghost"

Brcobranca.setup { |br| br.gerador = :rghost_proposta }

if ENV.fetch("CONSOLE", nil).nil?
  dados = {
    cedente: "Kivanio Barbosa",
    documento_cedente: "12345678912",
    sacado: "Claudio Pozzebom",
    sacado_documento: "12345678900",
    valor: 135.00,
    agencia: "4042",
    conta_corrente: "61900",
    convenio: "1238798",
    nosso_numero: "7777700168",
    documento_numero: "666-0",
    data_vencimento: Date.parse("2008-02-01"),
    data_documento: Date.parse("2008-02-01"),

    instrucao1: "Sr. Caixa: este boleto pode ser pago com qualquer valor.",
    instrucao2: "Sugerimos o valor acima de R$ 20,00 devido às despesas bancárias e de envio.",
    instrucao3: "Após o vencimento pagável somente nas agências Bradesco.",
    instrucao4: "Este boleto deve ser utilizado para doação espontânea, não é uma cobrança.",

    # instrucao1: "Pagável na rede bancária até a data de vencimento.",
    # instrucao2: "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)",
    # instrucao3: "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006",
    # instrucao4: "NÃO RECEBER APÓS 15/11/2006",
    # instrucao5: "Após vencimento pagável somente nas agências do Banco do Brasil",
    # instrucao6: "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO",
    sacado_endereco: "Av. Rubéns de Mendonça, 157 - Apto 3\nCentro\n78008-000 - Cuiabá -MT"
  }

  File.open("proposta_itau.pdf", "w") do |f|
    f.write(Brcobranca::Boleto::Itau.new(dados.merge(convenio: "12387", nosso_numero: "12345678")).to_pdf)
  end

  File.open("proposta_bradesco.pdf", "w") { |f| f.write(Brcobranca::Boleto::Bradesco.new(dados).to_pdf) }
  File.open("proposta_banco_brasil.pdf", "w") { |f| f.write(Brcobranca::Boleto::BancoBrasil.new(dados).to_pdf) }
else
  require "irb"
  require "irb/completion"

  IRB.start
end
