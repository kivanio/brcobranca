Gem para emissão de bloquetos de cobrança para bancos brasileiros.

[![Gem Version](http://img.shields.io/gem/v/brcobranca.svg)][gem]
[![Build Status](http://img.shields.io/travis/kivanio/brcobranca.svg)][travis]
[![Dependency Status](http://img.shields.io/gemnasium/kivanio/brcobranca.svg)][gemnasium]
[![Code Climate](http://img.shields.io/codeclimate/github/kivanio/brcobranca.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/kivanio/brcobranca/badges/coverage.svg)](https://codeclimate.com/github/kivanio/brcobranca/coverage)
[![Coverage Status](https://coveralls.io/repos/kivanio/brcobranca/badge.svg)](https://coveralls.io/r/kivanio/brcobranca)

[gem]: https://rubygems.org/gems/brcobranca
[travis]: http://travis-ci.org/kivanio/brcobranca
[gemnasium]: https://gemnasium.com/kivanio/brcobranca
[codeclimate]: https://codeclimate.com/github/kivanio/brcobranca
[coveralls]: https://coveralls.io/r/kivanio/brcobranca

### Exemplos

- https://brcobranca.herokuapp.com
- http://github.com/kivanio/brcobranca_exemplo
- https://github.com/thiagoc7/brcobranca_app

### Bancos Disponíveis

| Bancos                | Carteiras         | Documentações  |
|-----------------------|-------------------|----------------|
| 001 - Banco do Brasil | Todas as carteiras presentes na documentação | [pdf](http://www.bb.com.br/docs/pub/emp/empl/dwn/Doc5175Bloqueto.pdf) |
| 021 - Banestes        | Todas as carteiras presentes na documentação  | | 
| 033 - Santander       | Todas as carteiras presentes na documentação - [Ronaldo Araujo](https://github.com/ronaldoaraujo) | [pdf](http://177.69.143.161:81/Treinamento/SisMoura/Documentação%20Boleto%20Remessa/Documentacao_SANTANDER/Layout%20de%20Cobrança%20-%20Código%20de%20Barras%20Santander%20Setembro%202012%20v%202%203.pdf) |
| 104 - Caixa           | Todas as carteiras presentes na documentação - [Túlio Ornelas](https://github.com/tulios) | [pdf](http://downloads.caixa.gov.br/_arquivos/cobranca_caixa_sigcb/manuais/CODIGO_BARRAS_SIGCB.PDF) |
| 237 - Bradesco        | Todas as carteiras presentes na documentação | [pdf](http://www.bradesco.com.br/portal/PDF/pessoajuridica/solucoes-integradas/outros/layout-de-arquivo/cobranca/4008-524-0121-08-layout-cobranca-versao-portugues.pdf) |
| 341 - Itaú            | Todas as carteiras presentes na documentação | [CNAB240](http://download.itau.com.br/bankline/cobranca_cnab240.pdf), [CNAB400](http://download.itau.com.br/bankline/layout_cobranca_400bytes_cnab_itau_mensagem.pdf) |
| 399 - HSBC            | CNR, CSB - [Rafael DL](https://github.com/rafaeldl) |                |
| 748 - Sicredi         | C (03)            |                |
| 756 - Sicoob          | Todas as carteiras presentes na documentação |                |

### Retornos Disponíveis

* CBR643
* CNAB240
* CNAB400

Para CNABs do tipo 240 indico usar a gem [cnab240](https://github.com/eduardordm/cnab240) que é muito completa.

### Remessas Disponíveis

* Banco do Brasil (CNAB240) [Isabella](https://github.com/isabellaSantos) da [Zaez](http://www.zaez.net)
* Caixa Economica Federal (CNAB240) [Isabella](https://github.com/isabellaSantos) da [Zaez](http://www.zaez.net)
* Bradesco (CNAB400) [Isabella](https://github.com/isabellaSantos) da [Zaez](http://www.zaez.net)
* Itaú (CNAB400) [Isabella](https://github.com/isabellaSantos) da [Zaez](http://www.zaez.net)
* Citibank (CNAB400)
* Santander (CNAB400)

### Documentação

Caso queira verificar(ou adicionar) alguma documentação, acesse [nosso wiki](https://github.com/kivanio/brcobranca/wiki).

### Rubydoc

- [versão estável](http://rubydoc.info/gems/brcobranca)
- [versão de desenvolvimento](http://rubydoc.info/github/kivanio/brcobranca/master/frames)

### Apoio

[![RubyMine](http://www.jetbrains.com/ruby/features/ruby_banners/ruby1/ruby468x60_rubin.gif)](http://www.jetbrains.com/ruby/features?utm_source=RubyMineUser&utm_medium=Banner&utm_campaign=RubyMine)

[Boleto Simples](https://wwww.boletosimples.com.br)

### Licença

* BSD
