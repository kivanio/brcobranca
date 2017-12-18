## v9.0.0

- Removida dependência do ActiveModel
- Renomeado `numero_documento` para `nosso_numero`
- Renomeado `cod_de_ocorrencia` para `codigo_ocorrencia`
- Renomeado `data_de_ocorrencia` para `data_ocorrencia`

## v8.0.0

- Corrige erro no cálculo do fator de vencimento
- Boleto da Caixa passa a ser no formato registrado por padrão.

## v7.0.0
- Adicionado Banrisul
- Rubocop styles

## v6.1.0
- Adicionado Banestes
- Limpeza e formatação de strings de acordo com o tamanho permitido por cada banco
- Homologação de cnab240 do Banco do Brazil

## v6.0.0

- Extraído campo data_vencimento que passa a receber a data de vencimento
- Removido campo dias_vencimento que era usado para calculo automático de data de vencimento
- Correçao do cálculo do dígito do nosso número do SICOOB

## v3.1.2 13-02-2013

* Adicionado suporte ao valor da tarifa no arquivo retorno CNAB240 by Felipe Munhoz

## v3.1.1 08-09-2012

* adicionado boletos do Santader by Ronaldo Araujo

## v3.0.0 14-04-2011

* Múltiplos boletos em lote com RGhost
* Validações
* Incluindo boleto para CAIXA by Túlio Ornelas
* Removendo BANESPA que virou Santander

## v2.0.7 14-05-2010

* Resolução de imagens com maior qualidade - Anderson Dias
* Correção do campo de exibição agencia/conta no boleto do Itáu (Solicitado pelo banco em homologação) - Antonio Carlos

## v2.0.6 16-08-2009

* Incluindo boleto para banco Santander Banespa - Diego Lucena

## v2.0.4 04-05-2009

* Solucionado problemas com refatoração do retorno.

## v2.0.3 25-04-2009

* Incluindo boleto para o banco Bradesco(Todas as Carteiras)
* Incluindo boleto para o banco UNIBANCO(com e sem registro)

## v2.0.2 21-04-2009

* Incluindo boleto para o banco Real(com e sem registro)

## v2.0.1 19-04-2009

* Ajustes finais para lançamento

## v2.0.0 06-04-2009

* 1 acts_as_payment torna-se brcobranca: Release inicial com versão em 2.0.0