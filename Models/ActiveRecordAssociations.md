# Active Record Associations

## Porquê Associações?

No Rails, uma associação é uma conexão entre dois modelos Active Record. Por que precisamos de associações entre modelos? Porque eles tornam as operações comuns mais simples e fáceis no seu código.

Por exemplo, considere uma aplicação Rails simples que inclui um modelo para autores e um modelo para livros. Cada autor pode ter muitos livros.

Sem associações, as declarações do modelo ficariam assim:

```ruby
class Author < ApplicationRecord
end

class Book < ApplicationRecord
end
```

Agora, suponha que quiséssemos adicionar um novo livro de um autor existente. Precisaríamos fazer algo assim:

```ruby
@book = Book.create(published_at: Time.now, author_id: @author.id)
```

Ou considere excluir um autor e garantir que todos os seus livros também sejam excluídos:

```ruby
@books = Book.where(author_id: @author.id)
@books.each do |book|
  book.destroy
end
@author.destroy
```

Com as associações do Active Record, podemos agilizar essas - e outras - operações informando declarativamente ao Rails que existe uma conexão entre os dois modelos. Aqui está o código revisado para configurar autores e livros:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :destroy
end

class Book < ApplicationRecord
  belongs_to :author
end
```

Com essa mudança, criar um novo livro para um determinado autor fica mais fácil:

```ruby
@book = @author.books.create(published_at: Time.now)
```

Excluir um autor e todos os seus livros é muito mais fácil:

```ruby
@author.destroy
```

Para saber mais sobre os diferentes tipos de associações, leia a próxima seção deste guia. Isso é seguido por algumas dicas e truques para trabalhar com associações e, em seguida, por uma referência completa aos métodos e opções para associações no Rails.

## Os tipos de associações

Rails suporta seis tipos de associações, cada uma com um caso de uso específico em mente.

Aqui está uma lista de todos os tipos suportados com um link para seus documentos de API para obter informações mais detalhadas sobre como usá-los, seus parâmetros de método, etc.

- [`belongs_to`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-belongs_to)
- [`has_one`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one)
- [`has_many`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many)
- [`has_many :through`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_many)
- [`has_one :through`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_one)
- [`has_and_belongs_to_many`](https://api.rubyonrails.org/v7.1.3.2/classes/ActiveRecord/Associations/ClassMethods.html#method-i-has_and_belongs_to_many)

As associações são implementadas usando chamadas de estilo macro, para que você possa adicionar recursos declarativamente aos seus modelos. Por exemplo, ao declarar um modelo `belongs_to` de outro, você instrui o Rails a manter informações de Chave Primária - Chave Estrangeira entre instâncias dos dois modelos, e também obtém vários métodos utilitários adicionados ao seu modelo.

No restante deste guia, você aprenderá como declarar e usar as diversas formas de associações. Mas primeiro, uma rápida introdução às situações em que cada tipo de associação é apropriado.,


###  A Associação `belongs_to`

Uma associação `belongs_to` estabelece uma conexão com outro modelo, de modo que cada instância do modelo declarante “pertence a” uma instância do outro modelo. Por exemplo, se seu aplicativo incluir autores e livros, e cada livro puder ser atribuído a exatamente um autor, você declararia o modelo de livro desta forma:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

![Aviso Active Record Associations](/imagens/active_record_associations1.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Quando usado sozinho, `belongs_to` produz uma conexão unidirecional um para um. Portanto, cada livro no exemplo acima “conhece” seu autor, mas os autores não sabem sobre seus livros. Para configurar uma associação bidirecional - use `belongs_to` em combinação com um `has_one` ou `has_many` no outro modelo, neste caso o modelo Autor.

`belongs_to` não garante consistência de referência se `optional` estiver definido como verdadeiro, portanto, dependendo do caso de uso, você também pode precisar adicionar uma restrição de chave estrangeira no nível do banco de dados na coluna de referência, como esta:

```ruby
create_table :books do |t|
  t.belongs_to :author, foreign_key: true
  # ...
end
```


### A Associação `has_one`

Uma associação `has_one` indica que outro modelo tem uma referência a este modelo. Esse modelo pode ser obtido por meio desta associação.

Por exemplo, se cada fornecedor no seu aplicativo tiver apenas uma conta, você declararia o modelo do fornecedor assim:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

A principal diferença `belongs_to` é que a coluna do link `supplier_id` está localizada na outra tabela:

![Aviso Active Record Association has_one](/imagens/active_record_associations2.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end
  end
end
```

Dependendo do caso de uso, talvez você também precise criar um índice exclusivo e/ou uma restrição de chave estrangeira na coluna de fornecedor da tabela de contas. Nesse caso, a definição da coluna pode ser assim:

```ruby
create_table :accounts do |t|
  t.belongs_to :supplier, index: { unique: true }, foreign_key: true
  # ...
end
```

Esta relação pode ser bidirecional quando usada em combinação com `belongs_to` outro modelo.



###  A Associação `has_many`

Uma associação `has_many` é semelhante a `has_one`, mas indica uma conexão um-para-muitos com outro modelo. Muitas vezes você encontrará essa associação do “outro lado” de uma associação `belongs_to`. Esta associação indica que cada instância do modelo possui zero ou mais instâncias de outro modelo. Por exemplo, em uma aplicação contendo autores e livros, o modelo de autor poderia ser declarado assim:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

![Active Record Associations - has_many](/imagens/active_record_associations3.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateAuthors < ActiveRecord::Migration[7.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end

    create_table :books do |t|
      t.belongs_to :author
      t.datetime :published_at
      t.timestamps
    end
  end
end
```

Dependendo do caso de uso, geralmente é uma boa ideia criar um índice não exclusivo e, opcionalmente, uma restrição de chave estrangeira na coluna do autor da tabela de livros:

```ruby
create_table :books do |t|
  t.belongs_to :author, index: true, foreign_key: true
  # ...
end
```

###  A Associação `has_many :through`

Uma associação `has_many :through` é frequentemente usada para configurar uma conexão muitos para muitos com outro modelo. Esta associação indica que o modelo declarante pode ser combinado com zero ou mais instâncias de outro modelo, procedendo-se através de um terceiro modelo. Por exemplo, considere um consultório médico onde os pacientes marcam consultas médicas. As declarações de associação relevantes poderiam ser assim:

```ruby
class Physician < ApplicationRecord
  has_many :appointments
  has_many :patients, through: :appointments
end

class Appointment < ApplicationRecord
  belongs_to :physician
  belongs_to :patient
end

class Patient < ApplicationRecord
  has_many :appointments
  has_many :physicians, through: :appointments
end
```

![Active Record Associations - has_many :through](/imagens/active_record_associations4.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :physicians do |t|
      t.string :name
      t.timestamps
    end

    create_table :patients do |t|
      t.string :name
      t.timestamps
    end

    create_table :appointments do |t|
      t.belongs_to :physician
      t.belongs_to :patient
      t.datetime :appointment_date
      t.timestamps
    end
  end
end
```

A coleção de modelos de junção pode ser gerenciada através dos métodos `has_many` de associação . Por exemplo, se você atribuir:

```ruby
physician.patients = patients
```

Em seguida, novos modelos de junção são criados automaticamente para os objetos recém-associados. Se algumas das linhas que existiam anteriormente estiverem faltando, suas linhas de junção serão excluídas automaticamente.

![Active Record Associations - Aviso has_many :through](/imagens/active_record_associations5.JPG)

A associação `has_many :through` também é útil para configurar “atalhos” através de associações `has_many` aninhadas. Por exemplo, se um documento tiver muitas seções e uma seção tiver muitos parágrafos, às vezes você pode querer obter uma coleção simples de todos os parágrafos do documento. Você poderia configurar isso desta forma:

```ruby
class Document < ApplicationRecord
  has_many :sections
  has_many :paragraphs, through: :sections
end

class Section < ApplicationRecord
  belongs_to :document
  has_many :paragraphs
end

class Paragraph < ApplicationRecord
  belongs_to :section
end
```

Com `through: :sections` especificado, Rails agora entenderá:

```ruby
@document.paragraphs
```


###  A Associação `has_one :through`

Uma associação `has_one :through` estabelece uma conexão um-para-um com outro modelo. Esta associação indica que o modelo declarante pode ser combinado com uma instância de outro modelo através de um terceiro modelo. Por exemplo, se cada fornecedor tiver uma conta e cada conta estiver associada a um histórico de conta, o modelo do fornecedor poderá ser assim:

```ruby
class Supplier < ApplicationRecord
  has_one :account
  has_one :account_history, through: :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  has_one :account_history
end

class AccountHistory < ApplicationRecord
  belongs_to :account
end
```

![Active Record Associations - has_one :through](/imagens/active_record_associations6.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateAccountHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.belongs_to :supplier
      t.string :account_number
      t.timestamps
    end

    create_table :account_histories do |t|
      t.belongs_to :account
      t.integer :credit_rating
      t.timestamps
    end
  end
end
```


###  A Associação `has_and_belongs_to_many`

Uma associação `has_and_belongs_to_many` cria uma conexão direta muitos-para-muitos com outro modelo, sem nenhum modelo interveniente. Esta associação indica que cada instância do modelo declarante refere-se a zero ou mais instâncias de outro modelo. Por exemplo, se seu aplicativo inclui montagens e peças, com cada montagem tendo muitas peças e cada peça aparecendo em muitas montagens, você poderia declarar os modelos desta forma:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

![Active Record Associations - has_and_belongs_to_many](/imagens/active_record_associations7.JPG)

A migração correspondente pode ser assim:

```ruby
class CreateAssembliesAndParts < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies do |t|
      t.string :name
      t.timestamps
    end

    create_table :parts do |t|
      t.string :part_number
      t.timestamps
    end

    create_table :assemblies_parts, id: false do |t|
      t.belongs_to :assembly
      t.belongs_to :part
    end
  end
end
```

### Escolhendo entre `belongs_to` e `has_one`

Se quiser estabelecer um relacionamento um-para-um entre dois modelos, você precisará adicionar `belongs_to` em um e `has_one` em outro. Como você sabe qual é qual?

A distinção está em onde você coloca a chave estrangeira (ela vai para a tabela da classe que declara a associação `belongs_to`), mas você também deve pensar um pouco no significado real dos dados. O relacionamento `has_one`  diz que algo é seu - isto é, que algo aponta de volta para você. Por exemplo, faz mais sentido dizer que um fornecedor possui uma conta do que que uma conta possui um fornecedor. Isso sugere que os relacionamentos corretos são assim:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

A migração correspondente pode ser assim:

```ruby
class CreateSuppliers < ActiveRecord::Migration[7.1]
  def change
    create_table :suppliers do |t|
      t.string :name
      t.timestamps
    end

    create_table :accounts do |t|
      t.bigint  :supplier_id
      t.string  :account_number
      t.timestamps
    end

    add_index :accounts, :supplier_id
  end
end
```

![Active Record Associations Aviso](/imagens/active_record_associations8.JPG)


### Escolhendo entre `has_many :through` e `has_and_belongs_to_many`

Rails oferece duas maneiras diferentes de declarar um relacionamento muitos-para-muitos entre modelos. A primeira forma é utilizar o `has_and_belongs_to_many`, que permite fazer a associação diretamente:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

A segunda maneira de declarar um relacionamento muitos-para-muitos é usar `has_many :through`. Isso faz com que a associação seja indireta, através de um modelo de junção:

```ruby
class Assembly < ApplicationRecord
  has_many :manifests
  has_many :parts, through: :manifests
end

class Manifest < ApplicationRecord
  belongs_to :assembly
  belongs_to :part
end

class Part < ApplicationRecord
  has_many :manifests
  has_many :assemblies, through: :manifests
end
```

A regra mais simples é que você deve configurar um relacionamento `has_many :through` se precisar trabalhar com o modelo de relacionamento como uma entidade independente. Se você não precisar fazer nada com o modelo de relacionamento, pode ser mais simples configurar um relacionamento `has_and_belongs_to_many` (embora você precise se lembrar de criar a tabela de junção no banco de dados).

Você deve usar `has_many :through` se precisar de validações, retornos de chamada ou atributos extras no modelo de junção.

Embora `has_and_belongs_to_many` sugira a criação de uma tabela de junção sem chave primária por meio de id: false, considere usar uma chave primária composta para a tabela de junção no relacionamento `has_many :through`. Por exemplo, é recomendado usar `create_table` `:manifests, primary_key: [:assembly_id, :part_id]` no exemplo acima.



### Associações Polimórficas

Uma variação um pouco mais avançada nas associações é a associação polimórfica . Com associações polimórficas, um modelo pode pertencer a mais de um outro modelo, numa única associação. Por exemplo, você pode ter um modelo de imagem que pertence a um modelo de funcionário ou a um modelo de produto. Veja como isso pode ser declarado:

```ruby
class Picture < ApplicationRecord
  belongs_to :imageable, polymorphic: true
end

class Employee < ApplicationRecord
  has_many :pictures, as: :imageable
end

class Product < ApplicationRecord
  has_many :pictures, as: :imageable
end
```

Você pode pensar em uma declaração polimórfica `belongs_to` como a configuração de uma interface que qualquer outro modelo pode usar. De uma instância do modelo `Employee`, você pode recuperar uma coleção de imagens: `@employee.pictures`.

Da mesma forma, você pode recuperar `@product.pictures`.

Se você tiver uma instância do modelo `Picture`, poderá acessar seu pai por meio de `@picture.imageable`. Para fazer isso funcionar, você precisa declarar uma coluna de chave estrangeira e uma coluna de tipo no modelo que declara a interface polimórfica:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string  :name
      t.bigint  :imageable_id
      t.string  :imageable_type
      t.timestamps
    end

    add_index :pictures, [:imageable_type, :imageable_id]
  end
end
```

Esta migração pode ser simplificada usando o formulário `t.references`:

```ruby
class CreatePictures < ActiveRecord::Migration[7.1]
  def change
    create_table :pictures do |t|
      t.string :name
      t.references :imageable, polymorphic: true
      t.timestamps
    end
  end
end
```

![Active Record Associations Polimorfismo](/imagens/active_record_associations9.JPG)



### Associações entre Modelos com Chaves Primárias Compostas

Rails geralmente é capaz de inferir informações de chave primária - chave estrangeira entre modelos associados com chaves primárias compostas sem precisar de informações extras. Veja o seguinte exemplo:

```ruby
class Order < ApplicationRecord
  self.primary_key = [:shop_id, :id]
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :order
end
```

Aqui, Rails assume que a coluna `:id` deve ser usada como chave primária para a associação entre um pedido e seus livros, assim como acontece com uma associação regular `has_many`/`belongs_to`. Isso inferirá que a coluna de chave estrangeira na tabela `books` é `:order_id`. Acessando o pedido de um livro:

```ruby
order = Order.create!(id: [1, 2], status: "pending")
book = order.books.create!(title: "A Cool Book")

book.reload.order
```

irá gerar o seguinte SQL para acessar o pedido:

```sql
SELECT * FROM orders WHERE id = 2
```

Isso só funciona se a chave primária composta do modelo contiver a coluna `:id` e a coluna for exclusiva para todos os registros. Para usar a chave primária composta completa em associações, defina a opção `query_constraints` na associação. Esta opção especifica uma chave estrangeira composta na associação: todas as colunas da chave estrangeira serão usadas ao consultar o(s) registro(s) associado(s). Por exemplo:


```ruby
class Author < ApplicationRecord
  self.primary_key = [:first_name, :last_name]
  has_many :books, query_constraints: [:first_name, :last_name]
end

class Book < ApplicationRecord
  belongs_to :author, query_constraints: [:author_first_name, :author_last_name]
end
```

Acessando o autor de um livro:

```ruby
author = Author.create!(first_name: "Jane", last_name: "Doe")
book = author.books.create!(title: "A Cool Book")

book.reload.author
```

usará `:first_name` e `:last_name` na consulta SQL:

```sql
SELECT * FROM authors WHERE first_name = 'Jane' AND last_name = 'Doe'
```


### Auto-junções

Ao projetar um modelo de dados, às vezes você encontrará um modelo que deveria ter uma relação consigo mesmo. Por exemplo, você pode querer armazenar todos os funcionários em um único modelo de banco de dados, mas ser capaz de rastrear relacionamentos como entre gerente e subordinados. Esta situação pode ser modelada com associações auto-associadas:

```ruby
class Employee < ApplicationRecord
  has_many :subordinates, class_name: "Employee",
                          foreign_key: "manager_id"

  belongs_to :manager, class_name: "Employee", optional: true
end
```

Com esta configuração, você pode recuperar `@employee.subordinates` e `@employee.manager`.

Em suas migrações/esquema, você adicionará uma coluna de referências ao próprio modelo.

```ruby
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.references :manager, foreign_key: { to_table: :employees }
      t.timestamps
    end
  end
end
```

![Active Record Associations Aviso auto join](/imagens/active_record_associations10.JPG)


## Dicas, Truques e Avisos

Aqui estão algumas coisas que você deve saber para fazer uso eficiente de associações Active Record em suas aplicações Rails:

- Controlando o cache
- Evitando colisões de nomes
- Atualizando o esquema
- Controlando o escopo da associação
- Associações bidirecionais


### Controlando o Cache

Todos os métodos de associação são construídos em torno do cache, que mantém o resultado da consulta mais recente disponível para operações futuras. O cache é até compartilhado entre métodos. Por exemplo:

```ruby
# retrieves books from the database
author.books.load

# uses the cached copy of books
author.books.size

# uses the cached copy of books
author.books.empty?
```

Mas e se você quiser recarregar o cache, porque os dados podem ter sido alterados por alguma outra parte do aplicativo? Basta ligar `reload` para a associação:

```ruby
# retrieves books from the database
author.books.load

# uses the cached copy of books
author.books.size

# discards the cached copy of books and goes back to the database
author.books.reload.empty?
```


### Evitando colisões de nomes

Você não é livre para usar qualquer nome para suas associações. Como a criação de uma associação adiciona um método com esse nome ao modelo, é uma má ideia dar a uma associação um nome que já seja usado para um método de instância de `ActiveRecord::Base`. O método de associação substituiria o método base e quebraria as coisas. Por exemplo, `attributes` ou `connection` são nomes ruins para associações.



### Atualizando o Esquema

As associações são extremamente úteis, mas não são mágicas. Você é responsável por manter o esquema do seu banco de dados de acordo com suas associações. Na prática, isso significa duas coisas, dependendo do tipo de associação que você está criando. Para associações `belongs_to` você precisa criar chaves estrangeiras, e para associações `has_and_belongs_to_many` você precisa criar a tabela de junção apropriada.


#### Criando Chaves Estrangeiras para Associações `belongs_to`
Ao declarar uma associação `belongs_to`, você precisa criar chaves estrangeiras conforme apropriado. Por exemplo, considere este modelo:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Esta declaração precisa ser apoiada por uma coluna de chave estrangeira correspondente na tabela `books`. Para uma tabela totalmente nova, a migração pode ser mais ou menos assim:

```ruby
class CreateBooks < ActiveRecord::Migration[7.1]
  def change
    create_table :books do |t|
      t.datetime   :published_at
      t.string     :book_number
      t.references :author
    end
  end
end
```

Já para uma tabela existente, pode ser assim:

```ruby
class AddAuthorToBooks < ActiveRecord::Migration[7.1]
  def change
    add_reference :books, :author
  end
end
```

![Active Record Associations - FK para belong_to](/imagens/active_record_associations11.JPG)



#### Criando tabelas de junção para associações `has_and_belongs_to_many`

Se você criar uma associação `has_and_belongs_to_many`, precisará criar explicitamente a tabela de união. A menos que o nome da tabela de junção seja especificado explicitamente usando a opção `:join_table`, o `Active Record` cria o nome usando a ordem lexical dos nomes das classes. Portanto, uma junção entre os modelos de autor e livro fornecerá o nome padrão da tabela de junção `"authors_books"` porque "a" supera "b" na ordem lexical.

![Active Record Associations - Aviso lexical](/imagens/active_record_associations12.JPG)

Seja qual for o nome, você deve gerar manualmente a tabela de junção com uma migração apropriada. Por exemplo, considere estas associações:

```ruby
class Assembly < ApplicationRecord
  has_and_belongs_to_many :parts
end

class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Eles precisam ser apoiados por uma migração para criar a tabela `assemblies_parts`. Esta tabela deve ser criada sem uma chave primária:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_table :assemblies_parts, id: false do |t|
      t.bigint :assembly_id
      t.bigint :part_id
    end

    add_index :assemblies_parts, :assembly_id
    add_index :assemblies_parts, :part_id
  end
end
```

Passamos `id: false` porque `create_table` essa tabela não representa um modelo. Isso é necessário para que a associação funcione corretamente. Se você observar qualquer comportamento estranho em uma associação `has_and_belongs_to_many`, como IDs de modelo mutilados ou exceções sobre IDs conflitantes, é provável que você tenha esquecido essa parte.

Para simplificar, você também pode usar o método `create_join_table`:

```ruby
class CreateAssembliesPartsJoinTable < ActiveRecord::Migration[7.1]
  def change
    create_join_table :assemblies, :parts do |t|
      t.index :assembly_id
      t.index :part_id
    end
  end
end
```

### Escopo da Associação de Controle