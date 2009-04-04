require File.join(File.dirname(__FILE__),'test_helper.rb')

class BaseTest < Test::Unit::TestCase #:nodoc:[all]

  def setup
    @boleto = Brcobranca::Boleto::Base.new
  end

  def test_should_initialize_correctly
    assert_equal "DM", @boleto.especie_documento
    assert_equal "R$", @boleto.especie
    assert_equal "9", @boleto.moeda
    assert_equal Date.today, @boleto.data_documento
    assert_equal 1, @boleto.dias_vencimento
    assert_equal((Date.today + 1), @boleto.data_vencimento)
    assert_equal "S", @boleto.aceite
    assert_equal 1, @boleto.quantidade
    assert_equal 0.0, @boleto.valor
    assert_equal 0.0, @boleto.valor_documento
    assert_equal "QUALQUER BANCO ATÉ O VENCIMENTO", @boleto.local_pagamento
  end

  def test_should_calculate_correct_banco_dv
    @boleto.banco = "85068014982"
    assert_equal 9, @boleto.banco_dv
    @boleto.banco = "05009401448"
    assert_equal 1, @boleto.banco_dv
    @boleto.banco = "12387987777700168"
    assert_equal 2, @boleto.banco_dv
    @boleto.banco = "4042"
    assert_equal 8, @boleto.banco_dv
    @boleto.banco = "61900"
    assert_equal 0, @boleto.banco_dv
    @boleto.banco = "0719"
    assert_equal 6, @boleto.banco_dv
    @boleto.banco = 85068014982
    assert_equal 9, @boleto.banco_dv
    @boleto.banco = 5009401448
    assert_equal 1, @boleto.banco_dv
    @boleto.banco = 12387987777700168
    assert_equal 2, @boleto.banco_dv
    @boleto.banco = 4042
    assert_equal 8, @boleto.banco_dv
    @boleto.banco = 61900
    assert_equal 0, @boleto.banco_dv
    @boleto.banco = 719
    assert_equal 6, @boleto.banco_dv
  end

  def test_should_calculate_correct_agencia_dv
    @boleto.agencia = "85068014982"
    assert_equal 9, @boleto.agencia_dv
    @boleto.agencia = "05009401448"
    assert_equal 1, @boleto.agencia_dv
    @boleto.agencia = "12387987777700168"
    assert_equal 2, @boleto.agencia_dv
    @boleto.agencia = "4042"
    assert_equal 8, @boleto.agencia_dv
    @boleto.agencia = "61900"
    assert_equal 0, @boleto.agencia_dv
    @boleto.agencia = "0719"
    assert_equal 6, @boleto.agencia_dv
    @boleto.agencia = 85068014982
    assert_equal 9, @boleto.agencia_dv
    @boleto.agencia = 5009401448
    assert_equal 1, @boleto.agencia_dv
    @boleto.agencia = 12387987777700168
    assert_equal 2, @boleto.agencia_dv
    @boleto.agencia = 4042
    assert_equal 8, @boleto.agencia_dv
    @boleto.agencia = 61900
    assert_equal 0, @boleto.agencia_dv
    @boleto.agencia = 719
    assert_equal 6, @boleto.agencia_dv
  end

  def test_should_calculate_correct_conta_corrente_dv
    @boleto.conta_corrente = "85068014982"
    assert_equal 9, @boleto.conta_corrente_dv
    @boleto.conta_corrente = "05009401448"
    assert_equal 1, @boleto.conta_corrente_dv
    @boleto.conta_corrente = "12387987777700168"
    assert_equal 2, @boleto.conta_corrente_dv
    @boleto.conta_corrente = "4042"
    assert_equal 8, @boleto.conta_corrente_dv
    @boleto.conta_corrente = "61900"
    assert_equal 0, @boleto.conta_corrente_dv
    @boleto.conta_corrente = "0719"
    assert_equal 6, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 85068014982
    assert_equal 9, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 5009401448
    assert_equal 1, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 12387987777700168
    assert_equal 2, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 4042
    assert_equal 8, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 61900
    assert_equal 0, @boleto.conta_corrente_dv
    @boleto.conta_corrente = 719
    assert_equal 6, @boleto.conta_corrente_dv
  end

  def test_should_calculate_correct_nosso_numero_dv
    @boleto.numero_documento = "85068014982"
    assert_equal 9, @boleto.nosso_numero_dv
    @boleto.numero_documento = "05009401448"
    assert_equal 1, @boleto.nosso_numero_dv
    @boleto.numero_documento = "12387987777700168"
    assert_equal 2, @boleto.nosso_numero_dv
    @boleto.numero_documento = "4042"
    assert_equal 8, @boleto.nosso_numero_dv
    @boleto.numero_documento = "61900"
    assert_equal 0, @boleto.nosso_numero_dv
    @boleto.numero_documento = "0719"
    assert_equal 6, @boleto.nosso_numero_dv
    @boleto.numero_documento = 85068014982
    assert_equal 9, @boleto.nosso_numero_dv
    @boleto.numero_documento = 5009401448
    assert_equal 1, @boleto.nosso_numero_dv
    @boleto.numero_documento = 12387987777700168
    assert_equal 2, @boleto.nosso_numero_dv
    @boleto.numero_documento = 4042
    assert_equal 8, @boleto.nosso_numero_dv
    @boleto.numero_documento = 61900
    assert_equal 0, @boleto.nosso_numero_dv
    @boleto.numero_documento = 719
    assert_equal 6, @boleto.nosso_numero_dv
  end

  def test_should_return_correct_valor_documento
    @boleto.quantidade = 1
    @boleto.valor = 1
    assert_equal 1, @boleto.valor_documento
    @boleto.quantidade = 1
    @boleto.valor = 1.0
    assert_equal 1.0, @boleto.valor_documento
    @boleto.quantidade = 1
    @boleto.valor = 1.2
    assert_equal 1.2, @boleto.valor_documento
    @boleto.quantidade = 100
    @boleto.valor = 1
    assert_equal 100, @boleto.valor_documento
    @boleto.quantidade = 1
    @boleto.valor = 135.43
    assert_equal 135.43, @boleto.valor_documento
  end

  def test_should_return_correct_data_vencimento
    @boleto.data_documento = Date.parse "2008-02-01"
    @boleto.dias_vencimento = 1
    assert_equal "2008-02-02", @boleto.data_vencimento.to_s
    @boleto.data_documento = Date.parse "2008-02-02"
    @boleto.dias_vencimento = 28
    assert_equal "2008-03-01", @boleto.data_vencimento.to_s
    @boleto.data_documento = Date.parse "2008-02-06"
    @boleto.dias_vencimento = 100
    assert_equal "2008-05-16", @boleto.data_vencimento.to_s
    assert_equal Date.parse("2008-05-16"), @boleto.data_vencimento
  end

end
