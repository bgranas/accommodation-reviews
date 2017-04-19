class HwImage < ApplicationRecord

	validates_uniqueness_of :imageURL
end
