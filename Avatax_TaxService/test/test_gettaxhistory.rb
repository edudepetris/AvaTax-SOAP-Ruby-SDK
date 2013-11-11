#Load the Avalara Address Service module
require 'avatax_taxservice' 

#Create an tax service instance
username = 'USERNAME'   #Your user account number or name here
password = 'PASSSWORD'   #The password that was e-mailed to you here
name = 'Avalara Inc.'
clientname = 'MyShoppingCart'
adapter = 'Avatax SDK for Ruby 1.0.1'
machine = 'Lenovo W520 Windows 7'
TaxServ = AvaTax::TaxService.new(username,password,name,clientname,adapter,machine)


docid = "99999999"
companycode = 'APITrialCompany'
doctype = "SalesInvoice"
doccode = ""
detaillevel = "Line"
debug = false

tax_result = {}
#Call the gettax service
tax_result = TaxServ.gettaxhistory(docid,
                  companycode,
                  doctype,
                  doccode,
                  detaillevel,
                  debug)


require 'pp'
pp tax_result
















    
    