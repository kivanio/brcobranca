# -*- encoding: utf-8 -*-
#
require 'spec_helper'

RSpec.describe Brcobranca::FormatacaoString do
  context 'no arguments' do
    it { expect { ''.format_size }.to raise_error(ArgumentError) }
  end

  context 'blank' do
    it { expect(' '.format_size(10)).to eq('          ') }
    it { expect(''.format_size(10)).to eq('          ') }
  end

  context 'above size' do
    it { expect('SOCIEDADE BRASILEIRA DE ZOOLOGIA LTDA'.format_size(30)).to eql('SOCIEDADE BRASILEIRA DE ZOOLOG') }
    it { expect('pablo diego JOSÉ FRANCISCO DE PAULA JUAN'.format_size(30)).to eql('pablo diego JOSE FRANCISCO DE ') }
  end

  context 'bellow size' do
    it { expect('SOCIEDADE'.format_size(30)).to eql('SOCIEDADE                     ') }
    it { expect('caçaróla'.format_size(30)).to eql('cacarola                      ') }
  end
end
