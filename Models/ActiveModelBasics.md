# Active Model Basics

## O que é modelo ativo?

Active Model é uma biblioteca que contém diversos módulos utilizados no desenvolvimento de classes que necessitam de alguns recursos presentes no Active Record. Alguns desses módulos são explicados abaixo.


### API

`ActiveModel::API` adiciona a capacidade de uma classe trabalhar com Action Pack e Action View imediatamente.

```ruby
class EmailContact
  include ActiveModel::API

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

Ao incluir `ActiveModel::API` você obtém alguns recursos como:

- introspecção do nome do modelo
- conversões
- traduções
- validações

Também oferece a capacidade de inicializar um objeto com um hash de atributos, como qualquer objeto Active Record.

```ruby
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Qualquer classe que inclua `ActiveModel::API` pode ser usada com `form_with` e `render` quaisquer outros métodos auxiliares do Action View, assim como os objetos Active Record.


### Métodos de Atributos

O módulo `ActiveModel::AttributeMethods` pode adicionar prefixos e sufixos personalizados nos métodos de uma classe. É usado para definir os prefixos e sufixos e quais métodos no objeto os utilizarão.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end
```

```ruby
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
```


### Retornos de chamada

`ActiveModel::Callbacks` fornece retornos de chamada no estilo Active Record. Isso fornece a capacidade de definir retornos de chamada que são executados em momentos apropriados. Depois de definir os retornos de chamada, você pode envolvê-los com métodos personalizados antes, depois e em torno.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # This method is called when update is called on an object.
    end
  end

  def reset_me
    # This method is called when update is called on an object as a before_update callback is defined.
  end
end
```


### Conversão

Se uma classe define métodos `persisted?` `id`, então você pode incluir o módulo `ActiveModel::Conversion` nessa classe e chamar os métodos de conversão do Rails nos objetos dessa classe.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end
```

```ruby
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
```


### Sujo

Um objeto fica sujo (dirty) quando passou por uma ou mais alterações em seus atributos e não foi salvo. `ActiveModel::Dirty` dá a capacidade de verificar se um objeto foi alterado ou não. Ele também possui métodos acessadores baseados em atributos. Vamos considerar uma classe `Person` com atributos `first_name` e `last_name`:

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # do save work...
    changes_applied
  end
end
```


#### Consultando um objeto diretamente para obter sua lista de todos os atributos alterados

```ruby
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# Returns true if any of the attributes have unsaved changes.
irb> person.changed?
=> true

# Returns a list of attributes that have changed before saving.
irb> person.changed
=> ["first_name"]

# Returns a Hash of the attributes that have changed with their original values.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Returns a Hash of changes, with the attribute names as the keys, and the values as an array of the old and new values for that field.
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### Métodos de acesso baseados em atributos

Acompanhe se o atributo específico foi alterado ou não.

```ruby
irb> person.first_name
=> "First Name"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

Acompanhe o valor anterior do atributo.

```ruby
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

Acompanhe os valores anteriores e atuais do atributo alterado. Retorna um array se alterado, caso contrário retorna nulo.

```ruby
# attr_name_change
irb> person.first_name_change
=> [nil, "First Name"]
irb> person.last_name_change
=> nil
```


### Validações

O módulo `ActiveModel::Validations` adiciona a capacidade de validar objetos como no Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```ruby
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
```


### Nomenclatura

`ActiveModel::Naming` adiciona vários métodos de classe que facilitam o gerenciamento de nomenclatura e roteamento. O módulo define o método `model_name`  de classe que definirá vários acessadores usando alguns métodos `ActiveSupport::Inflector`.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```


### Modelo

`ActiveModel::Model` permite implementar modelos semelhantes ao `ActiveRecord::Base`.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

Ao incluir `ActiveModel::Model` você obtém todos os recursos do `ActiveModel::API`.


### Serialização

`ActiveModel::Serialization` fornece serialização básica para seu objeto. Você precisa declarar um Hash de atributos que contenha os atributos que deseja serializar. Os atributos devem ser strings, não símbolos.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

Agora você pode acessar um Hash serializado do seu objeto usando o serializable_hashmétodo.

```ruby
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
```


#### ActiveModel::Serializadores

O Active Model também fornece o módulo `ActiveModel::Serializers::JSON` para serialização/desserialização JSON. Este módulo inclui automaticamente o módulo discutido anteriormente ActiveModel::Serialization.


#####  ActiveModel::Serializadores::JSON

Para usar `ActiveModel::Serializers::JSON` você só precisa alterar o módulo que está incluindo de `ActiveModel::Serialization` para `ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    { 'name' => nil }
  end
end
```

O método `as_json`, semelhante a `serializable_hash`, fornece um Hash que representa o modelo.

```ruby
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

Você também pode definir os atributos de um modelo a partir de uma sequência JSON. No entanto, você precisa definir o método `attributes=` na sua classe:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    { 'name' => nil }
  end
end
```

Agora é possível criar uma instância `Person`e definir atributos usando `from_json`.

```ruby
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
```


### Tradução

`ActiveModel::Translation` fornece integração entre seu objeto e a estrutura de internacionalização Rails (i18n).

```ruby
class Person
  extend ActiveModel::Translation
end
```

Com o método `human_attribute_name`, você pode transformar nomes de atributos em um formato mais legível. O formato legível por humanos é definido em seus arquivos de localidade.

- config/locales/app.pt-BR.yml

```yml
pt-BR:
  activemodel:
    attributes:
      person:
        name: 'Nome'
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint Tests

`ActiveModel::Lint::Tests` permite testar se um objeto é compatível com a API Active Model.

- app/models/person.rb

```ruby
class Person
  include ActiveModel::Model
end
```

- test/models/person_test.rb

```ruby
require "test_helper"

class PersonTest < ActiveSupport::TestCase
  include ActiveModel::Lint::Tests

  setup do
    @model = Person.new
  end
end
```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Não é necessário um objeto para implementar todas as APIs para funcionar com o Action Pack. Este módulo pretende apenas orientar caso você queira todos os recursos prontos para uso.


### Senha Segura

`ActiveModel::SecurePassword` fornece uma maneira de armazenar com segurança qualquer senha de forma criptografada. Quando você inclui este módulo, `has_secure_password` é fornecido um método de classe que define um acessador `password` com certas validações por padrão.



#### Requisitos

`ActiveModel::SecurePassword` depende `bcrypt`, então inclua esta gem no seu `Gemfile` para usar `ActiveModel::SecurePassword` corretamente. Para que isso funcione, o modelo deve ter um acessador chamado `XXX_digest`. Onde `XXX` é o nome do atributo da senha desejada. As seguintes validações são adicionadas automaticamente:

- 1 - A senha deve estar presente.

- 2 - A senha deverá ser igual à sua confirmação (desde que `XXX_confirmation` habilitado).

- 3 - O comprimento máximo de uma senha é de 72 bytes (obrigatório porque bcrypt, do qual `ActiveModel::SecurePassword` depende, trunca a string para esse tamanho antes de criptografá-la).


#### Exemplos

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end
```

```ruby
irb> person = Person.new

# When password is blank.
irb> person.valid?
=> false

# When the confirmation doesn't match the password.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# When the length of password exceeds 72.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# When only password is supplied with no password_confirmation.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# When all validations are passed.
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```

