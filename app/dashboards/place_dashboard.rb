require "administrate/base_dashboard"

class PlaceDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    address_1: Field::String,
    address_2: Field::String,
    city: Field::String,
    zip: Field::String,
    lat: Field::String,
    long: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    categories: Field::String,
    google_id: Field::String,
    types: Field::String,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :name,
    :address_1,
    :address_2,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :name,
    :address_1,
    :address_2,
    :city,
    :zip,
    :lat,
    :long,
    :created_at,
    :updated_at,
    :categories,
    :google_id,
    :types,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :name,
    :address_1,
    :address_2,
    :city,
    :zip,
    :lat,
    :long,
    :categories,
    :google_id,
    :types,
  ].freeze

  # Overwrite this method to customize how places are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(place)
  #   "Place ##{place.id}"
  # end
end
