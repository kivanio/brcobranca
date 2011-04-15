# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "RGhost" do

  before(:each) do
    @valid_attributes = {
      :especie_documento => "DM",
      :moeda => "9",
      :data_documento => Date.today,
      :dias_vencimento => 1,
      :aceite => "S",
      :quantidade => 1,
      :valor => 0.0,
      :local_pagamento => "QUALQUER BANCO ATÉ O VENCIMENTO",
      :cedente => "Kivanio Barbosa",
      :documento_cedente => "12345678912",
      :sacado => "Claudio Pozzebom",
      :sacado_documento => "12345678900",
      :agencia => "4042",
      :conta_corrente => "61900",
      :convenio => 12387989,
      :numero_documento => "777700168"
    }
  end

  it "Testar se RGhost está instalado" do
    # RGhost::Config.config_platform
    File.exist?(RGhost::Config::GS[:path]).should be_true
    File.executable?(RGhost::Config::GS[:path]).should be_true
    s=`#{RGhost::Config::GS[:path]} -v`
    s.should =~ /^GPL Ghostscript/
    s=`#{RGhost::Config::GS[:path]} --version`
    s.should =~ /[8-9]\.[0-9]/
  end

end