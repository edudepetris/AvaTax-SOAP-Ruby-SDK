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

document[:docid] = "99999999" 
document[:companycode] = 'APITrialCompany'
document[:doctype] = 'SalesInvoice'
document[:doccode] = ""    
document[:detaillevel] = "Line"
document[:debug] = false

#Create empty hash for the tax result details 
tax_result = Hash.new

#Call the gettax service
tax_result = TaxServ.gettaxhistory(document)

require 'pp'
pp tax_result
















    
    