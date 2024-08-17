class Aluno < ApplicationRecord
  validates :nome, :telefone, :matricula, presence: true
end
