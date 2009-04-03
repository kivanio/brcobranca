require File.join(File.dirname(__FILE__),'test_helper.rb')

class RetornoCbr643Test < Test::Unit::TestCase #:nodoc:[all]

  def test_should_correct_return_retorno
    @pagamentos = Brcobranca::Retorno::Cbr643.load_lines(File.join(File.dirname(__FILE__),'arquivos','CBR64310.RET'))
    assert_equal("000002", @pagamentos.first.sequencial)
    assert_equal("33521", @pagamentos.first.agencia_com_dv)
    assert_equal("000141473", @pagamentos.first.cedente_com_dv)
    assert_equal("1123725", @pagamentos.first.convenio)
    assert_equal("080708", @pagamentos.first.data_liquidacao)
    assert_equal("100708", @pagamentos.first.data_credito)
    assert_equal("0000000108461", @pagamentos.first.valor_recebido)
    assert_equal("11237250000047565", @pagamentos.first.nosso_numero)
  end

end