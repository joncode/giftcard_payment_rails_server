class ClientContent < ActiveRecord::Base
	self.table_name = 'contents'

#	-------------

	validates :content_id, uniqueness: { scope: [:content_type, :client_id] }, if: Proc.new { |a| a.client_id.present? }
	validates :content_id, uniqueness: { scope: [:content_type, :partner_id, :partner_type] }, if: Proc.new { |a| a.client_id.nil? }

#	-------------

	belongs_to :client
	belongs_to :content, polymorphic: true
	belongs_to :partner, polymorphic: true

end
