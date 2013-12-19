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

tax_result = [] 
#Call the gettax service
tax_result = TaxServ.reconciletaxhistory(document)

require 'pp'
pp tax_result

#Calculate the number od docs returned
no_recs = tax_result.size - 2
puts no_recs

#Print out the document details
i = 0
while i <= no_recs
  puts tax_result[:GetTaxResultDocId][i]
  puts tax_result[:GetTaxResultDocType][i]
  puts tax_result[:GetTaxResultDocDate][i]
  puts tax_result[:GetTaxResultTotalAmount][i]
  puts tax_result[:GetTaxResultTotalTax][i]
  puts
  i += 1      
end




















    
    