class Lead < ApplicationRecord
  belongs_to :contact
  belongs_to :category

  enum :status, {
    backlog: "backlog",
    in_progress: "in_progress",
    done: "done",
    archived: "archived"
  }, default: :backlog, validate: true

  STATUS_LABELS = {
    "backlog" => "Backlog",
    "in_progress" => "In-Progress",
    "done" => "Done",
    "archived" => "Archived"
  }.freeze

  STATUS_COLORS = {
    "backlog" => "bg-amber-100 text-amber-800 border-amber-200",
    "in_progress" => "bg-blue-100 text-blue-800 border-blue-200",
    "done" => "bg-emerald-100 text-emerald-800 border-emerald-200",
    "archived" => "bg-slate-100 text-slate-700 border-slate-200"
  }.freeze

  validates :contact_id, uniqueness: true

  attr_accessor :new_category_name
  before_validation :assign_new_category, if: -> { new_category_name.present? }

  scope :recent, -> { order(updated_at: :desc) }
  scope :active, -> { where.not(status: :archived) }
  scope :archived, -> { where(status: :archived) }

  def status_label
    STATUS_LABELS[status] || status.titleize
  end

  private

  def assign_new_category
    self.category = Category.find_or_create_by!(name: new_category_name.strip)
  end
end
