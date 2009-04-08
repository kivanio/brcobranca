require File.join(File.dirname(__FILE__),'test_helper.rb')

class BancoHsbcTest < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto_novo = BancoHsbc.new(:data_documento => Date.parse("2008-02-01"))
    @boleto_novo.cedente = "Kivanio Barbosa"
    @boleto_novo.documento_cedente = "12345678912"
    @boleto_novo.sacado = "Claudio Pozzebom"
    @boleto_novo.sacado_documento = "12345678900"
    @boleto_novo.aceite = "S"
    @boleto_novo.agencia = "4042"
    @boleto_novo.valor = 2952.95
  end

  def test_should_initialize_correctly
    assert_equal '399', @boleto_novo.banco
    assert_equal "DM", @boleto_novo.especie_documento
    assert_equal "R$", @boleto_novo.especie
    assert_equal "9", @boleto_novo.moeda
    assert_equal Date.parse("2008-02-01"), @boleto_novo.data_documento
    assert_equal 1, @boleto_novo.dias_vencimento
    assert_equal((@boleto_novo.data_documento + 1), @boleto_novo.data_vencimento)
    assert_equal "S", @boleto_novo.aceite
    assert_equal 1, @boleto_novo.quantidade
    assert_equal 2952.95, @boleto_novo.valor
    assert_equal 2952.95, @boleto_novo.valor_documento
    assert_equal "QUALQUER BANCO ATÉ O VENCIMENTO", @boleto_novo.local_pagamento
  end
  
  def test_should_return_correct_nosso_numero
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2000-07-04")
    assert_equal "12345678942", @boleto_novo.nosso_numero
    @boleto_novo.conta_corrente = "351202"
    @boleto_novo.numero_documento = "39104766"
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.data_documento = Date.parse("2000-07-04")
    assert_equal "39104766340", @boleto_novo.nosso_numero
    @boleto_novo.conta_corrente = "351202"
    @boleto_novo.numero_documento = "39104766"
    @boleto_novo.dias_vencimento = 0
    @boleto_novo.data_documento = ""
    assert_equal "39104766354", @boleto_novo.nosso_numero
  end

  def test_should_mont_correct_codigo_barras
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2009-04-03")
    assert_equal "3999420100002952951122334000001234567809892", @boleto_novo.monta_codigo_43_digitos
    assert_equal "39998420100002952951122334000001234567809892", @boleto_novo.codigo_barras
  end

  def test_should_mont_correct_linha_digitalvel
    @boleto_novo.conta_corrente = "1122334"
    @boleto_novo.numero_documento = "12345678"
    @boleto_novo.dias_vencimento = 5
    @boleto_novo.data_documento = Date.parse("2009-04-03")
    assert_equal("39991.12232 34000.001239 45678.098927 8 42010000295295", @boleto_novo.codigo_barras.linha_digitavel)
  end

end