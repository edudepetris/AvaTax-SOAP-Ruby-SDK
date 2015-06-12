require_relative '../lib/avatax_addressservice.rb'
#require 'Avatax_AddressService'

accountNumber = "1234567890"
licenseKey = "A1B2C3D4E5F6G7H8"
serviceURL = "https://development.avalara.net"

# Header Level Parameters
addressSvc = AvaTax::AddressService.new(

# Required Header Parameters
  :username => accountNumber, 
  :password => licenseKey,  
  :service_url => serviceURL,
  :clientname => "AvaTaxSample",

# Optional Header Parameters  
  :name => "Development") 

pingResult = addressSvc.ping

#Display the result
puts "PingTest ResultCode: " + pingResult[:result_code]
if pingResult[:result_code] != "Success"
	puts pingResult.to_s
  pingResult[:messages].each { |message| puts message[:details] }
end