# class VcardController < ApplicationController
# 	def card
# 		vcard = VCardigan.create
# 		vcard.name 'Meetable'
# 		vcard.fullname 'Meetable.ai'
# 		vcard.tel '6467599030'
# 		vcard[:item1].url 'https://meetable.ai'
# 		send_data vcard.to_s, :filename => "meetable.vcf"
# 	end
# end
#require 'base64'

class VcardController < ApplicationController
  # after_filter :set_content_type
#6467599030
	def card
		vcard_template = File.open(File.join(Rails.root, "public/vcard_template.txt"), "rb").read
		vcard = vcard_template.sub! 'REPLACE_PHONE_NUMBER', params[:relay]
		send_data vcard, :filename => "meetable.vcf"
		# ##imgencoded = Base64.encode64(File.open(File.join(Rails.root, "public/m2.jpg"), "rb").read)
		# vcard = VCardigan.create(:version => '3.0')
		# vcard.name 'Meetable', ''
		# vcard.fullname 'Meetable.ai'
		# vcard.tel '6467599030'
		# vcard[:item1].url 'https://www.meetable.ai'
		# ##vcard.photo 'https://meetable-api-prime.herokuapp.com/m2.jpg', :type => 'JPEG', :value => 'URI'
		# ##vcard.photo imgencoded, :ENCODING => 'BASE64;JPEG'
		# send_data vcard.to_s, :filename => "meetable.vcf"
	end

# 	def set_content_type
# 		self.content_type = "text/x-vcard; charset=utf-8"
# #    	self.content_type = "application/foo; bar=1; charset=utf-8"
#   	end
end

 
