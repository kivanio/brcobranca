require File.join(File.dirname(__FILE__),'test_helper.rb')

class TestBancoUnibanco < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoUnibanco.new
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.conta_corrente = "61900"
  end

  def boleto_com_registro
    @boleto_novo.agencia = "0123"
    @boleto_novo.conta_corrente = "100618"
    @boleto_novo.carteira = "4"
    @boleto_novo.convenio = 2031671
    @boleto_novo.valor = 2952.95
    @boleto_novo.numero_documento = "1803029901"
    @boleto_novo.data_documento = Date.parse("2009-04-30")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_sem_registro
    @boleto_novo.agencia = "0123"
    @boleto_novo.conta_corrente = "100618"
    @boleto_novo.carteira = "5"
    @boleto_novo.convenio = 2031671
    @boleto_novo.valor = 2952.95
    @boleto_novo.numero_documento = "1803029901"
    @boleto_novo.data_documento = Date.parse("2009-04-30")
    @boleto_novo.dias_vencimento = 0
  end

  def boleto_nil
    @boleto_novo.banco = ""
    @boleto_novo.carteira = ""
    @boleto_novo.moeda = ""
    @boleto_novo.valor = 0
    @boleto_novo.convenio = ""
    @boleto_novo.numero_documento = "" 
    @boleto_novo.data_documento = Date.parse("2008-02-01")
    @boleto_novo.dias_vencimento = 0
  end

  def test_should_initialize_correctly
    assert_equal '409', @boleto_novo.banco
    assert_equal '5', @boleto_novo.carteira
    assert_equal "DM", @boleto_novo.especie_documento
    assert_equal "R$", @boleto_novo.especie
    assert_equal "9", @boleto_novo.moeda
    assert_equal Date.today, @boleto_novo.data_documento
    assert_equal 1, @boleto_novo.dias_vencimento
    assert_equal((Date.today + 1), @boleto_novo.data_vencimento)
    assert_equal "S", @boleto_novo.aceite
    assert_equal 1, @boleto_novo.quantidade
    assert_equal 0.0, @boleto_novo.valor
    assert_equal 0.0, @boleto_novo.valor_documento
    assert_equal "QUALQUER BANCO ATÉ O VENCIMENTO", @boleto_novo.local_pagamento
  end
  
  def return_correct_nosso_numero_dv
    @boleto_novo.numero_documento = "00001803029901"
    assert_equal "5", @boleto_novo.nosso_numero_dv
  end

  def test_should_mont_correct_codigo_barras
    boleto_sem_registro
    assert_equal "4099422300002952955203167100000018030299015", @boleto_novo.monta_codigo_43_digitos
    assert_equal "40995422300002952955203167100000018030299015", @boleto_novo.codigo_barras
    boleto_com_registro
    assert_equal "4099422300002952950409043001236018030299015", @boleto_novo.monta_codigo_43_digitos
    assert_equal "40997422300002952950409043001236018030299015", @boleto_novo.codigo_barras
    boleto_nil
    assert_equal nil, @boleto_novo.codigo_barras
    assert_raise RuntimeError do
      boleto_nil
      raise 'Verifique as informações do boleto!!!'
    end
  end

  def test_should_mont_correct_linha_digitalvel
    boleto_sem_registro
    assert_equal("40995.20316 67100.000016 80302.990157 5 42230000295295", @boleto_novo.codigo_barras.linha_digitavel)
    boleto_com_registro
    assert_equal("40990.40901 43001.236017 80302.990157 7 42230000295295", @boleto_novo.codigo_barras.linha_digitavel)
  end

end