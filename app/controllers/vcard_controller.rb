class VcardController < ApplicationController
	def card
		vcard = VCardigan.create
		vcard.name 'Meetable'
		vcard.phone '6467599030'
		vcard.fullname 'Meetable.ai'
		vcard.photo 'https://media.licdn.com/mpr/mpr/shrinknp_100_100/AAEAAQAAAAAAAAbnAAAAJDFmOTJkNjc2LTZhZWYtNDAxMS04Nzc4LWU1YTFmNjZiMzhiNQ.jpg', :type => 'uri'
		vcard[:item1].url 'https://meetable.ai'
		send_data vcard.to_s, :filename => "meetable.vcf"
	end
end

