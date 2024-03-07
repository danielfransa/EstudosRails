# Active Record Callbacks

## O Ciclo de Vida do Objeto

Durante a operação normal de uma aplicação Rails, objetos podem ser criados, atualizados e destruídos. O Active Record fornece ganchos para esse ciclo de vida do objeto para que você possa controlar seu aplicativo e seus dados.

Os retornos de chamada permitem acionar a lógica antes ou depois de uma alteração no estado de um objeto.

```ruby
class Baby < ApplicationRecord
  after_create -> { puts "Congratulations!" }
end
```

```bash
irb> @baby = Baby.create
Congratulations!
```

Como você verá, há muitos eventos no ciclo de vida e você pode optar por se conectar a qualquer um deles antes, depois ou mesmo próximo a eles.


## Visão geral dos retornos de chamada

Callbacks são métodos chamados em determinados momentos do ciclo de vida de um objeto. Com callbacks é possível escrever código que será executado sempre que um objeto Active Record for criado, salvo, atualizado, excluído, validado ou carregado do banco de dados.


### Registro de retorno de chamada

Para utilizar os retornos de chamada disponíveis, você precisa registrá-los. Você pode implementar os retornos de chamada como métodos comuns e usar um método de classe estilo macro para registrá-los como retornos de chamada:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.blank?
        self.login = email unless email.blank?
      end
    end
end
```

Os métodos de classe estilo macro também podem receber um bloco. Considere usar este estilo se o código dentro do seu bloco for tão curto que caiba em uma única linha:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

Alternativamente, você pode passar um proc para que o retorno de chamada seja acionado.

```ruby
class User < ApplicationRecord
  before_create ->(user) { user.name = user.login.capitalize if user.name.blank? }
end
```

Por último, você pode definir seu próprio objeto de retorno de chamada personalizado, que abordaremos mais tarde com mais detalhes .

```ruby
class User < ApplicationRecord
  before_create MaybeAddName
end

class MaybeAddName
  def self.before_create(record)
    if record.name.blank?
      record.name = record.login.capitalize
    end
  end
end
```

Os retornos de chamada também podem ser registrados para serem acionados apenas em determinados eventos do ciclo de vida, o que permite controle total sobre quando e em que contexto seus retornos de chamada são acionados.

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on takes an array as well
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

É considerada uma boa prática declarar métodos de retorno de chamada como privados. Se deixados públicos, eles podem ser chamados de fora do modelo e violar o princípio do encapsulamento de objetos.

![Aviso sobre chamadas Callback](/imagens/acitive_record_callbacks1.JPG)


## retornos de chamada disponíveis

Aqui está uma lista com todos os retornos de chamada do Active Record disponíveis, listados na mesma ordem em que serão chamados durante as respectivas operações:


### Criando um Objeto

- `before_validation`
- `after_validation`
- `before_save`
- `around_save`
- `before_create`
- `around_create`
- `after_create`
- `after_save`
- `after_commit/after_rollback`

### Atualizando um Objeto

- `before_validation`
- `after_validation`
- `before_save`
- `around_save`
- `before_update`
- `around_update`
- `after_update`
- `after_save`
- `after_commit/after_rollback`

![Aviso Callbacks After_save](/imagens/acitive_record_callbacks2.JPG)


### Destruindo um Objeto

- `before_destroy`
- `around_destroy`
- `after_destroy`
- `after_commit/after_rollback`

![Aviso callback destroy](/imagens/acitive_record_callbacks3.JPG)


### after_initialize e after_find

Sempre que um objeto Active Record for instanciado, `after_initialize` o retorno de chamada será chamado, seja usando diretamente `new` ou quando um registro for carregado do banco de dados. Pode ser útil evitar a necessidade de substituir diretamente o método `initialize` Active Record.

Ao carregar um registro do banco de dados o callback `after_find` será chamado. `after_find` é chamado antes `after_initialize` se ambos estiverem definidos.

![Aviso callback after*](/imagens/acitive_record_callbacks4.JPG)

Eles podem ser registrados da mesma forma que os outros retornos de chamada do Active Record.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
  end
end
```

```bash
irb> User.new
You have initialized an object!
=> #<User id: nil>

irb> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

### after_touch

O retorno `after_touch` de chamada será chamado sempre que um objeto Active Record for tocado.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end
```

```bash
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
You have touched an object
=> true
```

Pode ser usado junto com `belongs_to`:

```ruby
class Book < ApplicationRecord
  belongs_to :library, touch: true
  after_touch do
    puts 'A Book was touched'
  end
end

class Library < ApplicationRecord
  has_many :books
  after_touch :log_when_books_or_library_touched

  private
    def log_when_books_or_library_touched
      puts 'Book/Library was touched'
    end
end
```

```bash
irb> @book = Book.last
=> #<Book id: 1, library_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @book.touch # triggers @book.library.touch
A Book was touched
Book/Library was touched
=> true
```

## Retornos de chamada em execução

Os seguintes métodos acionam retornos de chamada:

- `create`
- `create!`
- `destroy`
- `destroy!`
- `destroy_all`
- `destroy_by`
- `save`
- `save!`
- `save(validate: false)`
- `save!(validate: false)`
- `toggle!`
- `touch`
- `update_attribute`
- `update`
- `update!`
- `valid?`

Além disso, o retorno `after_find` de chamada é acionado pelos seguintes métodos de localização:

- `all`
- `first`
- `find`
- `find_by`
- `find_by_*`
- `find_by_*!`
- `find_by_sql`
- `last`

O retorno `after_initialize` de chamada é acionado sempre que um novo objeto da classe é inicializado.

![Aviso Active Record Calback](/imagens/active_record_callbacks5.JPG)

##  Ignorando retornos de chamada

Assim como nas validações, também é possível pular retornos de chamada usando os seguintes métodos:

- `decrement!`
- `decrement_counter`
- `delete`
- `delete_all`
- `delete_by`
- `increment!`
- `increment_counter`
- `insert`
- `insert!`
- `insert_all`
- `insert_all!`
- `touch_all`
- `update_column`
- `update_columns`
- `update_all`
- `update_counters`
- `upsert`
- `upsert_all`

Entretanto, esses métodos devem ser usados ​​com cautela, pois importantes regras de negócios e lógica de aplicação podem ser mantidas em retornos de chamada. Ignorá-los sem compreender as implicações potenciais pode levar a dados inválidos.


## Parando a Execução

À medida que você começa a registrar novos retornos de chamada para seus modelos, eles serão colocados na fila para execução. Esta fila incluirá todas as validações do seu modelo, os callbacks registrados e a operação do banco de dados a ser executada.

Toda a cadeia de retorno de chamada está envolvida em uma transação. Se algum retorno de chamada gerar uma exceção, a cadeia de execução será interrompida e um ROLLBACK será emitido. Para interromper intencionalmente o uso de uma corrente:

```ruby
throw :abort
```

![Aviso Active Record Callback interrupções](/imagens/active_record_callbacks6.JPG)


## Retornos de chamada relacionais

Os retornos de chamada funcionam por meio de relacionamentos de modelo e podem até ser definidos por eles. Suponha um exemplo em que um usuário tenha muitos artigos. Os artigos de um usuário devem ser destruídos se o usuário for destruído. Vamos adicionar um retorno `after_destroy` de chamada ao modelo `User` por meio de seu relacionamento com o modelo `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end
```

```bash
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
Article destroyed
=> #<User id: 1>
```


## Retornos de chamada de associação

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

Rails passa o objeto que está sendo adicionado ou removido para o retorno de chamada.

Você pode empilhar retornos de chamada em um único evento, passando-os como um array:

```ruby
class Author < ApplicationRecord
  has_many :books,
    before_add: [:check_credit_limit, :calculate_shipping_charges]

  def check_credit_limit(book)
    # ...
  end

  def calculate_shipping_charges(book)
    # ...
  end
end
```

Se um retorno `before_add` de chamada for lançado `:abort`, o objeto não será adicionado à coleção. Da mesma forma, se um retorno `before_remove` de chamada for lançado `:abort`, o objeto não será removido da coleção:

```ruby
# book won't be added if the limit has been reached
def check_credit_limit(book)
  throw(:abort) if limit_reached?
end
```

![Aviso Active Record Callback](/imagens/active_record_callbacks7.JPG)

```ruby
# Triggers `before_add` callback
author.books << book
author.books = [book, book2]

# Does not trigger the `before_add` callback
book.update(author_id: 1)
```


## Retornos de chamada condicionais

Assim como acontece com as validações, também podemos condicionar a chamada de um método de retorno de chamada à satisfação de um determinado predicado. Podemos fazer isso usando as opções `:if` e `:unless`, que podem receber um `símbolo`, uma `Proc` ou um `Array`.

Você pode usar a opção `:if` quando quiser especificar sob quais condições o retorno de chamada deve ser chamado. Se quiser especificar as condições sob as quais o retorno de chamada não deve ser chamado, você pode usar a opção `:unless`.


### Usando `:if` e `:unless` com um `Symbol`

Você pode associar as opções `:if` e `:unless` a um símbolo correspondente ao nome de um método predicado que será chamado logo antes do retorno de chamada.

Ao usar a opção `:if`, o retorno de chamada **não** será executado se o método predicado retornar **false**; ao usar a opção `:unless`, o retorno de chamada **não** será executado se o método predicado retornar **true** . Esta é a opção mais comum.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

Utilizando esta forma de cadastro também é possível cadastrar diversos predicados diferentes que devem ser chamados para verificar se o callback deve ser executado. Abordaremos isso abaixo .


### Usando `:if` e `:unless` com um Proc

É possível associar `:if` e `:unless`a um objeto `Proc`. Esta opção é mais adequada ao escrever métodos de validação curtos, geralmente de uma linha:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

Como o proc é avaliado no contexto do objeto, também é possível escrever isso como:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```


### Múltiplas Condições de Retorno de Chamada

As opções `:if` e `:unless` também aceitam uma matriz de procs ou nomes de métodos como símbolos:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, :untrusted_author?]
end
```

Você pode incluir facilmente um proc na lista de condições:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: [:subject_to_parental_control?, Proc.new { untrusted_author? }]
end
```

### Usando ambos `:if` e `:unless`

Os retornos de chamada podem misturar ambos `:if` e `:unless` na mesma declaração:

```ruby
class Comment < ApplicationRecord
  before_save :filter_content,
    if: Proc.new { forum.parental_control? },
    unless: Proc.new { author.trusted? }
end
```

O retorno de chamada só é executado quando todas as condições `:if` e nenhuma delas `:unless` são avaliadas como true.


## Aulas de retorno de chamada

