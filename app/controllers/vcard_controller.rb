class VcardController < ApplicationController
	def card
		vcard = VCardigan.create
		vcard.name 'Meetable'
		vcard.fullname 'Meetable.ai'
		vcard.tel '6467599030'
		vcard[:item1].url 'https://meetable.ai'
		send_data vcard.to_s, :filename => "meetable.vcf"
	end
end

