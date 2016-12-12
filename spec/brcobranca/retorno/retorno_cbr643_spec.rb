# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::Retorno::RetornoCbr643 do
  before do
    @arquivo = File.join(File.dirname(__FILE__), '..', '..', 'arquivos', 'CBR64310.RET')
  end

  it 'Transforma arquivo de retorno em objetos de retorno' do
    pagamentos = described_class.load_lines(@arquivo)
    expect(pagamentos.first.sequencial).to eql('000001')
    expect(pagamentos.first.agencia_com_dv).to eql('CA')
    expect(pagamentos.first.cedente_com_dv).to eql('33251')
    expect(pagamentos.first.convenio).to eql('0002893')
    expect(pagamentos.first.data_liquidacao).to eql('')
    expect(pagamentos.first.data_credito).to eql('')
    expect(pagamentos.first.valor_recebido).to eql('')
    expect(pagamentos.first.nosso_numero).to eql('OSSENSE DO AL001B')
  end

  it 'Transforma arquivo de retorno em objetos de retorno excluindo a primeira linha com a opção :except' do
    pagamentos = described_class.load_lines(@arquivo, except: [1])
    expect(pagamentos.first.sequencial).to eql('000002')
    expect(pagamentos.first.agencia_com_dv).to eql('33251')
    expect(pagamentos.first.cedente_com_dv).to eql('000289353')
    expect(pagamentos.first.convenio).to eql('1622420')
    expect(pagamentos.first.data_liquidacao).to eql('200109')
    expect(pagamentos.first.data_credito).to eql('220109')
    expect(pagamentos.first.valor_recebido).to eql('0000000009064')
    expect(pagamentos.first.nosso_numero).to eql('16224200000000003')
  end

  # it "Transforma arquivo de retorno em objetos de retorno excluindo a primeira linha com a opção :except e :length" do
  #   pagamentos = Brcobranca::Retorno::RetornoCbr643.load_lines(@arquivo,{:except => [1], :length => 400})
  #   pagamentos.first.sequencial.should eql("000002")
  #   pagamentos.first.agencia_com_dv.should eql("33251")
  #   pagamentos.first.cedente_com_dv.should eql("000289353")
  #   pagamentos.first.convenio.should eql("1622420")
  #   pagamentos.first.data_liquidacao.should eql("200109")
  #   pagamentos.first.data_credito.should eql("220109")
  #   pagamentos.first.valor_recebido.should eql("0000000009064")
  #   pagamentos.first.nosso_numero.should eql("16224200000000003")
  # end

  it 'Transforma arquivo de retorno em objetos de retorno excluindo a primeira linha com a opção :except em regex' do
    pagamentos = described_class.load_lines(@arquivo, except: /^[^7]/)
    expect(pagamentos.first.sequencial).to eql('000002')
    expect(pagamentos.first.agencia_com_dv).to eql('33251')
    expect(pagamentos.first.cedente_com_dv).to eql('000289353')
    expect(pagamentos.first.convenio).to eql('1622420')
    expect(pagamentos.first.data_liquidacao).to eql('200109')
    expect(pagamentos.first.data_credito).to eql('220109')
    expect(pagamentos.first.valor_recebido).to eql('0000000009064')
    expect(pagamentos.first.nosso_numero).to eql('16224200000000003')
  end

  # it "Transforma arquivo de retorno em objetos de retorno excluindo a primeira linha com a opção :except em regex e :length" do
  #   pagamentos = Brcobranca::Retorno::RetornoCbr643.load_lines(@arquivo,{:except => /^[^7]/, :length => 400})
  #   pagamentos.first.sequencial.should eql("000002")
  #   pagamentos.first.agencia_com_dv.should eql("33251")
  #   pagamentos.first.cedente_com_dv.should eql("000289353")
  #   pagamentos.first.convenio.should eql("1622420")
  #   pagamentos.first.data_liquidacao.should eql("200109")
  #   pagamentos.first.data_credito.should eql("220109")
  #   pagamentos.first.valor_recebido.should eql("0000000009064")
  #   pagamentos.first.nosso_numero.should eql("16224200000000003")
  # end
end
