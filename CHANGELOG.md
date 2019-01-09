# Change Log

## [v9.2.3](https://github.com/kivanio/brcobranca/tree/v9.2.3) (18-12-2018)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.2.2...v9.2.3)

**Closed issues:**

- Geração de Arquivos de remessa [\#199](https://github.com/kivanio/brcobranca/issues/199)
- numero\_documento e nosso\_numero Diferentes [\#196](https://github.com/kivanio/brcobranca/issues/196)

**Merged pull requests:**

- Ajustes na função de formatar string para campo de remessa [\#203](https://github.com/kivanio/brcobranca/pull/203) ([escobera](https://github.com/escobera))

## [v9.2.2](https://github.com/kivanio/brcobranca/tree/v9.2.2) (25-06-2018)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.2.1...v9.2.2)

## [v9.2.1](https://github.com/kivanio/brcobranca/tree/v9.2.1) (21-06-2018)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.2.0...v9.2.1)

## [v9.2.0](https://github.com/kivanio/brcobranca/tree/v9.2.0) (11-06-2018)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.1.2...v9.2.0)

**Closed issues:**

- Remessa para atualização de campos [\#186](https://github.com/kivanio/brcobranca/issues/186)

## [v9.1.2](https://github.com/kivanio/brcobranca/tree/v9.1.2) (18-12-2017)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.1.1...v9.1.2)

**Merged pull requests:**

- Ajusta a resolução das logos do Cecred e do Credisis [\#184](https://github.com/kivanio/brcobranca/pull/184) ([marceloboth](https://github.com/marceloboth))

## [v9.1.1](https://github.com/kivanio/brcobranca/tree/v9.1.1) (13-12-2017)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.1.0...v9.1.1)

## [v9.1.0](https://github.com/kivanio/brcobranca/tree/v9.1.0) (13-12-2017)
[Full Changelog](https://github.com/kivanio/brcobranca/compare/v9.0.0...v9.1.0)

**Closed issues:**

- Erro ao ler campo nosso\_numero do arquivo de retorno Bradesco. [\#183](https://github.com/kivanio/brcobranca/issues/183)
- onde colocar o arquivo que foi alterado? [\#168](https://github.com/kivanio/brcobranca/issues/168)
- Remessa e retorno 240 do Sicoob não estão utilizando o DV no nosso número [\#164](https://github.com/kivanio/brcobranca/issues/164)
- Linhas lidas em retorno [\#161](https://github.com/kivanio/brcobranca/issues/161)
- Juros de mora na remessa para CNAB240 não está implementado [\#159](https://github.com/kivanio/brcobranca/issues/159)
- Gem não faz o parse de Código de Movimento Retorno e Motivo da Ocorrência para CNAB 240 [\#158](https://github.com/kivanio/brcobranca/issues/158)
- Linhas em branco quando gerado remessa pelo Mac + Chrome [\#157](https://github.com/kivanio/brcobranca/issues/157)
- Remessa Caixa - CNAB240 [\#156](https://github.com/kivanio/brcobranca/issues/156)
- boleto caixa - convenio [\#154](https://github.com/kivanio/brcobranca/issues/154)
- protesto e baixa automática [\#152](https://github.com/kivanio/brcobranca/issues/152)
- Remessa Sicredi [\#143](https://github.com/kivanio/brcobranca/issues/143)
- Ajuda com Arquivo de Retorno Sicoob [\#137](https://github.com/kivanio/brcobranca/issues/137)
- Boleto Caixa [\#135](https://github.com/kivanio/brcobranca/issues/135)
- Número do documento [\#117](https://github.com/kivanio/brcobranca/issues/117)
- remover monkeypatchs [\#73](https://github.com/kivanio/brcobranca/issues/73)
- permitir usar prawn [\#58](https://github.com/kivanio/brcobranca/issues/58)
- Exportar pra HTML [\#6](https://github.com/kivanio/brcobranca/issues/6)

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

\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*