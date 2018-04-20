require "administrate/base_dashboard"

class MessageDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    to: Field::String,
    from: Field::String,
    message: Field::String,
    media_url: Field::String,
    send_at: Field::DateTime,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    sent: Field::Boolean,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :to,
    :from,
    :message,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :id,
    :to,
    :from,
    :message,
    :media_url,
    :send_at,
    :created_at,
    :updated_at,
    :sent,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :to,
    :from,
    :message,
    :media_url,
    :send_at,
    :sent,
  ].freeze

  # Overwrite this method to customize how messages are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(message)
  #   "Message ##{message.id}"
  # end
end
