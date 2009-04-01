require File.dirname(__FILE__) + File::SEPARATOR + 'test_helper.rb'

class RetornoCbr643Test < Test::Unit::TestCase

  def test_should_correct_return_retorno
    @pagamentos = Brcobranca::Boleto::RetornoCbr643.new(File.join(File.dirname(__FILE__), '..','tasks','data_test','CBR64310.RET'))    
    assert_equal("000002", @pagamentos.retorno.first[:sequencial])
    assert_equal("33521", @pagamentos.retorno.first[:agencia_com_dv])
    assert_equal("000141473", @pagamentos.retorno.first[:cedente_com_dv])
    assert_equal("1123725", @pagamentos.retorno.first[:convenio])
    assert_equal("080708", @pagamentos.retorno.first[:data_liquidacao])
    assert_equal("100708", @pagamentos.retorno.first[:data_credito])
    assert_equal("0000000108461", @pagamentos.retorno.first[:valor_recebido])
    assert_equal("11237250000047565", @pagamentos.retorno.first[:nosso_numero])
  end

  def test_should_return_excpetion_on_initialize
    assert_raise ArgumentError do
      @pagamentos = Brcobranca::Boleto::RetornoCbr643.new
      raise 'Arquivo não encontrado'
    end
  end

  def test_should_return_excpetion_file_not_found
    assert_raise RuntimeError do
      @pagamentos = Brcobranca::Boleto::RetornoCbr643.new("nao_existe.txt")
      raise 'Arquivo não encontrado'
    end
  end

end