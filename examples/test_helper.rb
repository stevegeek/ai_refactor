require "rails/all"
require "active_support/testing/autorun"

class MyModel
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks

  validates :name, presence: true

  attribute :name, :string
  attribute :age, :integer
end
