require File.join(File.dirname(__FILE__),'test_helper.rb')
require 'tempfile'

class TestRGhost < Test::Unit::TestCase #:nodoc:[all]
  def setup
    @boleto = BancoBrasil.new
    @boleto.cedente = "Kivanio Barbosa"
    @boleto.documento_cedente = "12345678912"
    @boleto.sacado = "Claudio Pozzebom"
    @boleto.sacado_documento = "12345678900"
    @boleto.valor = 11135.00
    @boleto.aceite = "S"
    @boleto.agencia = "4042"
    @boleto.conta_corrente = "61900"
    @boleto.convenio = "1238798"
    @boleto.numero_documento = "7777700168"
    @boleto.dias_vencimento = 5
    @boleto.data_documento = Date.parse("2008-02-01")
    @boleto.instrucao1 = "Pagável na rede bancária até a data de vencimento."
    @boleto.instrucao2 = "Juros de mora de 2.0% mensal(R$ 0,09 ao dia)"
    @boleto.instrucao3 = "DESCONTO DE R$ 29,50 APÓS 05/11/2006 ATÉ 15/11/2006"
    @boleto.instrucao4 = "NÃO RECEBER APÓS 15/11/2006"
    @boleto.instrucao5 = "Após vencimento pagável somente nas agências do Banco do Brasil"
    @boleto.instrucao6 = "ACRESCER R$ 4,00 REFERENTE AO BOLETO BANCÁRIO"
    @boleto.sacado_endereco = "Av. Rubéns de Mendonça, 157 - 78008-000 - Cuiabá/MT"
  end

  def test_gs_presence
    RGhost::Config.config_platform
    assert_equal true, File.exist?(RGhost::Config::GS[:path])
    assert_equal true, File.executable?(RGhost::Config::GS[:path])
    s=`#{RGhost::Config::GS[:path]} -v`
    assert_match(/^GPL Ghostscript 8\.[6-9]/, s)
  end

  def test_outputs
    %w| pdf jpg tif png ps |.each do |format|
      file_body=@boleto.to(format.to_sym)
      tmp_file=Tempfile.new("foobar." << format)
      tmp_file.puts file_body
      tmp_file.close
      assert_equal true, File.exist?(tmp_file.path)
      assert_equal false, File.stat(tmp_file.path).zero?
      assert_equal 1, File.delete(tmp_file.path)
      assert_equal false, File.exist?(tmp_file.path)
    end
  end

end