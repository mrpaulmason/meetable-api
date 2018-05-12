class VcardController < ApplicationController
	def card
		# relay number passed into endpoint and populated in vCard
		vcard_template = File.open(File.join(Rails.root, "public/vcard_template.txt"), "rb").read
		vcard = vcard_template.sub! 'REPLACE_PHONE_NUMBER', params[:relay]
		send_data vcard, :filename => "meetable.vcf"
	end

end
