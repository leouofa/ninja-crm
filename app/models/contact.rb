class Contact < ApplicationRecord
  has_one :lead, dependent: :destroy

  validates :name, presence: true

  scope :ordered, -> { order(:name) }
  scope :without_lead, -> { where.missing(:lead) }
  scope :search, ->(query) {
    return all if query.blank?

    q = "%#{sanitize_sql_like(query.strip)}%"
    where("name ILIKE :q OR email ILIKE :q OR company ILIKE :q OR role ILIKE :q", q: q)
  }
end
