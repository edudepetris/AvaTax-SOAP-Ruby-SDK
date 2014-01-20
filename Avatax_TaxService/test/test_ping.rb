#Load the Avalara Address Service module
require 'avatax_taxservice' 
require 'pp'

#Create new credentials hash object
credentials = Hash.new

#Create new document hash object
document = Hash.new

credentials[:username] = 'USERNAME'
credentials[:password] = 'PASSWORD'
credentials[:name] = 'Avalara Inc.'
credentials[:clientname] = 'MyShoppingCart'
credentials[:adapter] = 'Avatax SDK for Ruby 1.0.6'
credentials[:machine] = 'Lenovo W520 Windows 7'
# Determine whether the DEV or PROD service is used. false = DEV  true = PROD
credentials[:use_production_account] = false

#Create a tax service instance
TaxServ = AvaTax::TaxService.new(credentials) 

#Populate the fields required by the PostTax call
document[:message] = 'APITrialCompany'
document[:debug] = true                    #Run in debug move - writes data to tax_log.txt

#Create empty hash for the tax result details 
tax_result = Hash.new

#Call the tax service
tax_result = TaxServ.ping(document) 

pp tax_result

puts "Result code = #{tax_result[:result_code]}"
puts "Summary = #{tax_result[:summary]}"
puts "Details = #{tax_result[:details]}"
puts "Faultstring = #{tax_result[:fault][:faultstring]}"














    
    