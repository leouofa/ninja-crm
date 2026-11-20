class Category < ApplicationRecord
  has_many :leads, dependent: :restrict_with_error
  has_one :template, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :ordered, -> { order(:name) }
end
