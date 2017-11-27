# Changelog

- Renomeado `cod_de_ocorrencia` para `codigo_ocorrencia`
- Renomeado `data_de_ocorrencia` para `data_ocorrencia`

## 8.0.0

- Corrige erro no cálculo do fator de vencimento
- Boleto da Caixa passa a ser no formato registrado por padrão.

## 7.0.0
- Adicionado Banrisul
- Rubocop styles

## 6.1.0
- Adicionado Banestes
- Limpeza e formatação de strings de acordo com o tamanho permitido por cada banco
- Homologação de cnab240 do Banco do Brazil

## 6.0.0

- Extraído campo data_vencimento que passa a receber a data de vencimento
- Removido campo dias_vencimento que era usado para calculo automático de data de vencimento
- Correçao do cálculo do dígito do nosso número do SICOOB
