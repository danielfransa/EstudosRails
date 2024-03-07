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

