#Load the Avalara Address Service module
require 'avatax_taxservice' 

#Create an tax service instance
username = 'USERNAME'     #Your user account number or name here
password = 'PASSWORD'   #The password that was e-mailed to you here
name = 'Avalara Inc.'
clientname = 'MyShoppingCart'
adapter = 'Avatax SDK for Ruby 1.0.1'
machine = 'Lenovo W520 Windows 7'
TaxServ = AvaTax::TaxService.new(username,password,name,clientname,adapter,machine)

companycode = 'APITrialCompany'
lastdocid = "99999999"
reconciled = false
startdate = '2013-01-01'
enddate = "2013-10-15"
docstatus = "Any"
doctype = "SalesInvoice"
lastdoccode =""
pagesize ="1"
debug = true

tax_result = [] 
#Call the gettax service
tax_result = TaxServ.reconciletaxhistory(companycode,
                  lastdocid,
                  reconciled,
                  startdate,
                  enddate,
                  docstatus,
                  doctype,
                  lastdoccode,
                  pagesize,
                  debug)


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




















    
    