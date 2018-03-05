class VcardController < ApplicationController
	def card
		vcard = VCardigan.create
		vcard.name 'Meetable'
		vcard.tel '6467599030'
		vcard.fullname 'Meetable.ai'
		vcard[:item1].url 'https://meetable.ai'
		send_data vcard.to_s, :filename => "meetable.vcf"
	end
end

