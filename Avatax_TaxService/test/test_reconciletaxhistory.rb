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
# Determine whether the DEV or PROD service is used. false = DEV  true = PROD
credentials[:use_production_account] = false

#Create a tax service instance
TaxServ = AvaTax::TaxService.new(credentials)

document[:companycode] = 'APITrialCompany'
document[:lastdocid] = '99999999'
document[:reconciled] = false
document[:startdate] = '2013-01-01'
document[:enddate] = '2013-10-15'
document[:docstatus] = "Any"
document[:doctype] = 'SalesInvoice'
document[:lastdoccode] = ''
document[:pagesize] = '1'
document[:debug] = true

#Create empty hash for the tax result details 
tax_result = Hash.new

#Call the gettax service
tax_result = TaxServ.reconciletaxhistory(document)

require 'pp'
pp tax_result





















    
    