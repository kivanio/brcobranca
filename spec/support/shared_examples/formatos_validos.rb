# frozen_string_literal: true

shared_examples_for 'formatos_validos' do
  it 'válido com método to_' do
    @valid_attributes[:data_vencimento] = Date.parse('2009/08/14')
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.send(:"to_#{format}")
      tmp_file = Tempfile.new("foobar.#{format}")
      tmp_file.puts file_body
      tmp_file.close
      expect(File).to exist(tmp_file.path)
      expect(File.stat(tmp_file.path)).not_to be_zero
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File).not_to exist(tmp_file.path)
    end
  end

  it 'válido' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    @valid_attributes[:data_vencimento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new("foobar.#{format}")
      tmp_file.puts file_body
      tmp_file.close
      expect(File).to exist(tmp_file.path)
      expect(File.stat(tmp_file.path)).not_to be_zero
      expect(File.delete(tmp_file.path)).to be(1)
      expect(File).not_to exist(tmp_file.path)
    end
  end
end
