require_relative '../lib/avatax_taxservice.rb'
#require 'Avatax_TaxService'

accountNumber = "1234567890"
licenseKey = "A1B2C3D4E5F6G7H8"
serviceURL = "https://development.avalara.net"

# Header Level Parameters
taxSvc = AvaTax::TaxService.new(

# Required Header Parameters
  :username => accountNumber, 
  :password => licenseKey,  
  :service_url => serviceURL,
  :clientname => "AvaTaxSample",

# Optional Header Parameters  
  :name => "Development") 

cancelTaxRequest = {
    # Required Request Parameters
    :companycode => "APITrialCompany",
    :doctype => "SalesInvoice",
    :doccode => "INV001",
    :cancelcode => "DocVoided"
    }

cancelTaxResult = taxSvc.canceltax(cancelTaxRequest)

# Print Results
puts "CancelTaxTest ResultCode: "+cancelTaxResult[:result_code]
if cancelTaxResult[:result_code] != "Success"
  cancelTaxResult[:messages].each { |message| puts message[:details] }
end