class MtUser < ActiveRecord::Base

	# has_one  :setting, foreign_key: :user_id
  	# has_many :pn_tokens
    has_many :invites, dependent: :destroy
    has_many :merchants, :through => :invites, source: :company, source_type: 'Merchant'
    has_many :affiliates, :through => :invites, source: :company, source_type: 'Affiliate'

#   -------------

    def companies
		merchants.where(active: true) + affiliates.where(active: true)
    end

	def merchants
		if self.admin?
			Merchant.all
		else
			super.where(active: true)
		end
	end

	def affiliates
		if self.admin?
			Affiliate.all
		else
			super.where(active: true)
		end
	end

#   -------------

	def name
    	if self.last_name.blank?
    	  "#{self.first_name}"
    	else
    	  "#{self.first_name} #{self.last_name}"
    	end
	end

    def get_photo
		if self.photo
			self.photo
		else
            nil
		end
	end

end

# == Schema Information
#
# Table name: mt_users
#
#  id                  :integer         not null, primary key
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  phone               :string(255)
#  sex                 :string(255)
#  birthday            :date
#  password_digest     :string(255)
#  remember_token      :string(255)     not null
#  admin               :boolean         default(FALSE)
#  confirm             :integer         default(0)
#  reset_token_sent_at :datetime
#  reset_token         :string(255)
#  active              :boolean         default(TRUE)
#  db_user_id          :integer
#  address             :string(255)
#  city                :string(255)
#  state               :string(2)
#  zip                 :string(16)
#  facebook_id         :string(255)
#  twitter             :string(255)
#  photo               :string(255)
#  min_photo           :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  affiliate_id        :integer
#

# autosave_associated_records_for_setting
# autosave_associated_records_for_pn_tokens
# validate_associated_records_for_pn_tokens
# before_add_for_pn_tokens
# before_add_for_pn_tokens?
# before_add_for_pn_tokens=
# after_add_for_pn_tokens
# after_add_for_pn_tokens?
# after_add_for_pn_tokens=
# before_remove_for_pn_tokens
# before_remove_for_pn_tokens?
# before_remove_for_pn_tokens=
# after_remove_for_pn_tokens
# after_remove_for_pn_tokens?
# after_remove_for_pn_tokens=
# autosave_associated_records_for_invites
# validate_associated_records_for_invites
# before_add_for_invites
# before_add_for_invites?
# before_add_for_invites=
# after_add_for_invites
# after_add_for_invites?
# after_add_for_invites=
# before_remove_for_invites
# before_remove_for_invites?
# before_remove_for_invites=
# after_remove_for_invites
# after_remove_for_invites?
# after_remove_for_invites=
# autosave_associated_records_for_merchants
# validate_associated_records_for_merchants
# before_add_for_merchants
# before_add_for_merchants?
# before_add_for_merchants=
# after_add_for_merchants
# after_add_for_merchants?
# after_add_for_merchants=
# before_remove_for_merchants
# before_remove_for_merchants?
# before_remove_for_merchants=
# after_remove_for_merchants
# after_remove_for_merchants?
# after_remove_for_merchants=
# merchants
# get_photo
# setting
# setting=
# build_setting
# create_setting
# create_setting!
# pn_tokens
# pn_token_ids
# pn_tokens=
# pn_token_ids=
# invites
# invite_ids
# invites=
# invite_ids=
# merchant_ids
# merchants=
# merchant_ids=
# id
# id=
# id_before_type_cast
# id?
# id_changed?
# id_change
# id_will_change!
# id_was
# reset_id!
# first_name
# first_name=
# first_name_before_type_cast
# first_name?
# first_name_changed?
# first_name_change
# first_name_will_change!
# first_name_was
# reset_first_name!
# last_name
# last_name=
# last_name_before_type_cast
# last_name?
# last_name_changed?
# last_name_change
# last_name_will_change!
# last_name_was
# reset_last_name!
# email
# email=
# email_before_type_cast
# email?
# email_changed?
# email_change
# email_will_change!
# email_was
# reset_email!
# phone
# phone=
# phone_before_type_cast
# phone?
# phone_changed?
# phone_change
# phone_will_change!
# phone_was
# reset_phone!
# sex
# sex=
# sex_before_type_cast
# sex?
# sex_changed?
# sex_change
# sex_will_change!
# sex_was
# reset_sex!
# birthday
# birthday=
# birthday_before_type_cast
# birthday?
# birthday_changed?
# birthday_change
# birthday_will_change!
# birthday_was
# reset_birthday!
# password_digest
# password_digest=
# password_digest_before_type_cast
# password_digest?
# password_digest_changed?
# password_digest_change
# password_digest_will_change!
# password_digest_was
# reset_password_digest!
# remember_token
# remember_token=
# remember_token_before_type_cast
# remember_token?
# remember_token_changed?
# remember_token_change
# remember_token_will_change!
# remember_token_was
# reset_remember_token!
# admin
# admin=
# admin_before_type_cast
# admin?
# admin_changed?
# admin_change
# admin_will_change!
# admin_was
# reset_admin!
# confirm
# confirm=
# confirm_before_type_cast
# confirm?
# confirm_changed?
# confirm_change
# confirm_will_change!
# confirm_was
# reset_confirm!
# reset_token_sent_at
# reset_token_sent_at=
# reset_token_sent_at_before_type_cast
# reset_token_sent_at?
# reset_token_sent_at_changed?
# reset_token_sent_at_change
# reset_token_sent_at_will_change!
# reset_token_sent_at_was
# reset_reset_token_sent_at!
# reset_token
# reset_token=
# reset_token_before_type_cast
# reset_token?
# reset_token_changed?
# reset_token_change
# reset_token_will_change!
# reset_token_was
# reset_reset_token!
# active
# active=
# active_before_type_cast
# active?
# active_changed?
# active_change
# active_will_change!
# active_was
# reset_active!
# db_user_id
# db_user_id=
# db_user_id_before_type_cast
# db_user_id?
# db_user_id_changed?
# db_user_id_change
# db_user_id_will_change!
# db_user_id_was
# reset_db_user_id!
# address
# address=
# address_before_type_cast
# address?
# address_changed?
# address_change
# address_will_change!
# address_was
# reset_address!
# city
# city=
# city_before_type_cast
# city?
# city_changed?
# city_change
# city_will_change!
# city_was
# reset_city!
# state
# state=
# state_before_type_cast
# state?
# state_changed?
# state_change
# state_will_change!
# state_was
# reset_state!
# zip
# zip=
# zip_before_type_cast
# zip?
# zip_changed?
# zip_change
# zip_will_change!
# zip_was
# reset_zip!
# facebook_id
# facebook_id=
# facebook_id_before_type_cast
# facebook_id?
# facebook_id_changed?
# facebook_id_change
# facebook_id_will_change!
# facebook_id_was
# reset_facebook_id!
# twitter
# twitter=
# twitter_before_type_cast
# twitter?
# twitter_changed?
# twitter_change
# twitter_will_change!
# twitter_was
# reset_twitter!
# photo
# photo=
# photo_before_type_cast
# photo?
# photo_changed?
# photo_change
# photo_will_change!
# photo_was
# reset_photo!
# min_photo
# min_photo=
# min_photo_before_type_cast
# min_photo?
# min_photo_changed?
# min_photo_change
# min_photo_will_change!
# min_photo_was
# reset_min_photo!
# created_at
# created_at=
# created_at_before_type_cast
# created_at?
# created_at_changed?
# created_at_change
# created_at_will_change!
# created_at_was
# reset_created_at!
# updated_at
# updated_at=
# updated_at_before_type_cast
# updated_at?
# updated_at_changed?
# updated_at_change
# updated_at_will_change!
# updated_at_was
# reset_updated_at!
# affiliate_id
# affiliate_id=
# affiliate_id_before_type_cast
# affiliate_id?
# affiliate_id_changed?
# affiliate_id_change
# affiliate_id_will_change!
# affiliate_id_was
# reset_affiliate_id!
# defined_enums
# defined_enums?
# defined_enums=
# logger
# default_timezone
# schema_format
# timestamped_migrations
# dump_schema_after_migration
# default_connection_handler
# default_connection_handler?
# primary_key_prefix_type
# table_name_prefix
# table_name_prefix?
# table_name_suffix
# table_name_suffix?
# pluralize_table_names
# pluralize_table_names?
# store_full_sti_class
# store_full_sti_class?
# default_scopes
# cache_timestamp_format
# cache_timestamp_format?
# validation_context
# validation_context=
# _validate_callbacks
# _validate_callbacks?
# _validate_callbacks=
# _validators
# _validators?
# _validators=
# lock_optimistically
# lock_optimistically?
# attribute_aliases
# attribute_aliases?
# attribute_method_matchers
# attribute_method_matchers?
# attribute_types_cached_by_default
# attribute_types_cached_by_default?
# time_zone_aware_attributes
# skip_time_zone_conversion_for_attributes
# skip_time_zone_conversion_for_attributes?
# partial_writes
# partial_writes?
# _validation_callbacks
# _validation_callbacks?
# _validation_callbacks=
# _initialize_callbacks
# _initialize_callbacks?
# _initialize_callbacks=
# _find_callbacks
# _find_callbacks?
# _find_callbacks=
# _touch_callbacks
# _touch_callbacks?
# _touch_callbacks=
# _save_callbacks
# _save_callbacks?
# _save_callbacks=
# _create_callbacks
# _create_callbacks?
# _create_callbacks=
# _update_callbacks
# _update_callbacks?
# _update_callbacks=
# _destroy_callbacks
# _destroy_callbacks?
# _destroy_callbacks=
# record_timestamps
# record_timestamps?
# record_timestamps=
# nested_attributes_options
# nested_attributes_options?
# _commit_callbacks
# _commit_callbacks?
# _commit_callbacks=
# _rollback_callbacks
# _rollback_callbacks?
# _rollback_callbacks=
# _reflections
# _reflections?
# _reflections=
# aggregate_reflections
# aggregate_reflections?
# aggregate_reflections=
# include_root_in_json
# include_root_in_json?
# include_root_in_json=
# _ransackers
# _ransackers?
# _ransackers=
# next
# prev
# read_store_attribute
# write_store_attribute
# serializable_hash
# to_xml
# from_xml
# from_json
# read_attribute_for_serialization
# no_touching?
# touch
# transaction
# destroy
# save
# save!
# rollback_active_record_state!
# committed!
# rolledback!
# add_to_transaction
# with_transaction_returning_status
# remember_transaction_record_state
# clear_transaction_record_state
# restore_transaction_record_state
# transaction_record_state
# transaction_include_any_action?
# clear_aggregation_cache
# _destroy
# reload
# mark_for_destruction
# marked_for_destruction?
# destroyed_by_association=
# destroyed_by_association
# changed_for_autosave?
# clear_association_cache
# association_cache
# association
# run_validations!
# changed?
# changed
# changes
# previous_changes
# changed_attributes
# attribute_changed?
# attribute_was
# to_key
# attribute_method?
# query_attribute
# read_attribute_before_type_cast
# attributes_before_type_cast
# raw_write_attribute
# read_attribute
# method_missing
# has_attribute?
# attribute_names
# attributes
# attributes_for_coder
# attribute_for_inspect
# attribute_present?
# column_for_attribute
# []
# []=
# clone_attributes
# clone_attribute_value
# arel_attributes_with_values_for_create
# arel_attributes_with_values_for_update
# attribute_missing
# respond_to_without_attributes?
# lock!
# with_lock
# locking_enabled?
# valid?
# perform_validations
# validates_absence_of
# validates_acceptance_of
# validates_confirmation_of
# validates_exclusion_of
# validates_format_of
# validates_inclusion_of
# validates_length_of
# validates_size_of
# validates_numericality_of
# validates_presence_of
# run_callbacks
# errors
# invalid?
# read_attribute_for_validation
# validates_with
# cache_key
# to_model
# to_partial_path
# assign_attributes
# attributes=
# sanitize_for_mass_assignment
# sanitize_forbidden_attributes
# quoted_id
# populate_with_current_scope_attributes
# new_record?
# destroyed?
# persisted?
# delete
# destroy!
# becomes
# becomes!
# update_attribute
# update
# update_attributes
# update!
# update_attributes!
# update_column
# update_columns
# increment
# increment!
# decrement
# decrement!
# toggle
# toggle!
# init_with
# encode_with
# readonly?
# readonly!
# connection_handler
# slice
# set_transaction_state
# has_transactional_callbacks?
