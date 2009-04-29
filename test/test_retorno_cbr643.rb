require File.join(File.dirname(__FILE__),'test_helper.rb')

class TestRetornoCbr643 < Test::Unit::TestCase #:nodoc:[all]

  def test_should_correct_return_retorno
    @pagamentos = RetornoCbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'))
    assert_equal("000001", @pagamentos.first.sequencial)
    assert_equal("CA", @pagamentos.first.agencia_com_dv)
    assert_equal("33251", @pagamentos.first.cedente_com_dv)
    assert_equal("0002893", @pagamentos.first.convenio)
    assert_equal("", @pagamentos.first.data_liquidacao)
    assert_equal("", @pagamentos.first.data_credito)
    assert_equal("", @pagamentos.first.valor_recebido)
    assert_equal("OSSENSE DO AL001B", @pagamentos.first.nosso_numero)
  end


  def test_should_correct_return_retorno_except
    @pagamentos = RetornoCbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'),{:except => [1]})
    assert_equal("000002", @pagamentos.first.sequencial)
    assert_equal("33251", @pagamentos.first.agencia_com_dv)
    assert_equal("000289353", @pagamentos.first.cedente_com_dv)
    assert_equal("1622420", @pagamentos.first.convenio)
    assert_equal("200109", @pagamentos.first.data_liquidacao)
    assert_equal("220109", @pagamentos.first.data_credito)
    assert_equal("0000000009064", @pagamentos.first.valor_recebido)
    assert_equal("16224200000000003", @pagamentos.first.nosso_numero)
  end
  
  def test_should_correct_return_retorno_except_length
    @pagamentos = RetornoCbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'),{:except => [1], :length => 400})
    assert_equal("000002", @pagamentos.first.sequencial)
    assert_equal("33251", @pagamentos.first.agencia_com_dv)
    assert_equal("000289353", @pagamentos.first.cedente_com_dv)
    assert_equal("1622420", @pagamentos.first.convenio)
    assert_equal("200109", @pagamentos.first.data_liquidacao)
    assert_equal("220109", @pagamentos.first.data_credito)
    assert_equal("0000000009064", @pagamentos.first.valor_recebido)
    assert_equal("16224200000000003", @pagamentos.first.nosso_numero)
  end
  
  def test_should_correct_return_retorno_except_regex
    @pagamentos = RetornoCbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'),{:except => /^[^7]/})
    assert_equal("000002", @pagamentos.first.sequencial)
    assert_equal("33251", @pagamentos.first.agencia_com_dv)
    assert_equal("000289353", @pagamentos.first.cedente_com_dv)
    assert_equal("1622420", @pagamentos.first.convenio)
    assert_equal("200109", @pagamentos.first.data_liquidacao)
    assert_equal("220109", @pagamentos.first.data_credito)
    assert_equal("0000000009064", @pagamentos.first.valor_recebido)
    assert_equal("16224200000000003", @pagamentos.first.nosso_numero)
  end
  
  def test_should_correct_return_retorno_except_regex_length
    @pagamentos = RetornoCbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'),{:except => /^[^7]/, :length => 400})
    assert_equal("000002", @pagamentos.first.sequencial)
    assert_equal("33251", @pagamentos.first.agencia_com_dv)
    assert_equal("000289353", @pagamentos.first.cedente_com_dv)
    assert_equal("1622420", @pagamentos.first.convenio)
    assert_equal("200109", @pagamentos.first.data_liquidacao)
    assert_equal("220109", @pagamentos.first.data_credito)
    assert_equal("0000000009064", @pagamentos.first.valor_recebido)
    assert_equal("16224200000000003", @pagamentos.first.nosso_numero)
  end

end