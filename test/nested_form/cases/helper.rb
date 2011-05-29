require 'action_view'
require 'nested_form'
require 'client_side_validations/nested_form'

# Copied from NestedForm's test suite.
class TablelessModel < ActiveRecord::Base
  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  def self.quoted_table_name
    name.pluralize.underscore
  end

  def quoted_id
    "0"
  end
end

class Project < TablelessModel
  column :title, :string
  has_many :tasks
  accepts_nested_attributes_for :tasks
  attr_accessible :title, :tasks_attributes
  validates_presence_of :title
end

class Task < TablelessModel
  column :project_id, :integer
  column :name, :string
  belongs_to :project
  validates_presence_of :name
end
