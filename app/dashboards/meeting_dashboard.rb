require "administrate/base_dashboard"

class MeetingDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    id: Field::Number,
    location_type: Field::String,
    share_code: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    datetime: Field::DateTime,
    date_time: Field::DateTime,
    nickname: Field::String,
    relay_number: Field::String,
    confirmation_code: Field::Number,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :id,
    :location_type,
    :share_code,
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = [
    :user,
    :id,
    :location_type,
    :share_code,
    :created_at,
    :updated_at,
    :datetime,
    :date_time,
    :nickname,
    :relay_number,
    :confirmation_code,
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :location_type,
    :share_code,
    :datetime,
    :date_time,
    :nickname,
    :relay_number,
    :confirmation_code,
  ].freeze

  # Overwrite this method to customize how meetings are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(meeting)
  #   "Meeting ##{meeting.id}"
  # end
end
