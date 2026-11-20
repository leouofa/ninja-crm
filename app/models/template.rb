class Template < ApplicationRecord
  belongs_to :category

  validates :category_id, uniqueness: { message: "already has a template" }
  validates :body, presence: true

  attr_accessor :new_category_name
  before_validation :assign_new_category, if: -> { new_category_name.present? }

  scope :ordered_by_category, -> { joins(:category).order("categories.name ASC") }

  private

  def assign_new_category
    self.category = Category.find_or_create_by!(name: new_category_name.strip)
  end
end
