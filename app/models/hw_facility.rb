class HwFacility < ApplicationRecord
	belongs_to :hw_property
	validates_uniqueness_of :hw_property_id, scope: :facility
end
