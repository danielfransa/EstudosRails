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

