require "administrate/base_dashboard"

class RelayDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    number: Field::String,
    active: Field::Boolean,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    released: Field::Boolean
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :number,
    :created_at,
    :released,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :number,
    :active,
    :created_at,
    :updated_at,
    :released,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :number,
    :released,
  ].freeze

  # Overwrite this method to customize how relays are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(relay)
  #   "Relay ##{relay.id}"
  # end
end
