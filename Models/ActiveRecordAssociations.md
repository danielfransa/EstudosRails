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

