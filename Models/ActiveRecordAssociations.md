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

Por padrão, as associações procuram objetos apenas dentro do escopo do módulo atual. Isso pode ser importante quando você declara modelos Active Record dentro de um módulo. Por exemplo:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end

    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Isso funcionará bem, porque tanto a classe `Supplier` quanto a classe `Account` são definidas no mesmo escopo. Mas o seguinte não funcionará, porque `Supplier` e `Account` são definidos em escopos diferentes:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier
    end
  end
end
```

Para associar um modelo a um modelo em um namespace diferente, você deve especificar o nome completo da classe em sua declaração de associação:

```ruby
module MyApplication
  module Business
    class Supplier < ApplicationRecord
      has_one :account,
        class_name: "MyApplication::Billing::Account"
    end
  end

  module Billing
    class Account < ApplicationRecord
      belongs_to :supplier,
        class_name: "MyApplication::Business::Supplier"
    end
  end
end
```


### Associações bidirecionais

É normal que as associações funcionem em duas direções, sendo necessária a declaração em dois modelos diferentes:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
end
```

O Active Record tentará identificar automaticamente que esses dois modelos compartilham uma associação bidirecional com base no nome da associação. Esta informação permite que o Active Record:

  - Evite consultas desnecessárias para dados já carregados:
    ```bash
    irb> author = Author.first
    irb> author.books.all? do |book|
    irb>   book.author.equal?(author) # No additional queries executed here
    irb> end
    => true
    ```

  - Evite dados inconsistentes (já que há apenas uma cópia do objeto `Author` carregada):
    ```bash
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => true
    ```

  - Associações de salvamento automático em mais casos:
    ```bash
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => true
    ```

  - Valide a `presença` e `ausência` de associações em mais casos:
    ```bash
    irb> book = Book.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => true
    ```

O Active Record suporta identificação automática para a maioria das associações com nomes padrão. No entanto, as associações bidirecionais que contêm as opções `:through` ou `:foreign_key` não serão identificadas automaticamente.

Os escopos personalizados na associação oposta também impedem a identificação automática, assim como os escopos personalizados na própria associação, a menos que `config.active_record.automatic_scope_inversing` sejam definidos como verdadeiros (o padrão para novos aplicativos).

Por exemplo, considere as seguintes declarações de modelo:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Devido à opção `:foreign_key`, o Active Record não reconhecerá mais automaticamente a associação bidirecional. Isso pode fazer com que seu aplicativo:

  - Execute consultas desnecessárias para os mesmos dados (neste exemplo, causando N+1 consultas):
    ```bash
    irb> author = Author.first
    irb> author.books.any? do |book|
    irb>   book.author.equal?(author) # This executes an author query for every book
    irb> end
    => false
    ```

  - Faça referência a várias cópias de um modelo com dados inconsistentes:
    ```bash
    irb> author = Author.first
    irb> book = author.books.first
    irb> author.name == book.author.name
    => true
    irb> author.name = "Changed Name"
    irb> author.name == book.author.name
    => false
    ```

  - Falha ao salvar associações automaticamente:
    ```bash
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.save!
    irb> book.persisted?
    => true
    irb> author.persisted?
    => false
    ```

  - Falha ao validar presença ou ausência:
    ```bash
    irb> author = Author.new
    irb> book = author.books.new
    irb> book.valid?
    => false
    irb> book.errors.full_messages
    => ["Author must exist"]
    ```

O Active Record oferece a opção `:inverse_of` para que você possa declarar explicitamente associações bidirecionais:

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: 'writer'
end

class Book < ApplicationRecord
  belongs_to :writer, class_name: 'Author', foreign_key: 'author_id'
end
```

Ao incluir a opção `:inverse_of` na declaração de associação `has_many` , o Active Record agora reconhecerá a associação bidirecional e se comportará como nos exemplos iniciais acima.

## Referência detalhada da associação

As seções a seguir fornecem detalhes de cada tipo de associação, incluindo os métodos que elas adicionam e as opções que você pode usar ao declarar uma associação.

### Referência de Associação `belongs_to`

Em termos de banco de dados, a associação `belongs_to` afirma que a tabela deste modelo contém uma coluna que representa uma referência a outra tabela. Isto pode ser usado para configurar relações um-para-um ou um-para-muitos, dependendo da configuração. Se a tabela da outra classe contiver a referência em uma relação um-para-um, você deverá usá-la com `has_one`

#### Métodos Adicionados por `belongs_to`

Ao declarar uma associação `belongs_to`, a classe declarante ganha automaticamente 8 métodos relacionados à associação:

- `association`
- `association=(associate)`
- `build_association(attributes = {})`
- `create_association(attributes = {})`
- `create_association!(attributes = {})`
- `reload_association`
- `reset_association`
- `association_changed?`
- `association_previously_changed?`

Em todos esses métodos, `association` é substituído pelo símbolo passado como primeiro argumento para `belongs_to`. Por exemplo, dada a declaração:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end
```

Cada instância do Bookmodelo terá estes métodos:

- `author`
- `author=`
- `build_author`
- `create_author`
- `create_author!`
- `reload_author`
- `reset_author`
- `author_changed?`
- `author_previously_changed?`

![Aviso Active Record Associations](/imagens/active_record_associations13.JPG)


##### association

O método `association` retorna o objeto associado, se houver. Se nenhum objeto associado for encontrado, ele retornará `nil`.

```ruby
@author = @book.author
```

Se o objeto associado já tiver sido recuperado do banco de dados para este objeto, a versão em cache será retornada. Para substituir esse comportamento (e forçar a leitura do banco de dados), chame `#reload_association` no objeto pai.

```ruby
@book.reset_author
```

##### association=(associate)

O método `association=` atribui um objeto associado a este objeto. Nos bastidores, isso significa extrair a chave primária do objeto associado e definir a chave estrangeira desse objeto com o mesmo valor.

```ruby
@book.author = @author
```

##### build_association(attributes = {})

O método `build_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, e o link através da chave estrangeira deste objeto será definido, mas o objeto associado ainda não será salvo.

```ruby
@author = @book.build_author(author_number: 123,
                             author_name: "John Doe")
```

##### create_association(attributes = {})

O método `create_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, o link através da chave estrangeira deste objeto será definido e, uma vez aprovado em todas as validações especificadas no modelo associado, o objeto associado será salvo.

```ruby
@author = @book.create_author(author_number: 123,
                              author_name: "John Doe")
```

##### create_association!(attributes = {})

Faz o mesmo que `create_association` acima, mas aumenta `ActiveRecord::RecordInvalid` se o registro for inválido.

##### association_changed?

O método `association_changed?` retorna verdadeiro se um novo objeto associado tiver sido atribuído e a chave estrangeira será atualizada no próximo salvamento.

```bash
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.author_changed? # => true

@book.save!
@book.author_changed? # => false
```

##### association_previously_changed?

O método `association_previously_changed?` retorna verdadeiro se o salvamento anterior atualizou a associação para fazer referência a um novo objeto associado.

```bash
@book.author # => #<Author author_number: 123, author_name: "John Doe">
@book.author_previously_changed? # => false

@book.author = Author.second # => #<Author author_number: 456, author_name: "Jane Smith">
@book.save!
@book.author_previously_changed? # => true
```

#### Opções para `belongs_to`

Embora o Rails use padrões inteligentes que funcionarão bem na maioria das situações, pode haver momentos em que você queira personalizar o comportamento da referência de associação `belongs_to`. Essas personalizações podem ser realizadas facilmente passando opções e blocos de escopo ao criar a associação. Por exemplo, esta associação usa duas dessas opções:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at,
    counter_cache: true
end
```

A belongs_toassociação apoia estas opções:

- `:autosave`
- `:class_name`
- `:counter_cache`
- `:default`
- `:dependent`
- `:ensuring_owner_was`
- `:foreign_key`
- `:foreign_type`
- `:primary_key`
- `:inverse_of`
- `:optional`
- `:polymorphic`
- `:required`
- `:strict_loading`
- `:touch`
- `:validate`

##### :autosave

Se você definir a opção `:autosave` como `true`, o Rails salvará quaisquer membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, os novos objetos associados serão salvos, mas os objetos associados atualizados não serão salvos.


##### :class_name

Se o nome do outro modelo não puder ser derivado do nome da associação, você poderá usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um livro pertence a um autor, mas o nome real do modelo que contém os autores é Patron, você configuraria as coisas desta forma:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron"
end
```

##### :counter_cache

A opção `:counter_cache` pode ser usada para tornar mais eficiente a localização do número de objetos pertencentes. Considere estes modelos:

```ruby
class Book < ApplicationRecord
  belongs_to :author
end

class Author < ApplicationRecord
  has_many :books
end
```

Com essas declarações, solicitar o valor de `@author.books.size` requer fazer uma chamada ao banco de dados para realizar uma COUNT(*)consulta. Para evitar esta chamada, você pode adicionar um cache de contador ao modelo pertencente :

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Com esta declaração, Rails manterá o valor do cache atualizado e então retornará esse valor em resposta ao método `size`.

Embora a opção `:counter_cache` seja especificada no modelo que inclui a declaração `belongs_to`, a coluna real deve ser adicionada ao modelo associado (`has_many`). No caso acima, você precisaria adicionar uma coluna nomeada `books_count` ao modelo `Author`.

Você pode substituir o nome da coluna padrão especificando um nome de coluna personalizado na declaração `counter_cache` em vez de true. Por exemplo, para usar `count_of_books` em vez de `books_count`:

```ruby
class Book < ApplicationRecord
  belongs_to :author, counter_cache: :count_of_books
end

class Author < ApplicationRecord
  has_many :books
end
```

![Aviso Active Record Associations -Aviso counter_cache](/imagens/active_record_associations14.JPG)

As colunas de cache do contador são adicionadas à lista de atributos somente leitura do modelo proprietário por meio de `attr_readonly`.

Se por algum motivo você alterar o valor da chave primária de um modelo proprietário e não atualizar também as chaves estrangeiras dos modelos contados, o cache do contador poderá ter dados obsoletos. Em outras palavras, quaisquer modelos órfãos ainda contarão para o contador. Para corrigir um cache de contador obsoleto, use `reset_counters`.

##### :default

Quando definido como `true`, a associação não terá sua presença validada.

##### :dependent

Se você definir a opção `:dependent` para:

- `:destroy`, quando o objeto for destruído, `destroy` será chamado em seus objetos associados.
- `:delete`, quando o objeto for destruído, todos os seus objetos associados serão excluídos diretamente do banco de dados sem chamar seu destroymétodo.
- `:destroy_async`: quando o objeto é destruído, um `ActiveRecord::DestroyAssociationAsyncJob` trabalho é enfileirado e chamará destroy em seus objetos associados. O trabalho ativo deve ser configurado para que isso funcione. Não utilize esta opção se a associação for apoiada por restrições de chave estrangeira no seu banco de dados. As ações de restrição de chave estrangeira ocorrerão dentro da mesma transação que exclui seu proprietário.

![Aviso Active Record Associations -Aviso dependent](/imagens/active_record_associations15.JPG)


##### ensuring_owner_was

Especifica um método de instância a ser chamado pelo proprietário. O método deve retornar verdadeiro para que os registros associados sejam excluídos em uma tarefa em segundo plano.

##### :foreign_key

Por convenção, Rails assume que a coluna usada para armazenar a chave estrangeira neste modelo é o nome da associação com o sufixo `_id` adicionado. A opção `:foreign_key` permite definir o nome da chave estrangeira diretamente:

```ruby
class Book < ApplicationRecord
  belongs_to :author, class_name: "Patron",
                      foreign_key: "patron_id"
end
```

![Aviso Active Record Associations -Aviso foreign_key](/imagens/active_record_associations16.JPG)


##### foreign_type

Especifique a coluna utilizada para armazenar o tipo do objeto associado, caso se trate de uma associação polimórfica. Por padrão, este é considerado o nome da associação com um `_type` sufixo “”. Portanto, uma classe que define uma associação `belongs_to :taggable, polymorphic: true` usará “`taggable_type`” como padrão `:foreign_type`.

##### :primary_key

Por convenção, Rails assume que a coluna `id` é usada para armazenar a chave primária de suas tabelas. A opção `:primary_key`  permite especificar uma coluna diferente.

Por exemplo, dado que temos uma tabela `users` e `guid` como chave primária. Se quisermos que uma tabela `todos` separada armazene a chave estrangeira `user_id` na coluna `guid`, podemos usar `primary_key` para conseguir isso da seguinte forma:

```ruby
class User < ApplicationRecord
  self.primary_key = 'guid' # primary key is guid and not id
end

class Todo < ApplicationRecord
  belongs_to :user, primary_key: 'guid'
end
```

Quando executarmos `@user.todos.create`, o registro `@todo` terá seu valor `user_id` como o valor `guid` de `@user`.


##### :inverse_of

A opção `:inverse_of` especifica o nome da associação `has_many` ou `has_one` que é o inverso desta associação. Consulte a seção de associação bidirecional para obter mais detalhes.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

##### :optional

Se você definir a opção `:optional` como `true`, a presença do objeto associado não será validada. Por padrão, esta opção está definida como false.


##### :polymorphic
Passar `true` para a opção `:polymorphic` indica que se trata de uma associação polimórfica. As associações polimórficas foram discutidas em detalhes anteriormente neste guia .


##### :required
Quando definido como `true`, a associação também terá sua presença validada. Isto validará a associação em si, não o id. Você pode usar `:inverse_of` para evitar uma consulta extra durante a validação.

![Aviso Active Record Associations -Aviso required](/imagens/active_record_associations17.JPG)


##### :strict_loading

Aplica o carregamento estrito sempre que o registro associado é carregado por meio desta associação.


##### :touch

Se você definir a opção `:touch` como `true`, o carimbo de data/hora `updated_at` ou `updated_on` no objeto associado será definido para a hora atual sempre que esse objeto for salvo ou destruído:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: true
end

class Author < ApplicationRecord
  has_many :books
end
```

Nesse caso, salvar ou destruir um livro atualizará o carimbo de data/hora do autor associado. Você também pode especificar um atributo de carimbo de data/hora específico para atualização:

```ruby
class Book < ApplicationRecord
  belongs_to :author, touch: :books_updated_at
end
```


##### :validate

Se você definir a opção `:validate` como `true`, então novos objetos associados serão validados sempre que você salvar este objeto. Por padrão, isto é `false`: novos objetos associados não serão validados quando este objeto for salvo.



####  Escopos para `belongs_to`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `belongs_to`. Essas personalizações podem ser obtidas por meio de um bloco de escopo. Por exemplo:

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão dentro do bloco de escopo. Os seguintes são discutidos abaixo:

- `where`
- `includes`
- `readonly`
- `select`


##### where

O método `where` permite especificar as condições que o objeto associado deve atender.

```ruby
class Book < ApplicationRecord
  belongs_to :author, -> { where active: true }
end
```

##### includes

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada. Por exemplo, considere estes modelos:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

Se você recupera frequentemente autores diretamente de capítulos (`@chapter.book.author`), então você pode tornar seu código um pouco mais eficiente incluindo autores na associação de capítulos a livros:

```ruby
class Chapter < ApplicationRecord
  belongs_to :book, -> { includes :author }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Author < ApplicationRecord
  has_many :books
end
```

![Aviso Active Record Associations -Aviso includes](/imagens/active_record_associations18.JPG)


##### readonly

Se você usar `readonly`, o objeto associado será somente leitura quando recuperado por meio da associação.

##### select

O método `select` permite substituir a cláusula `SELECT` do SQL usada para recuperar dados sobre o objeto associado. Por padrão, o Rails recupera todas as colunas.

![Aviso Active Record Associations -Aviso select](/imagens/active_record_associations19.JPG)


#### Existe algum objeto associado?

Você pode ver se existe algum objeto associado usando o método `association.nil?`:

```ruby
if @book.author.nil?
  @msg = "No author found for this book"
end
```

#### Quando os objetos são salvos?
Atribuir um objeto a uma associação `belongs_to` não salva automaticamente o objeto. Também não salva o objeto associado.



### Referência de Associação `has_one`

A associação `has_one` cria uma correspondência um-para-um com outro modelo. Em termos de banco de dados, esta associação diz que a outra classe contém a chave estrangeira. Se esta classe contiver a chave estrangeira, você deverá usar `belongs_to`.



#### Métodos Adicionados por `has_one`

Ao declarar uma has_oneassociação, a classe declarante ganha automaticamente 6 métodos relacionados à associação:

- `association`
- `association=(associate)`
- `build_association(attributes = {})`
- `create_association(attributes = {})`
- `create_association!(attributes = {})`
- `reload_association`
- `reset_association`

Em todos esses métodos, associationé substituído pelo símbolo passado como primeiro argumento para has_one. Por exemplo, dada a declaração:

```ruby
class Supplier < ApplicationRecord
  has_one :account
end
```

Cada instância do modelo `Supplier` terá estes métodos:

- `account`
- `account=`
- `build_account`
- `create_account`
- `create_account!`
- `reload_account`
- `reset_account`

![Aviso Active Record Associations -has_one](/imagens/active_record_associations20.JPG)



##### association

O método `association` retorna o objeto associado, se houver. Se nenhum objeto associado for encontrado, ele retornará `nil`.

```ruby
@account = @supplier.account
```

Se o objeto associado já tiver sido recuperado do banco de dados para este objeto, a versão em cache será retornada. Para substituir esse comportamento (e forçar a leitura do banco de dados), chame `#reload_association` no objeto pai.

```ruby
@account = @supplier.reload_account
```

Para descarregar a versão em cache do objeto associado — forçando o próximo acesso, se houver, para consultá-lo no banco de dados — chame `#reset_association` no objeto pai.

```ruby
@supplier.reset_account
```


##### association=(associate)

O método `association=` atribui um objeto associado a este objeto. Nos bastidores, isso significa extrair a chave primária deste objeto e definir a chave estrangeira do objeto associado com o mesmo valor.

```ruby
@supplier.account = @account
```


##### build_association(attributes = {})

O método `build_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, e o link através de sua chave estrangeira será definido, mas o objeto associado ainda não será salvo.

```ruby
@account = @supplier.build_account(terms: "Net 30")
```


##### create_association(attributes = {})

O método `create_association` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, o link através de sua chave estrangeira será definido e, uma vez aprovado em todas as validações especificadas no modelo associado, o objeto associado será salvo.

```ruby
@account = @supplier.create_account(terms: "Net 30")
```


##### create_association!(attributes = {})

Faz o mesmo que `create_association` acima, mas aumenta `ActiveRecord::RecordInvalid` se o registro for inválido.

####  Opções para `has_one`

Embora o Rails use padrões inteligentes que funcionarão bem na maioria das situações, pode haver momentos em que você queira personalizar o comportamento da referência de associação `has_one`. Essas personalizações podem ser facilmente realizadas passando opções ao criar a associação. Por exemplo, esta associação usa duas dessas opções:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing", dependent: :nullify
end
```

A associação `has_one` apoia estas opções:

- `:as`
- `:autosave`
- `:class_name`
- `:dependent`
- `:disable_joins`
- `:ensuring_owner_was`
- `:foreign_key`
- `:inverse_of`
- `:primary_key`
- `:query_constraints`
- `:required`
- `:source`
- `:source_type`
- `:strict_loading`
- `:through`
- `:touch`
- `:validate`

##### :as

Definir a opção `:as` indica que esta é uma associação polimórfica. As associações polimórficas foram discutidas em detalhes anteriormente neste guia .

##### :autosave

Se você definir a opção `:autosave` como `true`, o Rails salvará quaisquer membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, os novos objetos associados serão salvos, mas os objetos associados atualizados não serão salvos.

##### :class_name

Se o nome do outro modelo não puder ser derivado do nome da associação, você poderá usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um fornecedor tiver uma conta, mas o nome real do modelo que contém as contas for Billing, você configuraria as coisas desta forma:

```ruby
class Supplier < ApplicationRecord
  has_one :account, class_name: "Billing"
end
```

##### :dependent

Controla o que acontece com o objeto associado quando seu proprietário é destruído:

- `:destroy` faz com que o objeto associado também seja destruído
- `:delete` faz com que o objeto associado seja excluído diretamente do banco de dados (portanto, os retornos de chamada não serão executados)
- `:destroy_async`: quando o objeto é destruído, um trabalho `ActiveRecord::DestroyAssociationAsyncJob` é enfileirado e chamará destroy em seus objetos associados. O trabalho ativo deve ser configurado para que isso funcione. Não utilize esta opção se a associação for apoiada por restrições de chave estrangeira no seu banco de dados. As ações de restrição de chave estrangeira ocorrerão dentro da mesma transação que exclui seu proprietário.
- `:nullify` faz com que a chave estrangeira seja definida como NULL. A coluna do tipo polimórfico também é anulada em associações polimórficas. Os retornos de chamada não são executados.
- `:restrict_with_exception` faz com que uma exceção `ActiveRecord::DeleteRestrictionError` seja levantada se houver um registro associado
- `:restrict_with_error` faz com que um erro seja adicionado ao proprietário se houver um objeto associado

É necessário não definir ou deixar opções `:nullify` para associações que possuem restrições de banco de dados `NOT NULL`. Se você não definir `dependent` a destruição de tais associações, não poderá alterar o objeto associado porque a chave estrangeira do objeto associado inicial será definida com o valor `NULL` não permitido.


##### :disable_joins
Especifica se as junções devem ser ignoradas para uma associação. Se definido como `true`, duas ou mais consultas serão geradas. Observe que em alguns casos, se for aplicada ordem ou limite, isso será feito na memória devido a limitações do banco de dados. Esta opção só é aplicável em associações `has_one :through` , pois `has_one` sozinha não realiza uma junção.


##### :foreign_key

Por convenção, Rails assume que a coluna usada para armazenar a chave estrangeira no outro modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite definir o nome da chave estrangeira diretamente:

```ruby
class Supplier < ApplicationRecord
  has_one :account, foreign_key: "supp_id"
end
```

![Aviso Active Record Associations -Aviso foreign_key](/imagens/active_record_associations16.JPG)



##### :inverse_of

A opção `:inverse_of` especifica o nome da associação `belongs_to` que é o inverso desta associação. Consulte a seção de associação bidirecional para obter mais detalhes.

```ruby
class Supplier < ApplicationRecord
  has_one :account, inverse_of: :supplier
end

class Account < ApplicationRecord
  belongs_to :supplier, inverse_of: :account
end
```


##### :primary_key

Por convenção, Rails assume que a coluna usada para armazenar a chave primária deste modelo é `id`. Você pode substituir isso e especificar explicitamente a chave primária com a opção `:primary_key`.



##### :query_constraints

Serve como uma chave estrangeira composta. Define a lista de colunas a serem utilizadas para consultar o objeto associado. Esta é uma opção opcional. Por padrão, o Rails tentará derivar o valor automaticamente. Quando o valor é definido, o tamanho do Array deve corresponder à chave primária do modelo associado ou ao tamanho de query_constraints.



##### :required

Quando definido como `true`, a associação também terá sua presença validada. Isto validará a associação em si, não o id. Você pode usar `:inverse_of` para evitar uma consulta extra durante a validação.


##### :source

A opção `:source` especifica o nome da associação de origem para uma associação `has_one :through`.



##### :source_type

A opção `:source_type` especifica o tipo de associação de origem para uma associação `has_one :through` que prossegue através de uma associação polimórfica.

```ruby
class Author < ApplicationRecord
  has_one :book
  has_one :hardback, through: :book, source: :format, source_type: "Hardback"
  has_one :dust_jacket, through: :hardback
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Paperback < ApplicationRecord; end

class Hardback < ApplicationRecord
  has_one :dust_jacket
end

class DustJacket < ApplicationRecord; end
```


##### :strict_loading

Aplica o carregamento estrito sempre que o registro associado é carregado por meio desta associação.



##### :through

A opção `:through` especifica um modelo de junção através do qual realizar a consulta. As associações `has_one :through` foram discutidas em detalhes anteriormente neste guia .



##### :touch

Se você definir a opção `:touch` como `true`, o carimbo de data/hora `updated_at` ou `updated_on` no objeto associado será definido para a hora atual sempre que esse objeto for salvo ou destruído:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: true
end

class Account < ApplicationRecord
  belongs_to :supplier
end
```

Neste caso, salvar ou destruir um fornecedor atualizará o carimbo de data/hora da conta associada. Você também pode especificar um atributo de carimbo de data/hora específico para atualização:

```ruby
class Supplier < ApplicationRecord
  has_one :account, touch: :suppliers_updated_at
end
```

##### :validate

Se você definir a opção `:validate` como `true`, então novos objetos associados serão validados sempre que você salvar este objeto. Por padrão, isto é `false`: novos objetos associados não serão validados quando este objeto for salvo.



#### Escopos para `has_one`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `has_one`. Essas personalizações podem ser obtidas por meio de um bloco de escopo. Por exemplo:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where active: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão dentro do bloco de escopo. Os seguintes são discutidos abaixo:

- `where`
- `includes`
- `readonly`
- `select`



##### where

O método `where` permite especificar as condições que o objeto associado deve atender.

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { where "confirmed = 1" }
end
```


##### includes

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada. Por exemplo, considere estes modelos:


```ruby
class Supplier < ApplicationRecord
  has_one :account
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```

Se você frequentemente recupera representantes diretamente dos fornecedores (`@supplier.account.representative`), então você pode tornar seu código um pouco mais eficiente incluindo representantes na associação de fornecedores para contas:

```ruby
class Supplier < ApplicationRecord
  has_one :account, -> { includes :representative }
end

class Account < ApplicationRecord
  belongs_to :supplier
  belongs_to :representative
end

class Representative < ApplicationRecord
  has_many :accounts
end
```


##### readonly

Se você usar o método `readonly`, o objeto associado será somente leitura quando recuperado por meio da associação.


##### select

O método `select` permite substituir a cláusula `SELECT` SQL usada para recuperar dados sobre o objeto associado. Por padrão, o Rails recupera todas as colunas.


#### Existe algum objeto associado?

Você pode ver se existe algum objeto associado usando o método `association.nil?`:

```ruby
if @supplier.account.nil?
  @msg = "No account found for this supplier"
end
```


####  Quando os objetos são salvos?

Quando você atribui um objeto a uma associação `has_one`, esse objeto é salvo automaticamente (para atualizar sua chave estrangeira). Além disso, qualquer objeto substituído também é salvo automaticamente, pois sua chave estrangeira também será alterada.

Se algum desses salvamentos falhar devido a erros de validação, a instrução de atribuição retornará `false` e a atribuição em si será cancelada.

Se o objeto pai (aquele que declara a associação `has_one`) não for salvo (ou seja, `new_record?` retornar `true`), os objetos filhos não serão salvos. Eles serão automaticamente quando o objeto pai for salvo.

Se você deseja atribuir um objeto a uma associação `has_one` sem salvar o objeto, use o método `build_association`.


###  Referência de Associação `has_many`

A associação `has_many` cria um relacionamento um-para-muitos com outro modelo. Em termos de banco de dados, esta associação diz que a outra classe terá uma chave estrangeira que se refere a instâncias desta classe.

#### Métodos Adicionados por `has_many`

Ao declarar uma associação `has_many`, a classe declarante ganha automaticamente 17 métodos relacionados à associação:

- `collection`
- `collection<<(object, ...)`
- `collection.delete(object, ...)`
- `collection.destroy(object, ...)`
- `collection=(objects)`
- `collection_singular_ids`
- `collection_singular_ids=(ids)`
- `collection.clear`
- `collection.empty?`
- `collection.size`
- `collection.find(...)`
- `collection.where(...)`
- `collection.exists?(...)`
- `collection.build(attributes = {})`
- `collection.create(attributes = {})`
- `collection.create!(attributes = {})`
- `collection.reload`

Em todos esses métodos, `collection` é substituído pelo símbolo passado como primeiro argumento para `has_many` e `collection_singular` é substituído pela versão singularizada desse símbolo. Por exemplo, dada a declaração:

```ruby
class Author < ApplicationRecord
  has_many :books
end
```

Cada instância do modelo `Author` terá estes métodos:

```bash
books
books<<(object, ...)
books.delete(object, ...)
books.destroy(object, ...)
books=(objects)
book_ids
book_ids=(ids)
books.clear
books.empty?
books.size
books.find(...)
books.where(...)
books.exists?(...)
books.build(attributes = {}, ...)
books.create(attributes = {})
books.create!(attributes = {})
books.reload
```


##### collection

O método collection retorna uma relação de todos os objetos associados. Se não houver objetos associados, retorna uma Relação vazia.

```ruby
@books = @author.books
``` 


##### collection<<(object, ...)
O método `collection<<` adiciona um ou mais objetos à coleção definindo suas chaves estrangeiras como a chave primária do modelo de chamada.

```ruby
@author.books << @book1
```



##### collection.delete(object, ...)
O método `collection.delete` remove um ou mais objetos da coleção definindo suas chaves estrangeiras como `NULL`.

```ruby
@author.books.delete(@book1)
```

![Aviso Active Record Associations - has_many - delete](/imagens/active_record_associations21.JPG)



##### collection.destroy(object, ...)

O método `collection.destroy` remove um ou mais objetos da coleção executando `destroy` em cada objeto.

```ruby
@author.books.destroy(@book1)
```

![Aviso Active Record Associations - has_many - destroy](/imagens/active_record_associations22.JPG)


##### collection=(objects)

O método `collection=` faz com que a coleção contenha apenas os objetos fornecidos, adicionando e excluindo conforme apropriado. As alterações são persistidas no banco de dados.


##### collection_singular_ids

O método `collection_singular_ids` retorna um array dos ids dos objetos da coleção.

```ruby
@book_ids = @author.book_ids
```


##### collection_singular_ids=(ids)
O método `collection_singular_ids=` faz com que a coleção contenha apenas os objetos identificados pelos valores de chave primária fornecidos, adicionando e excluindo conforme apropriado. As alterações são persistidas no banco de dados.



##### collection.clear
O método `collection.clear` remove todos os objetos da coleção de acordo com a estratégia especificada pela opção `dependent`. Se nenhuma opção for dada, segue a estratégia padrão. A estratégia padrão para associações `has_many :through` é `delete_all`, e para associações `has_many` é definir as chaves estrangeiras como `NULL`.

```ruby
@author.books.clear
```

![Active Record Associations has_many - collection.clear](/imagens/active_record_associations23.JPG)



##### collection.empty?

O método `collection.empty?` retorna `true` se a coleção não contiver nenhum objeto associado.

```ruby
<% if @author.books.empty? %>
  No Books Found
<% end %>
```


##### collection.size

O método `collection.size` retorna o número de objetos na coleção.

```ruby
@book_count = @author.books.size
```


##### collection.find(...)

O método `collection.find` encontra objetos na tabela da coleção.

```ruby
@available_book = @author.books.find(1)
```

##### collection.where(...)
O método `collection.where` encontra objetos dentro da coleção com base nas condições fornecidas, mas os objetos são carregados lentamente, o que significa que o banco de dados é consultado apenas quando o(s) objeto(s) são acessados.

```ruby
@available_books = @author.books.where(available: true) # No query yet
@available_book = @available_books.first # Now the database will be queried
```


##### collection.exists?(...)

O método `collection.exists?` verifica se existe um objeto que atenda às condições fornecidas na tabela da coleção.


##### collection.build(attributes = {})

O método `collection.build` retorna um único ou uma matriz de novos objetos do tipo associado. O(s) objeto(s) serão instanciados a partir dos atributos passados, e o link através de sua chave estrangeira será criado, mas os objetos associados ainda não serão salvos.

```ruby
@book = @author.books.build(published_at: Time.now,
                            book_number: "A12345")

@books = @author.books.build([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```


##### collection.create(attributes = {})

O método `collection.create` retorna um único ou uma matriz de novos objetos do tipo associado. O(s) objeto(s) será(ão) instanciado(s) a partir dos atributos passados, o link através de sua chave estrangeira será criado e, uma vez aprovado em todas as validações especificadas no modelo associado, o objeto associado será salvo.

```ruby
@book = @author.books.create(published_at: Time.now,
                             book_number: "A12345")

@books = @author.books.create([
  { published_at: Time.now, book_number: "A12346" },
  { published_at: Time.now, book_number: "A12347" }
])
```


##### collection.create!(attributes = {})

Faz o mesmo que `collection.create` acima, mas aumenta `ActiveRecord::RecordInvalid` se o registro for inválido.


##### collection.reload

O método `collection.reload` retorna uma Relação de todos os objetos associados, forçando a leitura do banco de dados. Se não houver objetos associados, retorna uma Relação vazia.

```ruby
@books = @author.books.reload
```


####  Opções para `has_many`

Embora o Rails use padrões inteligentes que funcionarão bem na maioria das situações, pode haver momentos em que você queira personalizar o comportamento da referência de associação `has_many`. Essas personalizações podem ser facilmente realizadas passando opções ao criar a associação. Por exemplo, esta associação usa duas dessas opções:

```ruby
class Author < ApplicationRecord
  has_many :books, dependent: :delete_all, validate: false
end
```

A associação `has_many` apoia estas opções:

- `:as`
- `:autosave`
- `:class_name`
- `:counter_cache`
- `:dependent`
- `:disable_joins`
- `:ensuring_owner_was`
- `:extend`
- `:foreign_key`
- `:foreign_type`
- `:inverse_of`
- `:primary_key`
- `:query_constraints`
- `:source`
- `:source_type`
- `:strict_loading`
- `:through`
- `:validate`


##### :as

Definir a opção `:as` indica que esta é uma associação polimórfica, conforme discutido anteriormente neste guia .


##### :autosave

Se você definir a opção `:autosave` como `true`, o Rails salvará quaisquer membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, os novos objetos associados serão salvos, mas os objetos associados atualizados não serão salvos.


##### :class_name

Se o nome do outro modelo não puder ser derivado do nome da associação, você poderá usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se um autor tiver muitos livros, mas o nome real do modelo que contém os livros for `Transaction`, você configuraria as coisas desta forma:

```ruby
class Author < ApplicationRecord
  has_many :books, class_name: "Transaction"
end
```


##### :counter_cache

Esta opção pode ser usada para configurar um arquivo `:counter_cache`. Você só precisa desta opção quando personalizou o nome da sua associação `:counter_cache` `pertence_to`.


##### :dependent

Controla o que acontece com os objetos associados quando seu proprietário é destruído:

- `:destroy` faz com que todos os objetos associados também sejam destruídos
- `:delete_all` faz com que todos os objetos associados sejam excluídos diretamente do banco de dados (portanto, os retornos de chamada não serão executados)
- `:destroy_async`: quando o objeto é destruído, um trabalho `ActiveRecord::DestroyAssociationAsyncJob` é enfileirado e chamará destroy em seus objetos associados. O trabalho ativo deve ser configurado para que isso funcione.
- `:nullify` faz com que a chave estrangeira seja definida como `NULL`. A coluna do tipo polimórfico também é anulada em associações polimórficas. Os retornos de chamada não são executados.
- `:restrict_with_exception` faz com que uma exceção `ActiveRecord::DeleteRestrictionError` seja levantada se houver algum registro associado
- `:restrict_with_error` faz com que um erro seja adicionado ao proprietário se houver algum objeto associado

As opções `:destroy` e `:delete_all` também afetam a semântica dos métodos `collection.delete` e `collection=`, fazendo com que eles destruam objetos associados quando são removidos da coleção.


##### :disable_joins

Especifica se as junções devem ser ignoradas para uma associação. Se definido como verdadeiro, duas ou mais consultas serão geradas. Observe que em alguns casos, se for aplicada ordem ou limite, isso será feito na memória devido a limitações do banco de dados. Esta opção só é aplicável `has_many :through associations` quando `has_many` sozinho não executa uma junção.


##### :ensuring_owner_was

Especifica um método de instância a ser chamado pelo proprietário. O método deve retornar verdadeiro para que os registros associados sejam excluídos em uma tarefa em segundo plano.


##### :extend

Especifica um módulo ou matriz de módulos que será estendido ao objeto de associação retornado. Útil para definir métodos em associações, especialmente quando devem ser compartilhados entre vários objetos de associação.


##### :foreign_key

Por convenção, Rails assume que a coluna usada para armazenar a chave estrangeira no outro modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite definir o nome da chave estrangeira diretamente:

```ruby
class Author < ApplicationRecord
  has_many :books, foreign_key: "cust_id"
end
```

![Aviso Active Record Associations -Aviso foreign_key](/imagens/active_record_associations16.JPG)


##### :foreign_type

Especifique a coluna utilizada para armazenar o tipo do objeto associado, caso se trate de uma associação polimórfica. Por padrão, este é considerado o nome da associação polimórfica especificada na opção `as` “ ” com um sufixo `_type` “ ”. Portanto, uma classe que define uma associação `has_many :tags, as: :taggable` usará “`taggable_type`” como padrão `:foreign_type`.


##### :inverse_of

A opção `:inverse_of` especifica o nome da associação `belongs_to` que é o inverso desta associação. Consulte a seção de associação bidirecional para obter mais detalhes.

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```


##### :primary_key

Por convenção, Rails assume que a coluna usada para conter a chave primária da associação é `id`. Você pode substituir isso e especificar explicitamente a chave primária com a opção `:primary_key`.

Digamos que a tabela `users` tenha `id` como chave primária, mas também tenha uma coluna `guid` . O requisito é que a tabela `todos`  mantenha o valor da coluna `guid` como chave estrangeira e não `id` como valor. Isso pode ser alcançado assim:

```ruby
class User < ApplicationRecord
  has_many :todos, primary_key: :guid
end
```

Agora, se executarmos `@todo = @user.todos.create`, o valor `@todo` do registro `user_id` será o valor `guid` de `@user`.


##### :query_constraints

Serve como uma chave estrangeira composta. Define a lista de colunas a serem utilizadas para consultar o objeto associado. Esta é uma opção opcional. Por padrão, o Rails tentará derivar o valor automaticamente. Quando o valor é definido, o tamanho do Array deve corresponder à chave primária ou `query_constraints` ao tamanho do modelo associado.


##### :source

A opção `:source` especifica o nome da associação de origem para uma associação `has_many :through`. Você só precisará usar esta opção se o nome da associação de origem não puder ser inferido automaticamente a partir do nome da associação.


##### :source_type

A opção `:source_type` especifica o tipo de associação de origem para uma associação `has_many :through` que prossegue através de uma associação polimórfica.

```ruby
class Author < ApplicationRecord
  has_many :books
  has_many :paperbacks, through: :books, source: :format, source_type: "Paperback"
end

class Book < ApplicationRecord
  belongs_to :format, polymorphic: true
end

class Hardback < ApplicationRecord; end
class Paperback < ApplicationRecord; end
```


##### :strict_loading

Quando definido como verdadeiro, impõe carregamento estrito sempre que o registro associado é carregado por meio desta associação.


##### :through

A opção `:through` especifica um modelo de junção através do qual realizar a consulta. As associações `has_many :through` fornecem uma maneira de implementar relacionamentos muitos-para-muitos, conforme discutido anteriormente neste guia .


##### :validate

Se você definir a opção `:validate` como `false`, os novos objetos associados não serão validados sempre que você salvar esse objeto. Por padrão, isto é `true`: novos objetos associados serão validados quando este objeto for salvo.


#### Escopos para `has_many`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `has_many`. Essas personalizações podem ser obtidas por meio de um bloco de escopo. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { where processed: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão dentro do bloco de escopo. Os seguintes são discutidos abaixo:

- `where`
- `extending`
- `group`
- `includes`
- `limit`
- `offset`
- `order`
- `readonly`
- `select`
- `distinct`


##### where

O método `where` permite especificar as condições que o objeto associado deve atender.

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where "confirmed = 1" },
    class_name: "Book"
end
```

Você também pode definir condições por meio de um hash:

```ruby
class Author < ApplicationRecord
  has_many :confirmed_books, -> { where confirmed: true },
    class_name: "Book"
end
```

Se você usar uma opção de estilo hash `where`, a criação de registros por meio dessa associação terá o escopo automaticamente definido usando o hash. Neste caso, usar `@author.confirmed_books.create` ou `@author.confirmed_books.build` criará livros onde a coluna confirmada possui o valor true.


##### extending

O método `extending` especifica um módulo nomeado para estender o proxy de associação. As extensões de associação são discutidas em detalhes posteriormente neste guia .


##### group

O método `group` fornece um nome de atributo para agrupar o conjunto de resultados, usando uma cláusula `GROUP BY` no SQL do localizador.

```ruby
class Author < ApplicationRecord
  has_many :chapters, -> { group 'books.id' },
                      through: :books
end
```


##### includes

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada. Por exemplo, considere estes modelos:

```ruby
class Author < ApplicationRecord
  has_many :books
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```

Se você recupera frequentemente capítulos diretamente dos autores (`@author.books.chapters`), então você pode tornar seu código um pouco mais eficiente incluindo capítulos na associação de autores a livros:

```ruby
class Author < ApplicationRecord
  has_many :books, -> { includes :chapters }
end

class Book < ApplicationRecord
  belongs_to :author
  has_many :chapters
end

class Chapter < ApplicationRecord
  belongs_to :book
end
```


##### limit

O método `limit` permite restringir o número total de objetos que serão buscados por meio de uma associação.

```ruby
class Author < ApplicationRecord
  has_many :recent_books,
    -> { order('published_at desc').limit(100) },
    class_name: "Book"
end
```


##### offset

O método `offset` permite especificar o deslocamento inicial para buscar objetos por meio de uma associação. Por exemplo, `-> { offset(11) }` irá pular os primeiros 11 registros.


##### order

O método `order` determina a ordem em que os objetos associados serão recebidos (na sintaxe usada por uma cláusula `ORDER BY` SQL).

```ruby
class Author < ApplicationRecord
  has_many :books, -> { order "date_confirmed DESC" }
end
```


##### readonly

Se você usar o método `readonly`, os objetos associados serão somente leitura quando recuperados por meio da associação.


##### select

O método `select` permite substituir a cláusula `SELECT` SQL usada para recuperar dados sobre os objetos associados. Por padrão, o Rails recupera todas as colunas.

![Active Record Association has_many - select](/imagens/active_record_associations24.JPG)



##### distinct

Use o método `distinct` para manter a coleção livre de duplicatas. Isso é mais útil junto com a opção `:through`.

```ruby
class Person < ApplicationRecord
  has_many :readings
  has_many :articles, through: :readings
end
```

```bash
irb> person = Person.create(name: 'John')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 5, name: "a1">, #<Article id: 5, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 12, person_id: 5, article_id: 5>, #<Reading id: 13, person_id: 5, article_id: 5>]
```

No caso acima há duas leituras e `person.articles` traz à tona ambas, embora esses registros apontem para o mesmo artigo.

Agora vamos definir distinct:

```ruby
class Person
  has_many :readings
  has_many :articles, -> { distinct }, through: :readings
end
```

```bash
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
irb> person.articles.to_a
=> [#<Article id: 7, name: "a1">]
irb> Reading.all.to_a
=> [#<Reading id: 16, person_id: 7, article_id: 7>, #<Reading id: 17, person_id: 7, article_id: 7>]
```

No caso acima ainda existem duas leituras. Porém `person.articles` mostra apenas um artigo porque a coleção carrega apenas registros únicos.

Se quiser ter certeza de que, após a inserção, todos os registros na associação persistente sejam distintos (para ter certeza de que, ao inspecionar a associação, você nunca encontrará registros duplicados), adicione um índice exclusivo em a própria mesa. Por exemplo, se você tiver uma tabela nomeada `readings` e quiser ter certeza de que os artigos só poderão ser adicionados a uma pessoa uma vez, você poderá adicionar o seguinte em uma migração:

```ruby
add_index :readings, [:person_id, :article_id], unique: true
```

Depois de ter esse índice exclusivo, tentar adicionar o artigo a uma pessoa duas vezes gerará um erro `ActiveRecord::RecordNotUnique`:

```bash
irb> person = Person.create(name: 'Honda')
irb> article = Article.create(name: 'a1')
irb> person.articles << article
irb> person.articles << article
ActiveRecord::RecordNotUnique
```

Observe que a verificação da exclusividade usando algo como `include?` está sujeita às condições de corrida. Não tente usar `include?` para impor distinção em uma associação. Por exemplo, usando o exemplo do artigo acima, o código a seguir seria atrevido porque vários usuários poderiam estar tentando fazer isso ao mesmo tempo:

```ruby
person.articles << article unless person.articles.include?(article)
```


#### Quando os objetos são salvos?

Quando você atribui um objeto a uma associação `has_many`, esse objeto é salvo automaticamente (para atualizar sua chave estrangeira). Se você atribuir vários objetos em uma instrução, todos eles serão salvos.

Se algum desses salvamentos falhar devido a erros de validação, a instrução de atribuição retornará `false` e a atribuição em si será cancelada.

Se o objeto pai (aquele que declara a associação `has_many`) não for salvo (ou seja, `new_record?` retornar `true`), os objetos filhos não serão salvos quando forem adicionados. Todos os membros não salvos da associação serão salvos automaticamente quando o pai for salvo.

Se você deseja atribuir um objeto a uma associação `has_many` sem salvar o objeto, use o método `collection.build`.


###  Referência de Associação `has_and_belongs_to_many`

A associação `has_and_belongs_to_many` cria um relacionamento muitos para muitos com outro modelo. Em termos de banco de dados, isso associa duas classes por meio de uma tabela de junção intermediária que inclui chaves estrangeiras referentes a cada uma das classes.


#### Métodos Adicionados por `has_and_belongs_to_many`

Quando você declara uma associação `has_and_belongs_to_many`, a classe declarante ganha automaticamente vários métodos relacionados à associação:

- `collection`
- `collection<<(object, ...)`
- `collection.delete(object, ...)`
- `collection.destroy(object, ...)`
- `collection=(objects)`
- `collection_singular_ids`
- `collection_singular_ids=(ids)`
- `collection.clear`
- `collection.empty?`
- `collection.size`
- `collection.find(...)`
- `collection.where(...)`
- `collection.exists?(...)`
- `collection.build(attributes = {})`
- `collection.create(attributes = {})`
- `collection.create!(attributes = {})`
- `collection.reload`

Em todos esses métodos, `collection` é substituído pelo símbolo passado como primeiro argumento para `has_and_belongs_to_many` e `collection_singular` é substituído pela versão singularizada desse símbolo. Por exemplo, dada a declaração:

```ruby
class Part < ApplicationRecord
  has_and_belongs_to_many :assemblies
end
```

Cada instância do `Part` modelo terá estes métodos:

```bash
assemblies
assemblies<<(object, ...)
assemblies.delete(object, ...)
assemblies.destroy(object, ...)
assemblies=(objects)
assembly_ids
assembly_ids=(ids)
assemblies.clear
assemblies.empty?
assemblies.size
assemblies.find(...)
assemblies.where(...)
assemblies.exists?(...)
assemblies.build(attributes = {}, ...)
assemblies.create(attributes = {})
assemblies.create!(attributes = {})
assemblies.reload
```


##### Métodos de Coluna Adicionais

Se a tabela de junção de uma associação `has_and_belongs_to_many` tiver colunas adicionais além das duas chaves estrangeiras, essas colunas serão adicionadas como atributos aos registros recuperados por meio dessa associação. Os registros retornados com atributos adicionais serão sempre somente leitura, porque o Rails não pode salvar alterações nesses atributo.


![Active Record Associations has_and_belongs_to_many - Colunas adicionais](/imagens/active_record_associations25.JPG)


##### collection

O método `collection` retorna uma relação de todos os objetos associados. Se não houver objetos associados, retorna uma Relação vazia.

```ruby
@assemblies = @part.assemblies
```


##### collection<<(object, ...)

O método `collection<<` adiciona um ou mais objetos à coleção criando registros na tabela de junção.

```ruby
@part.assemblies << @assembly1
```

![Active Record Associations has_and_belongs_to_many - collection<< ](/imagens/active_record_associations26.JPG)


##### collection.delete(object, ...)

O método `collection.delete` remove um ou mais objetos da coleção excluindo registros na tabela de junção. Isso não destrói os objetos.

```ruby
@part.assemblies.delete(@assembly1)
```


##### collection.destroy(object, ...)

O método `collection.destroy` remove um ou mais objetos da coleção excluindo registros na tabela de junção. Isso não destrói os objetos.

```ruby
@part.assemblies.destroy(@assembly1)
```


##### collection=(objects)

O método `collection=` faz com que a coleção contenha apenas os objetos fornecidos, adicionando e excluindo conforme apropriado. As alterações são persistidas no banco de dados.


##### collection_singular_ids

O método `collection_singular_ids` retorna um array dos ids dos objetos da coleção.

```ruby
@assembly_ids = @part.assembly_ids
```


##### collection_singular_ids=(ids)

O método `collection_singular_ids=` faz com que a coleção contenha apenas os objetos identificados pelos valores de chave primária fornecidos, adicionando e excluindo conforme apropriado. As alterações são persistidas no banco de dados.


##### collection.clear

O método `collection.clear` remove todos os objetos da coleção excluindo as linhas da tabela de junção. Isto não destrói os objetos associados.


##### collection.empty?

O método `collection.empty?` retorna truese a coleção não contiver nenhum objeto associado.

```ruby
<% if @part.assemblies.empty? %>
  This part is not used in any assemblies
<% end %>
```


##### collection.size

O método `collection.size` retorna o número de objetos na coleção.

```ruby
@assembly_count = @part.assemblies.size
```


##### collection.find(...)

O método `collection.find` encontra objetos na tabela da coleção.

```ruby
@assembly = @part.assemblies.find(1)
```


##### collection.where(...)

O método `collection.where` encontra objetos dentro da coleção com base nas condições fornecidas, mas os objetos são carregados lentamente, o que significa que o banco de dados é consultado apenas quando o(s) objeto(s) são acessados.

```ruby
@new_assemblies = @part.assemblies.where("created_at > ?", 2.days.ago)
```


##### collection.exists?(...)

O método `collection.exists?` verifica se existe um objeto que atenda às condições fornecidas na tabela da coleção.


##### collection.build(attributes = {})

O método `collection.build` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, e o link através da tabela de junção será criado, mas o objeto associado ainda não será salvo.

```ruby
@assembly = @part.assemblies.build({ assembly_name: "Transmission housing" })
```


##### collection.create(attributes = {})

O método `collection.create` retorna um novo objeto do tipo associado. Este objeto será instanciado a partir dos atributos passados, será criado o link através da tabela de junção e, uma vez aprovado em todas as validações especificadas no modelo associado, o objeto associado será salvo.

```ruby
@assembly = @part.assemblies.create({ assembly_name: "Transmission housing" })
```


##### collection.create!(attributes = {})
Faz o mesmo que `collection.create`, mas aumenta `ActiveRecord::RecordInvalid` se o registro for inválido.


##### collection.reload
O método `collection.reload` retorna uma Relação de todos os objetos associados, forçando a leitura do banco de dados. Se não houver objetos associados, retorna uma Relação vazia.

```ruby
@assemblies = @part.assemblies.reload
```


#### Opções para `has_and_belongs_to_many`

Embora o Rails use padrões inteligentes que funcionarão bem na maioria das situações, pode haver momentos em que você queira personalizar o comportamento da referência de associação `has_and_belongs_to_many`. Essas personalizações podem ser facilmente realizadas passando opções ao criar a associação. Por exemplo, esta associação usa duas dessas opções:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { readonly },
                                       autosave: true
end
```

A associação `has_and_belongs_to_many` apoia estas opções:

- `:association_foreign_key`
- `:autosave`
- `:class_name`
- `:foreign_key`
- `:join_table`
- `:strict_loading`
- `:validate`


##### :association_foreign_key

Por convenção, Rails assume que a coluna na tabela de junção usada para conter a chave estrangeira apontando para o outro modelo é o nome desse modelo com o sufixo _idadicionado. A opção `:association_foreign_key` permite definir o nome da chave estrangeira diretamente:

![Active Record Associations has_and_belongs_to_many - association_foreign_key](/imagens/active_record_associations27.JPG)

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```


##### :autosave

Se você definir a opção `:autosave` como true, o Rails salvará quaisquer membros da associação carregados e destruirá os membros marcados para destruição sempre que você salvar o objeto pai. Definir `:autosave` como `false` não é o mesmo que não definir a opção `:autosave`. Se a opção `:autosave` não estiver presente, os novos objetos associados serão salvos, mas os objetos associados atualizados não serão salvos.


##### :class_name

Se o nome do outro modelo não puder ser derivado do nome da associação, você poderá usar a opção `:class_name` para fornecer o nome do modelo. Por exemplo, se uma peça tiver muitas montagens, mas o nome real do modelo que contém as montagens for `Gadget`, você configuraria as coisas desta forma:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, class_name: "Gadget"
end
```


##### :foreign_key

Por convenção, Rails assume que a coluna na tabela de junção usada para conter a chave estrangeira que aponta para este modelo é o nome deste modelo com o sufixo `_id` adicionado. A opção `:foreign_key` permite definir o nome da chave estrangeira diretamente:

```ruby
class User < ApplicationRecord
  has_and_belongs_to_many :friends,
      class_name: "User",
      foreign_key: "this_user_id",
      association_foreign_key: "other_user_id"
end
```


##### :join_table

Se o nome padrão da tabela de junção, com base na ordem lexical, não for o desejado, você poderá usar a opção `:join_table` para substituir o padrão.


##### :strict_loading

Aplica o carregamento estrito sempre que um registro associado é carregado por meio desta associação.


##### :validate
Se você definir a opção `:validate` como `false`, os novos objetos associados não serão validados sempre que você salvar esse objeto. Por padrão, isto é `true`: novos objetos associados serão validados quando este objeto for salvo.


### Escopos para `has_and_belongs_to_many`

Pode haver momentos em que você deseja personalizar a consulta usada pelo `has_and_belongs_to_many`. Essas personalizações podem ser obtidas por meio de um bloco de escopo. Por exemplo:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { where active: true }
end
```

Você pode usar qualquer um dos métodos de consulta padrão dentro do bloco de escopo. Os seguintes são discutidos abaixo:

- `where`
- `extending`
- `group`
- `includes`
- `limit`
- `offset`
- `order`
- `readonly`
- `select`
- `distinct`


##### where

O método `where` permite especificar as condições que o objeto associado deve atender.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where "factory = 'Seattle'" }
end
```

Você também pode definir condições por meio de um hash:

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { where factory: 'Seattle' }
end
```

Se você usar um estilo hash `where`, a criação de registros por meio dessa associação terá o escopo automaticamente definido usando o hash. Neste caso, usar `@parts.assemblies.create` ou `@parts.assemblies.build` criará montagens onde a coluna `factory` possui o valor "Seattle".


##### extending

O método `extending` especifica um módulo nomeado para estender o proxy de associação. As extensões de associação são discutidas em detalhes posteriormente neste guia .


##### group
O método `group` fornece um nome de atributo para agrupar o conjunto de resultados, usando uma cláusula `GROUP BY` no SQL do localizador.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies, -> { group "factory" }
end
```


##### includes

Você pode usar o método `includes` para especificar associações de segunda ordem que devem ser carregadas antecipadamente quando essa associação for usada.


##### limit

O método `limit` permite restringir o número total de objetos que serão buscados por meio de uma associação.

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order("created_at DESC").limit(50) }
end
```


##### offset

O método `offset` permite especificar o deslocamento inicial para buscar objetos por meio de uma associação. Por exemplo, se você definir `offset(11)`, os primeiros 11 registros serão ignorados.


##### order

O método `order` determina a ordem em que os objetos associados serão recebidos (na sintaxe usada por uma cláusula `ORDER BY` SQL).

```ruby
class Parts < ApplicationRecord
  has_and_belongs_to_many :assemblies,
    -> { order "assembly_name ASC" }
end
```


##### readonly

Se você usar o método `readonly`, os objetos associados serão somente leitura quando recuperados por meio da associação.


##### select

O método `select` permite substituir a cláusula `SELECT` no SQL usada para recuperar dados sobre os objetos associados. Por padrão, o Rails recupera todas as colunas.


##### distinct
Use o distinctmétodo para remover duplicatas da coleção.


#### Quando os objetos são salvos?

Quando você atribui um objeto a uma associação `has_and_belongs_to_many`, esse objeto é salvo automaticamente (para atualizar a tabela de junção). Se você atribuir vários objetos em uma instrução, todos eles serão salvos.

Se algum desses salvamentos falhar devido a erros de validação, a instrução de atribuição retornará `false` e a atribuição em si será cancelada.

Se o objeto pai (aquele que declara a associação `has_and_belongs_to_many`) não for salvo (ou seja, `new_record?` retornar `true`), os objetos filhos não serão salvos quando forem adicionados. Todos os membros não salvos da associação serão salvos automaticamente quando o pai for salvo.

Se você deseja atribuir um objeto a uma associação `has_and_belongs_to_many` sem salvar o objeto, use o método `collection.build`.


### Retornos de chamada de associação

Os retornos de chamada normais se conectam ao ciclo de vida dos objetos do Active Record, permitindo que você trabalhe com esses objetos em vários pontos. Por exemplo, você pode usar um retorno de chamada `:before_save` para fazer com que algo aconteça logo antes de um objeto ser salvo.

Os retornos de chamada de associação são semelhantes aos retornos de chamada normais, mas são acionados por eventos no ciclo de vida de uma coleção. Existem quatro retornos de chamada de associação disponíveis:

- `before_add`
- `after_add`
- `before_remove`
- `after_remove`

Você define retornos de chamada de associação adicionando opções à declaração de associação. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books, before_add: :check_credit_limit

  def check_credit_limit(book)
    # ...
  end
end
```

Leia mais sobre retornos de chamada de associação no Guia de retornos de chamada do Active Record


### Extensões de Associação

Você não está limitado à funcionalidade que o Rails constrói automaticamente em objetos proxy de associação. Você também pode estender esses objetos por meio de módulos anônimos, adicionando novos localizadores, criadores ou outros métodos. Por exemplo:

```ruby
class Author < ApplicationRecord
  has_many :books do
    def find_by_book_prefix(book_number)
      find_by(category_id: book_number[0..2])
    end
  end
end
```

Se você tiver uma extensão que deve ser compartilhada por muitas associações, poderá usar um módulo de extensão nomeado. Por exemplo:

```ruby
module FindRecentExtension
  def find_recent
    where("created_at > ?", 5.days.ago)
  end
end

class Author < ApplicationRecord
  has_many :books, -> { extending FindRecentExtension }
end

class Supplier < ApplicationRecord
  has_many :deliveries, -> { extending FindRecentExtension }
end
```

As extensões podem referir-se aos componentes internos do proxy de associação usando estes três atributos do acessador `proxy_association`:

- `proxy_association.owner` retorna o objeto do qual a associação faz parte.
- `proxy_association.reflection` retorna o objeto de reflexão que descreve a associação.
- `proxy_association.target` retorna o objeto associado para belongs_toou has_oneou a coleção de objetos associados para has_manyou has_and_belongs_to_many.


### Escopo da Associação usando o Proprietário da Associação

O proprietário da associação pode ser passado como um argumento único para o bloco de escopo em situações em que você precisa de ainda mais controle sobre o escopo da associação. No entanto, como advertência, o pré-carregamento da associação não será mais possível.

```ruby
class Supplier < ApplicationRecord
  has_one :account, ->(supplier) { where active: supplier.active? }
end
```


## Herança de Tabela Única (STI)

Às vezes, você pode querer compartilhar campos e comportamentos entre diferentes modelos. Digamos que temos modelos de carro, motocicleta e bicicleta. Queremos compartilhar os campos `color` e `price` e alguns métodos para todos eles, mas tendo algum comportamento específico para cada um, e controladores separados também.

Primeiro, vamos gerar o modelo base do Veículo:

```bash
$ bin/rails generate model vehicle type:string color:string price:decimal{10.2}
```

Você notou que estamos adicionando um campo "tipo"? Como todos os modelos serão salvos em uma única tabela do banco de dados, o Rails salvará nesta coluna o nome do modelo que está sendo salvo. Em nosso exemplo, pode ser “Carro”, “Motocicleta” ou “Bicicleta”. O STI não funcionará sem um campo “tipo” na tabela.

A seguir, geraremos o modelo `Car` que herda de `Vehicle`. Para isso, podemos utilizar a opção `--parent=PARENT`, que irá gerar um modelo que herda do pai especificado e sem migração equivalente (visto que a tabela já existe).

Por exemplo, para gerar o modelo Carro:

```bash
$ bin/rails generate model car --parent=Vehicle
```

O modelo gerado ficará assim:

```ruby
class Car < Vehicle
end
```

Isso significa que todos os comportamentos adicionados ao Veículo também estão disponíveis para o Carro, como associações, métodos públicos, etc.

Criar um carro irá salvá-lo na tabela `vehicles` com "Carro" no campo `type`:

```bash
Car.create(color: 'Red', price: 10000)
```

irá gerar o seguinte SQL:

```bash
INSERT INTO "vehicles" ("type", "color", "price") VALUES ('Car', 'Red', 10000)
```

A consulta aos registros do carro pesquisará apenas veículos que sejam carros:

```ruby
Car.all
```

irá executar uma consulta como:

```sql
SELECT "vehicles".* FROM "vehicles" WHERE "vehicles"."type" IN ('Car')
```


## Tipos delegados

`Single Table Inheritance (STI)` funciona melhor quando há pouca diferença entre as subclasses e seus atributos, mas inclui todos os atributos de todas as subclasses necessárias para criar uma única tabela.

A desvantagem dessa abordagem é que ela resulta em um inchaço na tabela. Uma vez que incluirá até atributos específicos de uma subclasse que não são usados ​​por mais nada.

No exemplo a seguir, existem dois modelos Active Record que herdam da mesma classe "Entry" que inclui o atributo `subject`.

```ruby
# Schema: entries[ id, type, subject, created_at, updated_at]
class Entry < ApplicationRecord
end

class Comment < Entry
end

class Message < Entry
end
```

Os tipos delegados resolvem esse problema, via `delegated_type`.

Para usar tipos delegados, temos que modelar nossos dados de uma maneira específica. Os requisitos são os seguintes:

- Existe uma superclasse que armazena atributos compartilhados entre todas as subclasses de sua tabela.
- Cada subclasse deve herdar da superclasse e terá uma tabela separada para quaisquer atributos adicionais específicos dela.

Isso elimina a necessidade de definir atributos em uma única tabela que são compartilhados involuntariamente entre todas as subclasses.

Para aplicar isso ao nosso exemplo acima, precisamos regenerar nossos modelos. Primeiro, vamos gerar o modelo `Entry` base que atuará como nossa superclasse:

```bash
$ bin/rails generate model entry entryable_type:string entryable_id:integer
```

Em seguida, geraremos novos modelos `Message` e `Comment` para delegação:

```bash
$ bin/rails generate model message subject:string body:string
$ bin/rails generate model comment content:string
```

Depois de executar os geradores, devemos acabar com modelos parecidos com estes:

```ruby
# Schema: entries[ id, entryable_type, entryable_id, created_at, updated_at ]
class Entry < ApplicationRecord
end

# Schema: messages[ id, subject, body, created_at, updated_at ]
class Message < ApplicationRecord
end

# Schema: comments[ id, content, created_at, updated_at ]
class Comment < ApplicationRecord
end
```


### Declarardelegated_type

Primeiro, declare a `delegated_type` na superclasse `Entry`.

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
end
```

O parâmetro `entryable` especifica o campo a ser usado para delegação e inclui os tipos `Message` e `Comment` as classes delegadas.

A classe `Entry` possui `entryable_type` e campos `entryable_id`. Este é o campo com os sufixos `_type`, `_id` adicionados ao nome `entryable` na definição `delegated_type` . `entryable_type` armazena o nome da subclasse do delegado e `entryable_id` armazena o ID do registro da subclasse do delegado.

A seguir, devemos definir um módulo para implementar esses tipos delegados, declarando o parâmetro `as: :entryable` para a associação `has_one`.

```ruby
module Entryable
  extend ActiveSupport::Concern

  included do
    has_one :entry, as: :entryable, touch: true
  end
end
```

E então inclua o módulo criado em sua subclasse.

```ruby
class Message < ApplicationRecord
  include Entryable
end

class Comment < ApplicationRecord
  include Entryable
end
```

Com esta definição concluída, nosso delegador `Entry` agora fornece os seguintes métodos:

| Método |	Retornar |
| ------ | --------- |
| `Entry#entryable_class` | Mensagem ou Comentário |
| `Entry#entryable_name` |	"mensagem" ou "comentário" |
| `Entry.messages` |	Entry.where(entryable_type: "Message") |
| `Entry#message?` |	Retorna verdadeiro quandoentryable_type == "Message" |
| `Entry#message` |	Retorna o registro da mensagem, quando entryable_type == "Message", caso contrárionil |
| `Entry#message_id` |	Retorna entryable_id, quando entryable_type == "Message", caso contrárionil |
| `Entry.comments` |	Entry.where(entryable_type: "Comment") |
| `Entry#comment?` |	Retorna verdadeiro quandoentryable_type == "Comment" |
| `Entry#comment` |	Retorna o registro do comentário, quando entryable_type == "Comment", caso contrárionil |
| `Entry#comment_id` |	Retorna entryable_id, quando entryable_type == "Comment", caso contrárionil |


### Criação de objetos

Ao criar um novo objeto `Entry`, podemos especificar a subclasse `entryable` ao mesmo tempo.

```bash
Entry.create! entryable: Message.new(subject: "hello!")
```


### Adicionando mais delegação

Podemos expandir nosso delegador `Entry` e aprimorá-lo ainda mais definindo `delegate` e usando polimorfismo nas subclasses. Por exemplo, para delegar o método `title` `Entry` para suas subclasses:

```ruby
class Entry < ApplicationRecord
  delegated_type :entryable, types: %w[ Message Comment ]
  delegate :title, to: :entryable
end

class Message < ApplicationRecord
  include Entryable

  def title
    subject
  end
end

class Comment < ApplicationRecord
  include Entryable

  def title
    content.truncate(20)
  end
end
```