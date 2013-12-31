#Load the Avalara Address Service module
require 'avatax_taxservice' 

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

#Create a tax service instance
TaxServ = AvaTax::TaxService.new(credentials) 

#Populate the fields required by the GetTax call
document[:companycode] = 'APITrialCompany'
document[:doctype] = 'SalesInvoice'
document[:doccode] = "MyDocCode"    
document[:cancelcode] = "DocVoided" 
document[:debug] = false                    #Run in debug move - writes data to tax_log.txt

#Create empty hash for the tax result details 
tax_result = Hash.new

#Call the tax service
tax_result = TaxServ.canceltax(document) 

require 'pp'
pp tax_result












    
    