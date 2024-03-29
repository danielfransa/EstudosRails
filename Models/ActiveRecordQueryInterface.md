# Active Record Query Interface

## O que é a interface de consulta de registro ativo? (Active Record Query Interface)

Se você está acostumado a usar SQL bruto para encontrar registros de banco de dados, geralmente descobrirá que existem maneiras melhores de realizar as mesmas operações no Rails. O Active Record isola você da necessidade de usar SQL na maioria dos casos.

O Active Record realizará consultas no banco de dados para você e é compatível com a maioria dos sistemas de banco de dados, incluindo MySQL, MariaDB, PostgreSQL e SQLite. Independentemente do sistema de banco de dados que você estiver usando, o formato do método Active Record será sempre o mesmo.

Os exemplos de código ao longo deste guia se referirão a um ou mais dos seguintes modelos:

![Active Record Query Interface](/imagens/active_record_query_interface1.JPG)

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```
```ruby
class Book < ApplicationRecord
  belongs_to :supplier
  belongs_to :author
  has_many :reviews
  has_and_belongs_to_many :orders, join_table: 'books_orders'

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
  scope :out_of_print_and_expensive, -> { out_of_print.where('price > 500') }
  scope :costs_more_than, ->(amount) { where('price > ?', amount) }
end
```
```ruby
class Customer < ApplicationRecord
  has_many :orders
  has_many :reviews
end
```
```ruby
class Order < ApplicationRecord
  belongs_to :customer
  has_and_belongs_to_many :books, join_table: 'books_orders'

  enum :status, [:shipped, :being_packed, :complete, :cancelled]

  scope :created_before, ->(time) { where(created_at: ...time) }
end
```
```ruby
class Review < ApplicationRecord
  belongs_to :customer
  belongs_to :book

  enum :state, [:not_reviewed, :published, :hidden]
end
```
```ruby
class Supplier < ApplicationRecord
  has_many :books
  has_many :authors, through: :books
end
```

![Active Record Query Interface - bookstore example](/imagens/active_record_query_interface2.JPG)


## Recuperando Objetos do Banco de Dados

Para recuperar objetos do banco de dados, o Active Record fornece vários métodos de localização. Cada método localizador permite que você passe argumentos para realizar determinadas consultas em seu banco de dados sem escrever SQL bruto.

Os métodos são:

- `annotate`
- `find`
- `create_with`
- `distinct`
- `eager_load`
- `extending`
- `extract_associated`
- `from`
- `group`
- `having`
- `includes`
- `joins`
- `left_outer_joins`
- `limit`
- `lock`
- `none`
- `offset`
- `optimizer_hints`
- `order`
- `preload`
- `readonly`
- `references`
- `reorder`
- `reselect`
- `regroup`
- `reverse_order`
- `select`
- `where`

Os métodos do Finder que retornam uma coleção, como `where` e `group`, retornam uma instância de `ActiveRecord::Relation`. Métodos que encontram uma única entidade, como `find` e `first`, retornam uma única instância do modelo.

A operação primária de `Model.find(options)` pode ser resumida como:

- Converta as opções fornecidas em uma consulta SQL equivalente.
- Dispare a consulta SQL e recupere os resultados correspondentes do banco de dados.
- Instancie o objeto Ruby equivalente do modelo apropriado para cada linha resultante.
- Execute `after_find` e depois retornos de chamada `after_initialize`, se houver.


### Recuperando um Único Objeto

O Active Record fornece diversas maneiras diferentes de recuperar um único objeto.

#### find

Usando o método `find`, você pode recuperar o objeto correspondente à chave primária especificada que corresponde a qualquer opção fornecida. Por exemplo:

```bash
# Find the customer with primary key (id) 10.
irb> customer = Customer.find(10)
=> #<Customer id: 10, first_name: "Ryan">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers WHERE (customers.id = 10) LIMIT 1
```

O método `find` gerará uma exceção `ActiveRecord::RecordNotFound`  se nenhum registro correspondente for encontrado.

Você também pode usar esse método para consultar vários objetos. Chame o método `find` e passe uma matriz de chaves primárias. O retorno será um array contendo todos os registros correspondentes às chaves primárias fornecidas . Por exemplo:

```bash
# Find the customers with primary keys 1 and 10.
irb> customers = Customer.find([1, 10]) # OR Customer.find(1, 10)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 10, first_name: "Ryan">]
```

O equivalente SQL do acima é:

![Active Record Query Interface - find](/imagens/active_record_query_interface3.JPG)

Se sua tabela usar uma chave primária composta, você precisará passar um array `find`  para encontrar um único item. Por exemplo, se os clientes foram definidos [:store_id, :id]como chave primária:

```bash
# Find the customer with store_id 3 and id 17
irb> customers = Customer.find([3, 17])
=> #<Customer store_id: 3, id: 17, first_name: "Magda">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers WHERE store_id = 3 AND id = 17
```

Para encontrar vários clientes com IDs compostos, você passaria uma matriz de matrizes:

```bash
# Find the customers with primary keys [1, 8] and [7, 15].
irb> customers = Customer.find([[1, 8], [7, 15]]) # OR Customer.find([1, 8], [7, 15])
=> [#<Customer store_id: 1, id: 8, first_name: "Pat">, #<Customer store_id: 7, id: 15, first_name: "Chris">]
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers WHERE (store_id = 1 AND id = 8 OR store_id = 7 AND id = 15)
```

#### take

O método `take` recupera um registro sem qualquer ordem implícita. Por exemplo:

```bash
irb> customer = Customer.take
=> #<Customer id: 1, first_name: "Lifo">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers LIMIT 1
```

O método `take` retorna `nil` se nenhum registro for encontrado e nenhuma exceção for gerada.

Você pode passar um argumento numérico para o método `take` para retornar até esse número de resultados. Por exemplo

```bash
irb> customers = Customer.take(2)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 220, first_name: "Sara">]
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers LIMIT 2
```

O método `take!` se comporta exatamente como take, exceto que será gerado `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.

![Active Record Query Interface - take](/imagens/active_record_query_interface4.JPG)


#### first
O método first encontra o primeiro registro ordenado por chave primária (padrão). Por exemplo:

```bash
irb> customer = Customer.first
=> #<Customer id: 1, first_name: "Lifo">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 1
```

O método `first` retorna `nil` se nenhum registro correspondente for encontrado e nenhuma exceção for gerada.

Se o seu escopo padrão contiver um método order, `first` retornará o primeiro registro de acordo com esta ordenação.

Você pode passar um argumento numérico para o método `first` para retornar até esse número de resultados. Por exemplo

```bash
irb> customers = Customer.first(3)
=> [#<Customer id: 1, first_name: "Lifo">, #<Customer id: 2, first_name: "Fifo">, #<Customer id: 3, first_name: "Filo">]
```
O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.id ASC LIMIT 3
```

Os modelos com chaves primárias compostas usarão a chave primária composta completa para ordenação. Por exemplo, se os clientes foram definidos `[:store_id, :id]` como chave primária:

```bash
irb> customer = Customer.first
=> #<Customer id: 2, store_id: 1, first_name: "Lifo">
```
O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.store_id ASC, customers.id ASC LIMIT 1
```

Em uma coleção ordenada usando order, `first` retornará o primeiro registro ordenado pelo atributo especificado para order.

```bash
irb> customer = Customer.order(:first_name).first
=> #<Customer id: 2, first_name: "Fifo">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.first_name ASC LIMIT 1
```

O método `first!` se comporta exatamente como first, exceto que será gerado `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.

#### last
O método `last` encontra o último registro ordenado por chave primária (padrão). Por exemplo:

```bash
irb> customer = Customer.last
=> #<Customer id: 221, first_name: "Russel">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 1
```

O método `last` retorna `nil` se nenhum registro correspondente for encontrado e nenhuma exceção for gerada.

Os modelos com chaves primárias compostas usarão a chave primária composta completa para ordenação. Por exemplo, se os clientes foram definidos `[:store_id, :id]` como chave primária:

```bash
irb> customer = Customer.last
=> #<Customer id: 221, store_id: 1, first_name: "Lifo">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.store_id DESC, customers.id DESC LIMIT 1
```

Se o seu escopo padrão contiver um método order, `last` retornará o último registro de acordo com esta ordenação.

Você pode passar um argumento numérico para o método `last` para retornar até esse número de resultados. Por exemplo

```bash
irb> customers = Customer.last(3)
=> [#<Customer id: 219, first_name: "James">, #<Customer id: 220, first_name: "Sara">, #<Customer id: 221, first_name: "Russel">]
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.id DESC LIMIT 3
```

Em uma coleção ordenada usando order, `last` retornará o último registro ordenado pelo atributo especificado para order.

```bash
irb> customer = Customer.order(:first_name).last
=> #<Customer id: 220, first_name: "Sara">
```

O equivalente SQL do acima é:

```sql
SELECT * FROM customers ORDER BY customers.first_name DESC LIMIT 1
```

O método `last!` se comporta exatamente como `last`, exceto que será gerado `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.


#### find_by

O método `find_by` encontra o primeiro registro que corresponde a algumas condições. Por exemplo:

```bash
irb> Customer.find_by first_name: 'Lifo'
=> #<Customer id: 1, first_name: "Lifo">

irb> Customer.find_by first_name: 'Jon'
=> nil
```

É equivalente a escrever:

```ruby
Customer.where(first_name: 'Lifo').take
```
O equivalente SQL do acima é:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Lifo') LIMIT 1
```

Observe que não há nenhum `ORDER BY` no SQL acima. Se suas condições `find_by` corresponderem a vários registros, você deverá aplicar um pedido para garantir um resultado determinístico.

O método `find_by!` se comporta exatamente como `find_by`, exceto que será gerado `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado. Por exemplo:

```bash
irb> Customer.find_by! first_name: 'does not exist'
ActiveRecord::RecordNotFound
```

Isso equivale a escrever:

```ruby
Customer.where(first_name: 'does not exist').take!
```

##### Condições com:id

Ao especificar condições em métodos como `find_by` e `where`, o uso de `id` corresponderá a um atributo `:id` no modelo. Isso é diferente de find, onde o ID transmitido deve ser um valor de chave primária.

Tenha cuidado ao usar `find_by(id:)` modelos onde `:id` não é a chave primária, como modelos de chave primária composta. Por exemplo, se os clientes foram definidos `[:store_id, :id]` como chave primária:

```bash
irb> customer = Customer.last
=> #<Customer id: 10, store_id: 5, first_name: "Joe">
irb> Customer.find_by(id: customer.id) # Customer.find_by(id: [5, 10])
=> #<Customer id: 5, store_id: 3, first_name: "Bob">
```

Aqui, podemos pretender procurar um único registro com a chave primária composta [5, 10], mas o Active Record procurará um registro com uma coluna `:id` de 5 ou 10 e poderá retornar o registro errado.

![Active Record Query Interface - find_by - condições com id](/imagens/active_record_query_interface5.JPG)

```bash
irb> customer = Customer.last
=> #<Customer id: 10, store_id: 5, first_name: "Joe">
irb> Customer.find_by(id: customer.id_value) # Customer.find_by(id: 10)
=> #<Customer id: 10, store_id: 5, first_name: "Joe">
```

### Recuperando Vários Objetos em Lotes

Muitas vezes precisamos iterar um grande conjunto de registros, como quando enviamos um boletim informativo para um grande conjunto de clientes ou quando exportamos dados.

Isso pode parecer simples:

```bash
# This may consume too much memory if the table is big.
Customer.all.each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Mas essa abordagem se torna cada vez mais impraticável à medida que o tamanho da tabela aumenta, pois `Customer.all.each` instrui o Active Record a buscar a tabela inteira em uma única passagem, construir um objeto modelo por linha e, em seguida, manter todo o array de objetos modelo na memória. Na verdade, se tivermos um grande número de registros, toda a coleção poderá exceder a quantidade de memória disponível.

Rails fornece dois métodos que resolvem esse problema, dividindo os registros em lotes de memória amigável para processamento. O primeiro método, `find_each` recupera um lote de registros e então entrega cada registro ao bloco individualmente como um modelo. O segundo método, `find_in_batches` recupera um lote de registros e depois entrega o lote inteiro ao bloco como uma matriz de modelos.

![Active Record Query Interface - find_by - condições com id](/imagens/active_record_query_interface6.JPG)


#### find_each

O método `find_each` recupera registros em lotes e depois entrega cada um deles ao bloco. No exemplo a seguir, `find_each` recupera clientes em lotes de 1.000 e os entrega ao bloco um por um:

```ruby
Customer.find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Este processo é repetido, buscando mais lotes conforme necessário, até que todos os registros tenham sido processados.

`find_each` trabalha em classes de modelos, como visto acima, e também em relações:

```ruby
Customer.where(weekly_subscriber: true).find_each do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

desde que não tenham ordem, pois o método precisa forçar uma ordem internamente para iterar.

Se uma ordem estiver presente no receptor, o comportamento depende da bandeira `config.active_record.error_on_ignored_order`. Se verdadeiro, `ArgumentError` é gerado, caso contrário a ordem é ignorada e um aviso é emitido, que é o padrão. Isso pode ser substituído pela opção `:error_on_ignore` explicada abaixo.

##### Opções para `find_each`
`:batch_size`

A opção `:batch_size` permite especificar a quantidade de registros a serem recuperados em cada lote, antes de serem passados ​​individualmente para o bloco. Por exemplo, para recuperar registros em lotes de 5.000:

```ruby
Customer.find_each(batch_size: 5000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

`:start`

Por padrão, os registros são buscados em ordem crescente da chave primária. A opção `:start` permite configurar o primeiro ID da sequência sempre que o ID mais baixo não for o que você precisa. Isto seria útil, por exemplo, se você quisesse retomar um processo em lote interrompido, desde que salvasse o último ID processado como um ponto de verificação.

Por exemplo, para enviar newsletters apenas para clientes com chave primária a partir de 2000:

```ruby
Customer.find_each(start: 2000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

`:finish`

Semelhante à opção `:start`, `:finish` permite configurar o último ID da sequência sempre que o ID mais alto não for o que você precisa. Isso seria útil, por exemplo, se você quisesse executar um processo em lote usando um subconjunto de registros baseado em `:starte` `:finish`.

Por exemplo, para enviar newsletters apenas para clientes com chave primária de 2.000 a 10.000:

```ruby
Customer.find_each(start: 2000, finish: 10000) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```

Outro exemplo seria se você quisesse vários trabalhadores lidando com a mesma fila de processamento. Você poderia fazer com que cada trabalhador lidasse com 10.000 registros definindo as opções `:start` e `:finish` apropriadas em cada trabalhador.

`:error_on_ignore`

Substitui a configuração do aplicativo para especificar se um erro deve ser gerado quando um pedido estiver presente na relação.

`:order`

Especifica a ordem da chave primária (pode ser `:asc` ou `:desc`). O padrão é `:asc`.

```ruby
Customer.find_each(order: :desc) do |customer|
  NewsMailer.weekly(customer).deliver_now
end
```


#### find_in_batches

O método `find_in_batches` é semelhante ao `find_each`, pois ambos recuperam lotes de registros. A diferença é que `find_in_batches` gera lotes para o bloco como uma matriz de modelos, em vez de individualmente. O exemplo a seguir renderá ao bloco fornecido uma matriz de até 1.000 clientes por vez, com o bloco final contendo todos os clientes restantes:

```ruby
# Give add_customers an array of 1000 customers at a time.
Customer.find_in_batches do |customers|
  export.add_customers(customers)
end
```

`find_in_batches` trabalha em classes de modelos, como visto acima, e também em relações:

```ruby
# Give add_customers an array of 1000 recently active customers at a time.
Customer.recently_active.find_in_batches do |customers|
  export.add_customers(customers)
end
```

desde que não tenham ordem, pois o método precisa forçar uma ordem internamente para iterar.


##### Opções parafind_in_batches

O método `find_in_batches` aceita as mesmas opções que `find_each`:

`:batch_size`

Assim como for `find_each`, `batch_size` estabelece quantos registros serão recuperados em cada grupo. Por exemplo, a recuperação de lotes de 2.500 registros pode ser especificada como:

```ruby
Customer.find_in_batches(batch_size: 2500) do |customers|
  export.add_customers(customers)
end
```

`:start`

A opção `start` permite especificar o ID inicial a partir do qual os registros serão selecionados. Conforme mencionado anteriormente, por padrão, os registros são buscados em ordem crescente da chave primária. Por exemplo, para recuperar clientes começando no ID: 5000 em lotes de 2.500 registros, o seguinte código pode ser usado:

```ruby
Customer.find_in_batches(batch_size: 2500, start: 5000) do |customers|
  export.add_customers(customers)
end
```

`:finish`

A opção `finish` permite especificar o ID final dos registros a serem recuperados. O código abaixo mostra o caso de recuperação de clientes em lotes, até o cliente com ID: 7000:

```ruby
Customer.find_in_batches(finish: 7000) do |customers|
  export.add_customers(customers)
end
```

`:error_on_ignore`

A opção `error_on_ignore` substitui a configuração do aplicativo para especificar se um erro deve ser gerado quando uma ordem específica está presente na relação.

## Condições

O método `where` permite especificar condições para limitar os registros retornados, representando a WHERE parte -da instrução SQL. As condições podem ser especificadas como string, array ou hash.


### Condições de String Pura

Se quiser adicionar condições à sua descoberta, basta especificá-las lá, assim como `Book.where("title = 'Introduction to Algorithms'")`. Isto encontrará todos os livros onde o valor do campo `title` é 'Introdução aos Algoritmos'.

![Active Record Query Interface - condições](/imagens/active_record_query_interface7.JPG)


### Condições da Matriz

Agora, e se esse título pudesse variar, digamos, como um argumento de algum lugar? A descoberta então assumiria o formato:

```ruby
Book.where("title = ?", params[:title])
```

O Active Record considerará o primeiro argumento como a string de condições e quaisquer argumentos adicionais substituirão os pontos de interrogação (?)nele.

Se você quiser especificar várias condições:

```ruby
Book.where("title = ? AND out_of_print = ?", params[:title], false)
```

Neste exemplo, o primeiro ponto de interrogação será substituído pelo valor in params[:title]e o segundo será substituído pela representação SQL de false, que depende do adaptador.

Este código é altamente preferível:

```ruby
Book.where("title = ?", params[:title])
```

para este código:

```ruby
Book.where("title = #{params[:title]}")
```

por causa da segurança do argumento. Colocar a variável diretamente na string de condições passará a variável para o banco de dados como está . Isso significa que será uma variável sem escape diretamente de um usuário que pode ter intenções maliciosas. Se você fizer isso, colocará todo o seu banco de dados em risco, porque assim que um usuário descobrir que pode explorar seu banco de dados, ele poderá fazer praticamente qualquer coisa com ele. Nunca coloque seus argumentos diretamente dentro da string de condições.

![Active Record Query Interface - aviso sql injection](/imagens/active_record_query_interface8.JPG)


#### Condições do espaço reservado

Semelhante ao (?)estilo de substituição de parâmetros, você também pode especificar chaves em sua string de condições junto com um hash de chaves/valores correspondente:

```ruby
Book.where("created_at >= :start_date AND created_at <= :end_date",
  { start_date: params[:start_date], end_date: params[:end_date] })
```

Isso torna a legibilidade mais clara se você tiver um grande número de condições variáveis.


#### Condições de UsoLIKE

Embora os argumentos de condição tenham escape automático para evitar a injeção de SQL, `LIKE` os curingas SQL (ou seja, `%` e `_`) não têm escape. Isto pode causar um comportamento inesperado se um valor não higienizado for usado em um argumento. Por exemplo:

```ruby
Book.where("title LIKE ?", params[:title] + "%")
```

No código acima, a intenção é combinar títulos que começam com uma string especificada pelo usuário. No entanto, quaisquer ocorrências de `%` ou `_` in `params[:title]` serão tratadas como curingas, levando a resultados de consulta surpreendentes. Em algumas circunstâncias, isto também pode impedir que o banco de dados use um índice pretendido, levando a uma consulta muito mais lenta.

Para evitar esses problemas, use `sanitize_sql_like` caracteres curinga para escapar na parte relevante do argumento:

```ruby
Book.where("title LIKE ?",
  Book.sanitize_sql_like(params[:title]) + "%")
```


### Condições de hash

O Active Record também permite que você passe condições de hash que podem aumentar a legibilidade da sintaxe de suas condições. Com condições de hash, você passa um hash com as chaves dos campos que deseja qualificar e os valores de como deseja qualificá-los:

![Active Record Query Interface - condição hash](/imagens/active_record_query_interface9.JPG)


#### Condições de Igualdade
```ruby
Book.where(out_of_print: true)
```

Isso irá gerar SQL assim:

```sql
SELECT * FROM books WHERE (books.out_of_print = 1)
```

O nome do campo também pode ser uma string:

```ruby
Book.where('out_of_print' => true)
```

No caso de um relacionamento pertence_a, uma chave de associação pode ser usada para especificar o modelo se um objeto Active Record for usado como valor. Este método também funciona com relacionamentos polimórficos.

```ruby
author = Author.first
Book.where(author: author)
Author.joins(:books).where(books: { author: author })
```

As condições de hash também podem ser especificadas em uma sintaxe semelhante a uma tupla, onde a chave é um array de colunas e o valor é um array de tuplas:

```sql
Book.where([:author_id, :id] => [[15, 1], [15, 2]])
```

Esta sintaxe pode ser útil para consultar relações onde a tabela usa uma chave primária composta:

```ruby
class Book < ApplicationRecord
  self.primary_key = [:author_id, :id]
end

Book.where(Book.primary_key => [[2, 1], [3, 1]])
```


#### Condições de Faixa

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

Isto encontrará todos os livros criados ontem usando uma instrução `BETWEEN` SQL:

```sql
SELECT * FROM books WHERE (books.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

Isso demonstra uma sintaxe mais curta para os exemplos em Array Conditions

Intervalos sem início e sem fim são suportados e podem ser usados ​​para criar condições menores/maiores que.

```ruby
Book.where(created_at: (Time.now.midnight - 1.day)..)
```

Isso geraria SQL como:

```sql
SELECT * FROM books WHERE books.created_at >= '2008-12-21 00:00:00'
```


#### Condições do Subconjunto

Se você quiser encontrar registros usando a expressão `IN`, você pode passar um array para o hash de condições:

```ruby
Customer.where(orders_count: [1, 3, 5])
```

Este código irá gerar SQL assim:

```sql
SELECT * FROM customers WHERE (customers.orders_count IN (1,3,5))
```


### NÃO Condições

Consultas `NOT`, SQL podem ser construídas por `where.not`:

```ruby
Customer.where.not(orders_count: [1, 3, 5])
```

Em outras palavras, esta consulta pode ser gerada chamando `where` sem argumento e imediatamente encadeada com condições `not` de passagem `where`. Isso irá gerar SQL assim:

```sql
SELECT * FROM customers WHERE (customers.orders_count NOT IN (1,3,5))
```

Se uma consulta tiver uma condição de hash com valores diferentes de zero em uma coluna anulável, os registros que possuem valores `nil` na coluna anulável não serão retornados. Por exemplo:

```ruby
Customer.create!(nullable_country: nil)
Customer.where.not(nullable_country: "UK")
# => []

# But
Customer.create!(nullable_country: "UK")
Customer.where.not(nullable_country: nil)
# => [#<Customer id: 2, nullable_country: "UK">]
```


### Condições `OU`

Condições `OR` entre duas relações podem ser construídas invocando ora primeira relação e passando a segunda como argumento.

```ruby
Customer.where(last_name: 'Smith').or(Customer.where(orders_count: [1, 3, 5]))
```

```sql
SELECT * FROM customers WHERE (customers.last_name = 'Smith' OR customers.orders_count IN (1,3,5))
```


### Condições `E` 

Condições `AND` podem ser construídas encadeando condições `where`.

```ruby
Customer.where(last_name: 'Smith').where(orders_count: [1, 3, 5])
```

```sql
SELECT * FROM customers WHERE customers.last_name = 'Smith' AND customers.orders_count IN (1,3,5)
```

Condições `AND` para a interseção lógica entre relações podem ser construídas invocando `and` a primeira relação e passando a segunda como argumento.

```ruby
Customer.where(id: [1, 2]).and(Customer.where(id: [2, 3]))
```

```sql
SELECT * FROM customers WHERE (customers.id IN (1, 2) AND customers.id IN (2, 3))
```


## Pedidos
Para recuperar registros do banco de dados em uma ordem específica, você pode usar o método `order`.

Por exemplo, se você estiver obtendo um conjunto de registros e quiser ordená-los em ordem crescente de acordo com o campo `created_at` da sua tabela:

```ruby
Book.order(:created_at)
# OR
Book.order("created_at")
```

Você pode especificar `ASC` ou `DESC` também:

```ruby
Book.order(created_at: :desc)
# OR
Book.order(created_at: :asc)
# OR
Book.order("created_at DESC")
# OR
Book.order("created_at ASC")
```

Ou ordenando por vários campos:

```ruby
Book.order(title: :asc, created_at: :desc)
# OR
Book.order(:title, created_at: :desc)
# OR
Book.order("title ASC, created_at DESC")
# OR
Book.order("title ASC", "created_at DESC")
```

Se você quiser ligar `order` várias vezes, os pedidos subsequentes serão anexados ao primeiro:

```ruby
irb> Book.order("title ASC").order("created_at DESC")
SELECT * FROM books ORDER BY title ASC, created_at DESC
```

![Active Record Query Interface - order](/imagens/active_record_query_interface10.JPG)


## Selecionando Campos Específicos

Por padrão, `Model.find` seleciona todos os campos do conjunto de resultados usando `select *`.

Para selecionar apenas um subconjunto de campos do conjunto de resultados, você pode especificar o subconjunto por meio do método `select`.

Por exemplo, para selecionar apenas colunas `isbn` e `out_of_print`:

```ruby
Book.select(:isbn, :out_of_print)
# OR
Book.select("isbn, out_of_print")
```

A consulta SQL usada por esta chamada find será semelhante a:

```sql
SELECT isbn, out_of_print FROM books
```

Tenha cuidado porque isso também significa que você está inicializando um objeto de modelo apenas com os campos selecionados. Se você tentar acessar um campo que não esteja no registro inicializado, você receberá:

```ruby
ActiveModel::MissingAttributeError: missing attribute '<attribute>' for Book
```

Onde `<attribute>` está o atributo que você pediu. O método `id` não aumentará o `ActiveRecord::MissingAttributeError`, portanto, tome cuidado ao trabalhar com associações, pois elas precisam que o método `id` funcione corretamente.

Se desejar obter apenas um único registro por valor exclusivo em um determinado campo, você pode usar `distinct`:

```ruby
Customer.select(:last_name).distinct
```

Isso geraria SQL como:

```sql
SELECT DISTINCT last_name FROM customers
```

Você também pode remover a restrição de exclusividade:

```ruby
# Returns unique last_names
query = Customer.select(:last_name).distinct

# Returns all last_names, even if there are duplicates
query.distinct(false)
```


## Limite e deslocamento

Para aplicar `LIMIT` ao SQL disparado pelo `Model.find`, você pode especificar os métodos `LIMIT` usando `limit` e `offset` na relação.

Você pode usar `limit` para especificar o número de registros a serem recuperados e `offset` para especificar o número de registros a serem ignorados antes de começar a retornar os registros. Por exemplo

```ruby
Customer.limit(5)
```

retornará no máximo 5 clientes e, como não especifica nenhum deslocamento, retornará os 5 primeiros da tabela. O SQL que ele executa fica assim:

```sql
SELECT * FROM customers LIMIT 5
```

Adicionando `offset` a isso

```ruby
Customer.limit(5).offset(30)
```

retornará no máximo 5 clientes começando no dia 31. O SQL se parece com:

```sql
SELECT * FROM customers LIMIT 5 OFFSET 30
```


## Agrupamento

Para aplicar uma cláusula `GROUP BY` ao SQL disparado pelo localizador, você pode usar o método `group`.

Por exemplo, se você quiser encontrar um conjunto de datas em que os pedidos foram criados:

```ruby
Order.select("created_at").group("created_at")
```

E isso lhe dará um único objeto `Order` para cada data onde houver pedidos no banco de dados.

O SQL que seria executado seria algo assim:

```sql
SELECT created_at
FROM orders
GROUP BY created_at
```


### Total de Itens Agrupados

Para obter o total de itens agrupados em uma única consulta, chame `count` após o group.

```ruby
irb> Order.group(:status).count
=> {"being_packed"=>7, "shipped"=>12}
```

O SQL que seria executado seria algo assim:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM orders
GROUP BY status
```


### TER Condições

SQL usa a cláusula `HAVING` para especificar condições nos campos `GROUP BY`. Você pode adicionar a cláusula `HAVING` ao SQL disparado `Model.find` adicionando o método `having` ao `find`.

Por exemplo:

```ruby
Order.select("created_at, sum(total) as total_price").
  group("created_at").having("sum(total) > ?", 200)
```

O SQL que seria executado seria algo assim:

```sql
SELECT created_at as ordered_date, sum(total) as total_price
FROM orders
GROUP BY created_at
HAVING sum(total) > 200
```

Isso retorna a data e o preço total de cada objeto de pedido, agrupados pelo dia em que foram solicitados e onde o total é superior a US$ 200.

Você acessaria `total_price` para cada objeto de pedido retornado assim:

```ruby
big_orders = Order.select("created_at, sum(total) as total_price")
                  .group("created_at")
                  .having("sum(total) > ?", 200)

big_orders[0].total_price
# Returns the total price for the first Order object
```

## Condições predominantes


### unscope

Você pode especificar certas condições a serem removidas usando o método unscope. Por exemplo:

```ruby
Book.where('id > 100').limit(20).order('id desc').unscope(:order)
```
O SQL que seria executado:

```sql
SELECT * FROM books WHERE id > 100 LIMIT 20

-- Original query without `unscope`
SELECT * FROM books WHERE id > 100 ORDER BY id desc LIMIT 20
```

Você também pode remover o escopo `where` de cláusulas específicas. Por exemplo, isso removerá `id` a condição da cláusula `where`:

```ruby
Book.where(id: 10, out_of_print: false).unscope(where: :id)
# SELECT books.* FROM books WHERE out_of_print = 0
```

Uma relação usada `unscope` afetará qualquer relação na qual for mesclada:

```ruby
Book.order('id desc').merge(Book.unscope(:order))
# SELECT books.* FROM books
```


### only

Você também pode substituir condições usando o método `only`. Por exemplo:

```ruby
Book.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE id > 10 ORDER BY id DESC

-- Original query without `only`
SELECT * FROM books WHERE id > 10 ORDER BY id DESC LIMIT 20
```

### reselect

O método `reselect` substitui uma instrução select existente. Por exemplo:

```ruby
Book.select(:title, :isbn).reselect(:created_at)
```

O SQL que seria executado:

```sql
SELECT books.created_at FROM books
```

Compare isso com o caso em que a cláusula `reselect` não é usada:

```ruby
Book.select(:title, :isbn).select(:created_at)
```

o SQL executado seria:

```sql
SELECT books.title, books.isbn, books.created_at FROM books
```


### reorder

O método `reorder` substitui a ordem de escopo padrão. Por exemplo, se a definição da classe incluir isto:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order(year_published: :desc) }
end
```

E você executa isso:

```ruby
Author.find(10).books
```

O SQL que seria executado:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published DESC
```

Você pode usar a cláusula `reorder` para especificar uma maneira diferente de ordenar os livros:

```ruby
Author.find(10).books.reorder('year_published ASC')
```

O SQL que seria executado:

```sql
SELECT * FROM authors WHERE id = 10 LIMIT 1
SELECT * FROM books WHERE author_id = 10 ORDER BY year_published ASC
```

### reverse_order

O método `reverse_order` inverte a cláusula de ordem, se especificada.

```ruby
Book.where("author_id > 10").order(:year_published).reverse_order
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY year_published DESC
```

Se nenhuma cláusula de ordem for especificada na consulta, as ordens `reverse_order` serão ordenadas pela chave primária na ordem inversa.

```ruby
Book.where("author_id > 10").reverse_order
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE author_id > 10 ORDER BY books.id DESC
```

O método reverse_order não aceita argumentos.


### rewhere

O método `rewhere` substitui uma condição nomeada existente `where`. Por exemplo:

```ruby
Book.where(out_of_print: true).rewhere(out_of_print: false)
```

O SQL que seria executado:

```sql
SELECT * FROM books WHERE out_of_print = 0
```

Se a cláusula `rewhere` não for usada, as cláusulas `where` serão combinadas com `AND`:

```ruby
Book.where(out_of_print: true).where(out_of_print: false)
```

o SQL executado seria:

```sql
SELECT * FROM books WHERE out_of_print = 1 AND out_of_print = 0
```


### regroup

O método `regroup` substitui uma condição nomeada existente `group`. Por exemplo:

```ruby
Book.group(:author).regroup(:id)
```

O SQL que seria executado:

```sql
SELECT * FROM books GROUP BY id
```

Se a cláusula `regroup` não for usada, as cláusulas de grupo serão combinadas:

```ruby
Book.group(:author).group(:id)
```

o SQL executado seria:

```sql
SELECT * FROM books GROUP BY author, id
```


## Relação Nula

O método `none` retorna uma relação encadeada sem registros. Quaisquer condições subsequentes encadeadas à relação retornada continuarão gerando relações vazias. Isso é útil em cenários em que você precisa de uma resposta encadeada para um método ou escopo que possa retornar zero resultados.

```ruby
Book.none # returns an empty Relation and fires no queries.
```

```ruby
# The highlighted_reviews method below is expected to always return a Relation.
Book.first.highlighted_reviews.average(:rating)
# => Returns average rating of a book

class Book
  # Returns reviews if there are at least 5,
  # else consider this as non-reviewed book
  def highlighted_reviews
    if reviews.count > 5
      reviews
    else
      Review.none # Does not meet minimum threshold yet
    end
  end
end
```


## Objetos somente leitura

O Active Record fornece o método `readonly` em uma relação para proibir explicitamente a modificação de qualquer um dos objetos retornados. Qualquer tentativa de alterar um registro somente leitura não terá êxito, gerando uma exceção `ActiveRecord::ReadOnlyRecord`.

```ruby
customer = Customer.readonly.first
customer.visits += 1
customer.save # Raises an ActiveRecord::ReadOnlyRecord
```

Como `customer` está explicitamente definido como um objeto somente leitura, o código acima gerará uma exceção  `ActiveRecord::ReadOnlyRecord` ao chamar `customer.save` com um valor atualizado de visitas .


## Bloqueio de registros para atualização

O bloqueio é útil para evitar condições de corrida ao atualizar registros no banco de dados e garantir atualizações atômicas.

O Active Record fornece dois mecanismos de bloqueio:

- Bloqueio Otimista
- Bloqueio Pessimista


### Bloqueio Otimista

O bloqueio otimista permite que vários usuários acessem o mesmo registro para edições e pressupõe um mínimo de conflitos com os dados. Isso é feito verificando se outro processo fez alterações em um registro desde que ele foi aberto. Uma exceção `ActiveRecord::StaleObjectError` será lançada se isso tiver ocorrido e a atualização for ignorada.

**Coluna de bloqueio otimista** 

Para usar o bloqueio otimista, a tabela precisa ter uma coluna chamada `lock_version` do tipo inteiro. Cada vez que o registro é atualizado, o Active Record incrementa a coluna `lock_version`. Se uma solicitação de atualização for feita com um valor no campo `lock_version` inferior ao que está atualmente na coluna `lock_version` do banco de dados, a solicitação de atualização falhará com uma extensão `ActiveRecord::StaleObjectError`.

Por exemplo:
```ruby
c1 = Customer.find(1)
c2 = Customer.find(1)

c1.first_name = "Sandra"
c1.save

c2.first_name = "Michael"
c2.save # Raises an ActiveRecord::StaleObjectError
```

Você será então responsável por lidar com o conflito resgatando a exceção e revertendo, mesclando ou aplicando a lógica de negócios necessária para resolver o conflito.

Este comportamento pode ser desativado configurando `ActiveRecord::Base.lock_optimistically = false`.

Para substituir o nome da coluna `lock_version`, `ActiveRecord::Base` fornece um atributo de classe chamado `locking_column`:

```ruby
class Customer < ApplicationRecord
  self.locking_column = :lock_customer_column
end
```


### Bloqueio Pessimista

O bloqueio pessimista usa um mecanismo de bloqueio fornecido pelo banco de dados subjacente. Usar `lock` ao construir uma relação obtém um bloqueio exclusivo nas linhas selecionadas. As relações usando `lock` geralmente são agrupadas dentro de uma transação para evitar condições de conflito.

Por exemplo:

```ruby
Book.transaction do
  book = Book.lock.first
  book.title = 'Algorithms, second edition'
  book.save!
end
```

A sessão acima produz o seguinte SQL para um backend MySQL:

```sql
SQL (0.2ms)   BEGIN
Book Load (0.3ms)   SELECT * FROM books LIMIT 1 FOR UPDATE
Book Update (0.4ms)   UPDATE books SET updated_at = '2009-02-07 18:05:56', title = 'Algorithms, second edition' WHERE id = 1
SQL (0.8ms)   COMMIT
```

Você também pode passar SQL bruto para o método `lock` para permitir diferentes tipos de bloqueios. Por exemplo, o MySQL tem uma expressão chamada `LOCK IN SHARE MODE` onde você pode bloquear um registro, mas ainda permitir que outras consultas o leiam. Para especificar esta expressão basta passá-la como opção de bloqueio:

```ruby
Book.transaction do
  book = Book.lock("LOCK IN SHARE MODE").find(1)
  book.increment!(:views)
end
```

![Active Record Query Interface - bloqueio bloqueio pessimista](/imagens/active_record_query_interface11.JPG)

Se você já possui uma instância do seu modelo, você pode iniciar uma transação e adquirir o bloqueio de uma só vez usando o seguinte código:

```ruby
book = Book.first
book.with_lock do
  # This block is called within a transaction,
  # book is already locked.
  book.increment!(:views)
end
```


## Unindo Tabelas

O Active Record fornece dois métodos de localização para especificar cláusulas `JOIN` no SQL resultante: `joins` e `left_outer_joins`. Embora `joins` deva ser usado para consultas `INNER JOIN` personalizadas, `left_outer_joins` é usado para consultas usando `LEFT OUTER JOIN`.

### joins

Existem várias maneiras de usar o método `joins`.


#### Usando um fragmento SQL de string

Você pode simplesmente fornecer o SQL bruto especificando a cláusula `JOIN` para `joins`:

```ruby
Author.joins("INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE")
```

Isso resultará no seguinte SQL:

```sql
SELECT authors.* FROM authors INNER JOIN books ON books.author_id = authors.id AND books.out_of_print = FALSE
```

#### Usando Array/Hash de Associações Nomeadas

O Active Record permite usar os nomes das associações definidas no modelo como um atalho para especificar cláusulas `JOIN` para essas associações ao usar o método `joins`.

Todos os itens a seguir produzirão as consultas de junção esperadas usando `INNER JOIN`:

##### Aderir a uma única associação

```ruby
Book.joins(:reviews)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
```

Ou, em inglês: “retornar um objeto Livro para todos os livros com resenhas”. Observe que você verá livros duplicados se um livro tiver mais de uma resenha. Se você quiser livros exclusivos, você pode usar o arquivo Book.joins(:reviews).distinct.


#### Aderindo a Múltiplas Associações

```ruby
Book.joins(:author, :reviews)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN authors ON authors.id = books.author_id
  INNER JOIN reviews ON reviews.book_id = books.id
```

Ou, em inglês: “devolver todos os livros com seu autor que tenham pelo menos uma resenha”. Observe novamente que os livros com várias resenhas aparecerão várias vezes.

##### Unindo associações aninhadas (nível único)

```ruby
Book.joins(reviews: :customer)
```

Isso produz:

```sql
SELECT books.* FROM books
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
```

Ou, em inglês: “devolver todos os livros que tiverem resenha de um cliente”.


##### Unindo associações aninhadas (nível múltiplo)

```ruby
Author.joins(books: [{ reviews: { customer: :orders } }, :supplier])
```

Isso produz:

```sql
SELECT authors.* FROM authors
  INNER JOIN books ON books.author_id = authors.id
  INNER JOIN reviews ON reviews.book_id = books.id
  INNER JOIN customers ON customers.id = reviews.customer_id
  INNER JOIN orders ON orders.customer_id = customers.id
INNER JOIN suppliers ON suppliers.id = books.supplier_id
```

Ou, em inglês: “devolver todos os autores que possuem livros com resenhas e que foram encomendados por um cliente, e os fornecedores desses livros”.


#### Especificando condições nas tabelas unidas

Você pode especificar condições nas tabelas unidas usando as condições regulares de Array e String . As condições de hash fornecem uma sintaxe especial para especificar condições para as tabelas unidas:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where('orders.created_at' => time_range).distinct
```

Isso irá encontrar todos os clientes que possuem pedidos que foram criados ontem, utilizando uma expressão `BETWEEN` SQL para comparar created_at.

Uma sintaxe alternativa e mais limpa é aninhar as condições de hash:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).where(orders: { created_at: time_range }).distinct
```

Para condições mais avançadas ou para reutilizar um escopo nomeado existente, `merge` pode ser usado. Primeiro, vamos adicionar um novo escopo nomeado ao modelo `Order`:

```ruby
class Order < ApplicationRecord
  belongs_to :customer

  scope :created_in_time_range, ->(time_range) {
    where(created_at: time_range)
  }
end
```

Agora podemos usar `merge` para mesclar no escopo `created_in_time_range`:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Customer.joins(:orders).merge(Order.created_in_time_range(time_range)).distinct
```

Isso encontrará todos os clientes que possuem pedidos criados ontem, novamente usando uma expressão `BETWEEN` SQL.


### left_outer_joins

Se você deseja selecionar um conjunto de registros, independentemente de terem ou não registros associados, você pode usar o método `left_outer_joins`.

```ruby
Customer.left_outer_joins(:reviews).distinct.select('customers.*, COUNT(reviews.*) AS reviews_count').group('customers.id')
```

O que produz:

```sql
SELECT DISTINCT customers.*, COUNT(reviews.*) AS reviews_count FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id GROUP BY customers.id
```

O que significa: "retornar a todos os clientes a contagem de comentários, independentemente de eles terem ou não comentários"


### `where.associated` e `where.missing`

Os métodos de consulta `associated` e `missing` permitem selecionar um conjunto de registros com base na presença ou ausência de uma associação.

Usar `where.associated`:

```ruby
Customer.where.associated(:reviews)
```

Produz:

```sql
SELECT customers.* FROM customers
INNER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NOT NULL
```

O que significa “devolver todos os clientes que fizeram pelo menos uma avaliação”.

Usar `where.missing`:

```ruby
Customer.where.missing(:reviews)
```

Produz:

```sql
SELECT customers.* FROM customers
LEFT OUTER JOIN reviews ON reviews.customer_id = customers.id
WHERE reviews.id IS NULL
```

O que significa “devolver todos os clientes que não fizeram nenhuma avaliação”.


##  Associações Eager Loading

O carregamento rápido é o mecanismo para carregar os registros associados dos objetos retornados usando `Model.find` o mínimo de consultas possível.


### Problema de consultas N + 1

Considere o código a seguir, que encontra 10 livros e imprime o sobrenome de seus autores:

```ruby
books = Book.limit(10)

books.each do |book|
  puts book.author.last_name
end
```

Este código parece bom à primeira vista. Mas o problema está no número total de consultas executadas. O código acima executa 1 (para encontrar 10 livros) + 10 (uma por cada livro para carregar o autor) = 11 consultas no total.


#### Solução para o problema de consultas N + 1

Active Record permite especificar antecipadamente todas as associações que serão carregadas.

Os métodos são:

- `includes`
- `preload`
- `eager_load`


### includes

Com `includes`, o Active Record garante que todas as associações especificadas sejam carregadas usando o número mínimo possível de consultas.

Revisitando o caso acima usando o método `includes`, poderíamos reescrever `Book.limit(10)` para autores de carga antecipada:

```ruby
books = Book.includes(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

O código acima executará apenas 2 consultas, em oposição às 11 consultas do caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.id IN (1,2,3,4,5,6,7,8,9,10)
```


#### Carregamento Antecipado de Múltiplas Associações

O Active Record permite carregar qualquer número de associações com uma única chamada `Model.find`  usando um array, hash ou um hash aninhado de array/hash com o método `includes`.

##### Matriz de Múltiplas Associações

```ruby
Customer.includes(:orders, :reviews)
```

Isso carrega todos os clientes e os pedidos e avaliações associados a cada um.


##### Hash de associações aninhadas

```ruby
Customer.includes(orders: { books: [:supplier, :author] }).find(1)
```

Isso encontrará o cliente com id 1 e carregará todos os pedidos associados a ele, os livros de todos os pedidos e o autor e fornecedor de cada um dos livros.


#### Especificando Condições em Associações Eager Loaded

Embora o Active Record permita especificar condições nas associações carregadas antecipadamente, como `joins`, a maneira recomendada é usar junções.

No entanto, se você precisar fazer isso, poderá usar `where` normalmente.

```ruby
Author.includes(:books).where(books: { out_of_print: true })
```
Isso geraria uma consulta que contém um `LEFT OUTER JOIN` enquanto o smétodo `join` geraria uma consulta usando a função `INNER JOIN`.

```sql
SELECT authors.id AS t0_r0, ... books.updated_at AS t1_r5 FROM authors LEFT OUTER JOIN books ON books.author_id = authors.id WHERE (books.out_of_print = 1)
```

Se não houvesse condição where, isso geraria o conjunto normal de duas consultas.

![Active Record Query Interface - eager_loading includes](/imagens/active_record_query_interface12.JPG)

```ruby
Author.includes(:books).where("books.out_of_print = true").references(:books)
```

Se, no caso desta consulta `includes`, não houvesse livros de nenhum autor, todos os autores ainda seriam carregados. Ao usar `joins` (um INNER JOIN), as condições de junção devem corresponder, caso contrário nenhum registro será retornado.

![Active Record Query Interface - eager_loading includes](/imagens/active_record_query_interface13.JPG)


### preload

Com `preload`, o Active Record carrega cada associação especificada usando uma consulta por associação.

Revisitando o problema das consultas N + 1, poderíamos reescrever `Book.limit(10)` para pré-carregar os autores:

```ruby
books = Book.preload(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

O código acima executará apenas 2 consultas, em oposição às 11 consultas do caso original:

```sql
SELECT books.* FROM books LIMIT 10
SELECT authors.* FROM authors
  WHERE authors.id IN (1,2,3,4,5,6,7,8,9,10)
```

![Active Record Query Interface - eager_loading preload](/imagens/active_record_query_interface14.JPG)


### eager_load

Com `eager_load`, o Active Record carrega todas as associações especificadas usando um arquivo `LEFT OUTER JOIN`.

Revisitando o caso em que ocorreu N + 1 usando o método `eager_load`, poderíamos reescrever `Book.limit(10)` para os autores:

```ruby
books = Book.eager_load(:author).limit(10)

books.each do |book|
  puts book.author.last_name
end
```

O código acima executará apenas 2 consultas, em oposição às 11 consultas do caso original:

```sql
SELECT DISTINCT books.id FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id LIMIT 10
SELECT books.id AS t0_r0, books.last_name AS t0_r1, ...
  FROM books LEFT OUTER JOIN authors ON authors.id = books.author_id
  WHERE books.id IN (1,2,3,4,5,6,7,8,9,10)
```

![Active Record Query Interface - eager_loading eager_load](/imagens/active_record_query_interface15.JPG)


### strict_loading

O carregamento rápido pode evitar consultas N + 1, mas você ainda pode estar com preguiça de carregar algumas associações. Para garantir que nenhuma associação seja carregada lentamente, você pode ativar `strict_loading`.

Ao habilitar o modo de carregamento estrito em uma relação, um `ActiveRecord::StrictLoadingViolationError` será gerado se o registro tentar carregar lentamente qualquer associação:

```ruby
user = User.strict_loading.first
user.address.city # raises an ActiveRecord::StrictLoadingViolationError
user.comments.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

### strict_loading!

Também podemos ativar o carregamento estrito no próprio registro chamando `strict_loading!`:

```ruby
user = User.first
user.strict_loading!
user.address.city # raises an ActiveRecord::StrictLoadingViolationError
user.comments.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

`strict_loading!` também leva um argumento `:mode`. Definir como `:n_plus_one_only` só gerará um erro se uma associação que levará a uma consulta N + 1 for carregada lentamente:

```ruby
user.strict_loading!(mode: :n_plus_one_only)
user.address.city # => "Tatooine"
user.comments.to_a # => [#<Comment:0x00...]
user.comments.first.likes.to_a # raises an ActiveRecord::StrictLoadingViolationError
```

## Scopes

O escopo permite especificar consultas comumente usadas que podem ser referenciadas como chamadas de método nos objetos ou modelos de associação. Com `where` esses escopos, você pode usar todos os métodos abordados anteriormente , como `joins` e `includes`. Todos os corpos de escopo devem retornar um `ActiveRecord::Relation` ou `nil` para permitir que outros métodos (como outros escopos) sejam chamados nele.

Para definir um escopo simples, usamos o método `scope` dentro da classe, passando a consulta que gostaríamos de executar quando esse escopo for chamado:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

Para chamar esse escopo `out_of_print`, podemos chamá-lo na classe:

```ruby
irb> Book.out_of_print
=> #<ActiveRecord::Relation> # all out of print books
```

Ou em uma associação composta por objetos `Book`:

```ruby
irb> author = Author.first
irb> author.books.out_of_print
=> #<ActiveRecord::Relation> # all out of print books by `author`
```

Os escopos também podem ser encadeados dentro dos escopos:

```ruby
class Book < ApplicationRecord
  scope :out_of_print, -> { where(out_of_print: true) }
  scope :out_of_print_and_expensive, -> { out_of_print.where("price > 500") }
end
```


### Passando Argumentos

Seu escopo pode receber argumentos:

```ruby
class Book < ApplicationRecord
  scope :costs_more_than, ->(amount) { where("price > ?", amount) }
end
```

Chame o escopo como se fosse um método de classe:

```ruby
irb> Book.costs_more_than(100.10)
```

No entanto, isso está apenas duplicando a funcionalidade que seria fornecida a você por um método de classe.

```ruby
class Book < ApplicationRecord
  def self.costs_more_than(amount)
    where("price > ?", amount)
  end
end
```

Estes métodos ainda estarão acessíveis nos objetos de associação:

```ruby
irb> author.books.costs_more_than(100.10)
```


### Usando Condicionais

Seu escopo pode utilizar condicionais:

```ruby
class Order < ApplicationRecord
  scope :created_before, ->(time) { where(created_at: ...time) if time.present? }
end
```

Como os outros exemplos, este se comportará de forma semelhante a um método de classe.

```ruby
class Order < ApplicationRecord
  def self.created_before(time)
    where(created_at: ...time) if time.present?
  end
end
```

No entanto, há uma advertência importante: um escopo sempre retornará um objeto `ActiveRecord::Relation`, mesmo que a condicional seja avaliada como false, enquanto um método de classe retornará `nil`. Isso pode causar `NoMethodError` ao encadear métodos de classe com condicionais, se alguma das condicionais retornar false.


### Aplicando um Escopo Padrão

Se desejarmos que um escopo seja aplicado a todas as consultas do modelo, podemos usar o método default_scope dentro do próprio modelo.

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

Quando as consultas são executadas neste modelo, a consulta SQL agora será semelhante a esta:

```sql
SELECT * FROM books WHERE (out_of_print = false)
```

Se precisar fazer coisas mais complexas com um escopo padrão, você pode defini-lo alternativamente como um método de classe:

```ruby
class Book < ApplicationRecord
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

![Active Record Query Interface - eager_loading eager_load](/imagens/active_record_query_interface16.JPG)

```ruby
class Book < ApplicationRecord
  default_scope { where(out_of_print: false) }
end
```

```ruby
irb> Book.new
=> #<Book id: nil, out_of_print: false>
irb> Book.unscoped.new
=> #<Book id: nil, out_of_print: nil>
```

Esteja ciente de que, quando fornecidos no formato Array, `default_scope` os argumentos de consulta não podem ser convertidos em uma atribuição `Hash` de atributo padrão. Por exemplo:

```ruby
class Book < ApplicationRecord
  default_scope { where("out_of_print = ?", false) }
end
```

```ruby
irb> Book.new
=> #<Book id: nil, out_of_print: nil>
```

### Fusão de Escopos

Assim como `where` as cláusulas, os escopos são mesclados por meio de condições `AND`.

```ruby
class Book < ApplicationRecord
  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }

  scope :recent, -> { where(year_published: 50.years.ago.year..) }
  scope :old, -> { where(year_published: ...50.years.ago.year) }
end
```
```sql
irb> Book.out_of_print.old
SELECT books.* FROM books WHERE books.out_of_print = 'true' AND books.year_published < 1969
```

Podemos misturar e combinar condições `scope`, `where` e o SQL final terá todas as condições unidas por `AND`.

```sql
irb> Book.in_print.where(price: ...100)
SELECT books.* FROM books WHERE books.out_of_print = 'false' AND books.price < 100
```

Se quisermos que a última cláusula `where` vença, `merge` poderá ser usada.

```ruby
irb> Book.in_print.merge(Book.out_of_print)
SELECT books.* FROM books WHERE books.out_of_print = true
```

Uma ressalva importante é que `default_scope` será acrescentado nas condições `scope` e `where`.

```ruby
class Book < ApplicationRecord
  default_scope { where(year_published: 50.years.ago.year..) }

  scope :in_print, -> { where(out_of_print: false) }
  scope :out_of_print, -> { where(out_of_print: true) }
end
```

```ruby
irb> Book.all
SELECT books.* FROM books WHERE (year_published >= 1969)

irb> Book.in_print
SELECT books.* FROM books WHERE (year_published >= 1969) AND books.out_of_print = false

irb> Book.where('price > 50')
SELECT books.* FROM books WHERE (year_published >= 1969) AND (price > 50)
```

Como você pode ver acima, `default_scope` está sendo mesclado nas condições `scope` and `where`.

### Removendo todo o escopo

Se desejarmos remover o escopo por qualquer motivo, podemos usar o unscopedmétodo. Isto é especialmente útil se a default_scopefor especificado no modelo e não deve ser aplicado para esta consulta específica.

```ruby
Book.unscoped.load
```

Este método remove todo o escopo e fará uma consulta normal na tabela.

```ruby
irb> Book.unscoped.all
SELECT books.* FROM books

irb> Book.where(out_of_print: true).unscoped.all
SELECT books.* FROM books
```

`unscoped` também pode aceitar um bloqueio:

```ruby
irb> Book.unscoped { Book.out_of_print }
SELECT books.* FROM books WHERE books.out_of_print = true
```


## Localizadores dinâmicos

Para cada campo (também conhecido como atributo) definido em sua tabela, o Active Record fornece um método localizador. Se você tiver um campo chamado `first_name` em seu modelo `Customer`, por exemplo, você obtém o método de instância `find_by_first_name` gratuitamente no Active Record. Se você também tiver um campo `locked` no modelo `Customer`, também obterá um  método `find_by_locked`.

Você pode especificar um ponto de exclamação (`!`) no final dos localizadores dinâmicos para que eles gerem um erro `ActiveRecord::RecordNotFound` se não retornarem nenhum registro, como `Customer.find_by_first_name!("Ryan")`

Se quiser encontrar ambos por `first_name` e `orders_count`, você pode encadear esses localizadores simplesmente digitando "`and`" entre os campos. Por exemplo, `Customer.find_by_first_name_and_orders_count("Ryan", 5)`.


## Enums

Um enum permite definir uma matriz de valores para um atributo e consultá-los por nome. O valor real armazenado no banco de dados é um número inteiro que foi mapeado para um dos valores.

Declarar um enum irá:

- Crie escopos que possam ser usados ​​para localizar todos os objetos que possuem ou não um dos valores enum
- Crie um método de instância que possa ser usado para determinar se um objeto possui um valor específico para a enumeração
- Crie um método de instância que possa ser usado para alterar o valor enum de um objeto
para todos os valores possíveis de um enum.

Por exemplo, dada esta declaração `enum`:

```ruby
class Order < ApplicationRecord
  enum :status, [:shipped, :being_packaged, :complete, :cancelled]
end
```

Esses `escopos` são criados automaticamente e podem ser usados ​​para localizar todos os objetos com ou sem um valor específico para status:

```ruby
irb> Order.shipped
=> #<ActiveRecord::Relation> # all orders with status == :shipped
irb> Order.not_shipped
=> #<ActiveRecord::Relation> # all orders with status != :shipped
```

Esses métodos de instância são criados automaticamente e consultam se o modelo possui esse valor para o enum `status`:

```ruby
irb> order = Order.shipped.first
irb> order.shipped?
=> true
irb> order.complete?
=> false
```

Esses métodos de instância são criados automaticamente e primeiro atualizarão o valor de `status` para o valor nomeado e, em seguida, consultarão se o status foi ou não definido com êxito para o valor:

```ruby
irb> order = Order.first
irb> order.shipped!
UPDATE "orders" SET "status" = ?, "updated_at" = ? WHERE "orders"."id" = ?  [["status", 0], ["updated_at", "2019-01-24 07:13:08.524320"], ["id", 1]]
=> true
```

A documentação completa sobre enums pode ser encontrada [aqui](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Enum.html) .


## Compreendendo o encadeamento de métodos

O padrão Active Record implementa Method Chaining , que nos permite usar vários métodos Active Record juntos de maneira simples e direta.

Você pode encadear métodos em uma instrução quando o método anterior chamado retornar um `ActiveRecord::Relation`, como `all`, `where` e `joins`. Os métodos que retornam um único objeto (consulte a seção Recuperando uma seção de objeto único ) devem estar no final da instrução.

Existem alguns exemplos abaixo. Este guia não cobrirá todas as possibilidades, apenas algumas como exemplos. Quando um método Active Record é chamado, a consulta não é gerada e enviada imediatamente ao banco de dados. A consulta é enviada somente quando os dados são realmente necessários. Portanto, cada exemplo abaixo gera uma única consulta.

### Recuperando dados filtrados de múltiplas tabelas

```ruby
Customer
  .select('customers.id, customers.last_name, reviews.body')
  .joins(:reviews)
  .where('reviews.created_at > ?', 1.week.ago)
```
O resultado deve ser algo assim:

```sql
SELECT customers.id, customers.last_name, reviews.body
FROM customers
INNER JOIN reviews
  ON reviews.customer_id = customers.id
WHERE (reviews.created_at > '2019-01-08')
```

### Recuperando dados específicos de múltiplas tabelas

```ruby
Book
  .select('books.id, books.title, authors.first_name')
  .joins(:author)
  .find_by(title: 'Abstraction and Specification in Program Development')
```

O código acima deve gerar:

```sql
SELECT books.id, books.title, authors.first_name
FROM books
INNER JOIN authors
  ON authors.id = books.author_id
WHERE books.title = $1 [["title", "Abstraction and Specification in Program Development"]]
LIMIT 1
```

![Active Record Query Interface - encadeamento](/imagens/active_record_query_interface17.JPG)


## Encontre ou construa um novo objeto

É comum que você precise encontrar um registro ou criá-lo caso ele não exista. Você pode fazer isso com os métodos `find_or_create_by` e `find_or_create_by!`.


### find_or_create_by

O método `find_or_create_by` verifica se existe um registro com os atributos especificados. Se não, então `create` é chamado. Vejamos um exemplo.

Suponha que você queira encontrar um cliente chamado “Andy” e, se não houver, crie um. Você pode fazer isso executando:

```ruby
irb> Customer.find_or_create_by(first_name: 'Andy')
=> #<Customer id: 5, first_name: "Andy", last_name: nil, title: nil, visits: 0, orders_count: nil, lock_version: 0, created_at: "2019-01-17 07:06:45", updated_at: "2019-01-17 07:06:45">
```
O SQL gerado por este método é assim:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO customers (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` retorna o registro que já existe ou o novo registro. No nosso caso, ainda não tínhamos um cliente chamado Andy, então o registro é criado e retornado.

O novo registro pode não ser salvo no banco de dados; isso depende se as validações foram aprovadas ou não (assim como `create`).

Suponha que desejamos definir o atributo 'locked' como `false` se estivermos criando um novo registro, mas não queremos incluí-lo na consulta. Portanto, queremos encontrar o cliente chamado “Andy”, ou se esse cliente não existir, criar um cliente chamado “Andy” que não esteja bloqueado.

Podemos conseguir isso de duas maneiras. A primeira é usar `create_with`:

```ruby
Customer.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

A segunda maneira é usando um bloco:

```ruby
Customer.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

O bloco só será executado se o cliente estiver sendo criado. Na segunda vez que executarmos este código, o bloco será ignorado.


### find_or_create_by!

Você também pode usar `find_or_create_by!` para gerar uma exceção se o novo registro for inválido. As validações não são abordadas neste guia, mas vamos supor por um momento que você adicione temporariamente

```ruby
validates :orders_count, presence: true
```

Ao seu modelo `Customer`. Se você tentar criar um novo `Customer` sem passar um `orders_count`, o registro será inválido e uma exceção será gerada:

```ruby
irb> Customer.find_or_create_by!(first_name: 'Andy')
ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### find_or_initialize_by

O método `find_or_initialize_by` funcionará exatamente como `find_or_create_by`, mas chamará `new` em vez de `create`. Isso significa que uma nova instância de modelo será criada na memória, mas não será salva no banco de dados. Continuando com o exemplo `find_or_create_by`, agora queremos o cliente chamado ‘Nina’:

```ruby
irb> nina = Customer.find_or_initialize_by(first_name: 'Nina')
=> #<Customer id: nil, first_name: "Nina", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

irb> nina.persisted?
=> false

irb> nina.new_record?
=> true
```
Como o objeto ainda não está armazenado no banco de dados, o SQL gerado fica assim:

```sql
SELECT * FROM customers WHERE (customers.first_name = 'Nina') LIMIT 1
```

Quando quiser salvá-lo no banco de dados, basta chamar save:

```ruby
irb> nina.save
=> true
```


## Localização por SQL

Se quiser usar seu próprio SQL para localizar registros em uma tabela, você pode usar `find_by_sql`. O método `find_by_sql` retornará uma matriz de objetos mesmo que a consulta subjacente retorne apenas um único registro. Por exemplo, você poderia executar esta consulta:

```ruby
irb> Customer.find_by_sql("SELECT * FROM customers INNER JOIN orders ON customers.id = orders.customer_id ORDER BY customers.created_at desc")
=> [#<Customer id: 1, first_name: "Lucas" ...>, #<Customer id: 2, first_name: "Jan" ...>, ...]
```

`find_by_sql` fornece uma maneira simples de fazer chamadas personalizadas ao banco de dados e recuperar objetos instanciados.


### select_all

`find_by_sql` tem um parente próximo chamado `connection.select_all`. `select_all` recuperará objetos do banco de dados usando SQL personalizado, `find_by_sql` mas não os instanciará. Este método retornará uma instância da classe `ActiveRecord::Result` e chamar `to_a` nesse objeto retornará um array de hashes onde cada hash indica um registro.

```ruby
irb> Customer.connection.select_all("SELECT first_name, created_at FROM customers WHERE id = '1'").to_a
=> [{"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"}, {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}]
```


### pluck

`pluck` pode ser usado para escolher os valores das colunas nomeadas na relação atual. Ele aceita uma lista de nomes de colunas como argumento e retorna uma matriz de valores das colunas especificadas com o tipo de dados correspondente.

```ruby
irb> Book.where(out_of_print: true).pluck(:id)
SELECT id FROM books WHERE out_of_print = true
=> [1, 2, 3]

irb> Order.distinct.pluck(:status)
SELECT DISTINCT status FROM orders
=> ["shipped", "being_packed", "cancelled"]

irb> Customer.pluck(:id, :first_name)
SELECT customers.id, customers.first_name FROM customers
=> [[1, "David"], [2, "Fran"], [3, "Jose"]]
```

`pluck` torna possível substituir códigos como:

```ruby
Customer.select(:id).map { |c| c.id }
# or
Customer.select(:id).map(&:id)
# or
Customer.select(:id, :first_name).map { |c| [c.id, c.first_name] }
```

com:

```ruby
Customer.pluck(:id)
# or
Customer.pluck(:id, :first_name)
```

Ao contrário `select`, `pluck` converte diretamente o resultado de um banco de dados em `Array` Ruby, sem construir objetos `ActiveRecord`. Isso pode significar melhor desempenho para uma consulta grande ou executada com frequência. No entanto, quaisquer substituições de métodos de modelo não estarão disponíveis. Por exemplo:

```ruby
class Customer < ApplicationRecord
  def name
    "I am #{first_name}"
  end
end
```

```ruby
irb> Customer.select(:first_name).map &:name
=> ["I am David", "I am Jeremy", "I am Jose"]

irb> Customer.pluck(:first_name)
=> ["David", "Jeremy", "Jose"]
```

Você não está limitado a consultar campos de uma única tabela; também pode consultar várias tabelas.

```ruby
irb> Order.joins(:customer, :books).pluck("orders.created_at, customers.email, books.title")
```

Além disso, ao contrário de `select` outros escopos `Relation`, `pluck` desencadeia uma consulta imediata e, portanto, não pode ser encadeado com outros escopos, embora possa funcionar com escopos já construídos anteriormente:

```ruby
irb> Customer.pluck(:first_name).limit(1)
NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

irb> Customer.limit(1).pluck(:first_name)
=> ["David"]
```

![Active Record Query Interface - pluck](/imagens/active_record_query_interface18.JPG)

```ruby
irb> assoc = Customer.includes(:reviews)
irb> assoc.pluck(:id)
SELECT "customers"."id" FROM "customers" LEFT OUTER JOIN "reviews" ON "reviews"."id" = "customers"."review_id"
```

Uma maneira de evitar isso é incluir `unscope`:

```ruby
irb> assoc.unscope(:includes).pluck(:id)
```


### pick

`pick` pode ser usado para escolher os valores das colunas nomeadas na relação atual. Ele aceita uma lista de nomes de colunas como argumento e retorna a primeira linha dos valores de coluna especificados com o tipo de dados correspondente. `pick` é uma abreviação de `relation.limit(1).pluck(*column_names).first`, que é útil principalmente quando você já tem uma relação limitada a uma linha.

`pick` torna possível substituir códigos como:

```ruby
Customer.where(id: 1).pluck(:id).first
```

com:

```ruby
Customer.where(id: 1).pick(:id)
```


### ids

`ids` pode ser usado para obter todos os IDs da relação usando a chave primária da tabela.

```ruby
irb> Customer.ids
SELECT id FROM customers
```

```ruby
class Customer < ApplicationRecord
  self.primary_key = "customer_id"
end
```

```ruby
irb> Customer.ids
SELECT customer_id FROM customers
```


## Existência de Objetos

Se você simplesmente deseja verificar a existência do objeto, existe um método chamado `exists?`. Este método consultará o banco de dados usando a mesma consulta que `find`, mas em vez de retornar um objeto ou coleção de objetos ele retornará `true` ou `false`.

```ruby
Customer.exists?(1)
```

O método `exists?` também aceita vários valores, mas o problema é que ele retornará `true` se algum desses registros existir.

```ruby
Customer.exists?(id: [1, 2, 3])
# or
Customer.exists?(first_name: ['Jane', 'Sergei'])
```

É até possível usar `exists?` sem argumentos em um modelo ou relação.

```ruby
Customer.where(first_name: 'Ryan').exists?
```

O valor acima retorna `true` se houver pelo menos um cliente com o `first_name` 'Ryan' e `false` caso contrário.

```ruby
Customer.exists?
```

O caso acima retorna `false` se a tabela `customers` estiver vazia e `true` caso contrário.

Você também pode usar `any?` e `many?` para verificar a existência de um modelo ou relação. `many?` usará SQL `count` para determinar se o item existe.

```ruby
# via a model
Order.any?
# SELECT 1 FROM orders LIMIT 1
Order.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders LIMIT 2)

# via a named scope
Order.shipped.any?
# SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 1
Order.shipped.many?
# SELECT COUNT(*) FROM (SELECT 1 FROM orders WHERE orders.status = 0 LIMIT 2)

# via a relation
Book.where(out_of_print: true).any?
Book.where(out_of_print: true).many?

# via an association
Customer.first.orders.any?
Customer.first.orders.many?
```


## Cálculos
Esta seção usa `count` como exemplo o método neste preâmbulo, mas as opções descritas se aplicam a todas as subseções.

Todos os métodos de cálculo funcionam diretamente em um modelo:

```ruby
irb> Customer.count
SELECT COUNT(*) FROM customers
```

Ou em uma relação:

```ruby
irb> Customer.where(first_name: 'Ryan').count
SELECT COUNT(*) FROM customers WHERE (first_name = 'Ryan')
```

Você também pode usar vários métodos de localização em uma relação para realizar cálculos complexos:

```ruby
irb> Customer.includes("orders").where(first_name: 'Ryan', orders: { status: 'shipped' }).count
```

O que será executado:

```sql
SELECT COUNT(DISTINCT customers.id) FROM customers
  LEFT OUTER JOIN orders ON orders.customer_id = customers.id
  WHERE (customers.first_name = 'Ryan' AND orders.status = 0)
```

assumindo que a Ordem tenha enum status: [ :shipped, :being_packed, :cancelled ].


### count

Se você quiser ver quantos registros existem na tabela do seu modelo, você pode ligar `Customer.count` e isso retornará o número. Se quiser ser mais específico e encontrar todos os clientes com título presente no banco de dados você pode usar `Customer.count(:title)`.



### average

Se você quiser ver a média de um determinado número em uma de suas tabelas, você pode chamar o método `average` da classe relacionada à tabela. Esta chamada de método será semelhante a isto:

```ruby
Order.average("subtotal")
```

Isso retornará um número (possivelmente um número de ponto flutuante como 3,14159265) representando o valor médio no campo.



### minimum

Se você deseja encontrar o valor mínimo de um campo em sua tabela, você pode chamar o minimummétodo na classe relacionada à tabela. Esta chamada de método será semelhante a isto:

```ruby
Order.minimum("subtotal")
```




### maximum

Se você deseja encontrar o valor máximo de um campo em sua tabela, você pode chamar o maximummétodo na classe relacionada à tabela. Esta chamada de método será semelhante a isto:

```ruby
Order.maximum("subtotal")
```

### sum

Se quiser encontrar a soma de um campo para todos os registros da sua tabela, você pode chamar o summétodo na classe relacionada à tabela. Esta chamada de método será semelhante a isto:

```ruby
Order.sum("subtotal")
```


## Executando EXPLAIN

Você pode executar uma relação `explain`. A saída EXPLAIN varia para cada banco de dados.

Por exemplo, rodar

```ruby
Customer.where(id: 1).joins(:orders).explain
```

pode render


![Active Record Query Interface - explain](/imagens/active_record_query_interface19.JPG)

sob MySQL e MariaDB.

O Active Record executa uma impressão bonita que emula o shell do banco de dados correspondente. Portanto, a mesma consulta executada com o adaptador PostgreSQL produziria

![Active Record Query Interface - explain](/imagens/active_record_query_interface20.JPG)

O carregamento rápido pode acionar mais de uma consulta oculta, e algumas consultas podem precisar dos resultados das anteriores. Por causa disso, `explain` realmente executa a consulta e depois solicita os planos de consulta. Por exemplo,

```ruby
Customer.where(id: 1).includes(:orders).explain
```

pode gerar isso para MySQL e MariaDB:

![Active Record Query Interface - explain](/imagens/active_record_query_interface21.JPG)

e pode gerar isso para PostgreSQL:

![Active Record Query Interface - explain](/imagens/active_record_query_interface22.JPG)


### Explicar Opções

Para bancos de dados e adaptadores que os suportam (atualmente PostgreSQL e MySQL), opções podem ser passadas para fornecer análises mais profundas.

Usando PostgreSQL, o seguinte:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze, :verbose)
```

rendimentos:

![Active Record Query Interface - explain](/imagens/active_record_query_interface23.JPG)

Usando MySQL ou MariaDB, o seguinte:

```ruby
Customer.where(id: 1).joins(:orders).explain(:analyze)
```

rendimentos:

![Active Record Query Interface - explain](/imagens/active_record_query_interface24.JPG)


22.2 Interpretação EXPLICAR
A interpretação do resultado de EXPLAIN está além do escopo deste guia. As seguintes dicas podem ser úteis:

- SQLite3: [EXPLICAR O PLANO DE CONSULTA](https://www.sqlite.org/eqp.html)

- MySQL: [EXPLAIN Formato de saída](https://dev.mysql.com/doc/refman/8.3/en/explain-output.html)

- MariaDB: [EXPLICAR](https://mariadb.com/kb/en/mariadb/explain/)

- PostgreSQL: [Usando EXPLAIN](https://www.postgresql.org/docs/current/using-explain.html)