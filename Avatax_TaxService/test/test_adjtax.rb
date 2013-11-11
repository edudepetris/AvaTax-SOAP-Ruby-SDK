#Load the Avalara Address Service module
require 'avatax_taxservice' 
#Load the Avalara Address Service module
require 'avatax_addressservice' 

#Create an tax service instance
username = 'USERNAME'   #Your user account number or name here
password = 'PASSWORD'   #The password that was e-mailed to you here
name = 'Avalara Inc.'
clientname = 'MyShoppingCart'
adapter = 'Avatax SDK for Ruby 1.0.1'
machine = 'Lenovo W520 Windows 7'
TaxServ = AvaTax::TaxService.new(username,password,name,clientname,adapter,machine) 

#Create an address service instance
AddrService = AvaTax::AddressService.new(username,password,name,clientname,adapter,machine)

adjustmentreason = "5"
adjustmentdescription = "Hey I adjusted the tax"
companycode = 'APITrialCompany'
doctype = "SalesInvoice"
doccode = "MyTest01"
docdate = "2013-10-11"
salespersoncode = "Bob Sales"
customercode = "CUS001"
customerusagetype = ""
discount = ".0000"
purchaseorderno = "PO999999"
exemptionno = ""
origincode = "123"
destinationcode = "456"
addresses = []
lines = []
detaillevel = "Tax"
referencecode = ""
hashcode = "0"
locationcode = ""
commit = "true"
batchcode = ""
taxoverridetype = "None"
taxamount = ".0000"
taxdate = "1900-01-01"
reason = ""
currencycode = "USD"
servicemode = "Remote"
paymentdate = "2013-09-26"
exchangerate = ".0000"
exchangerateeffdate = "1900-01-01"
poslanecode = ""
businessidentificationno = ""
debug = true
validate = false

addresses = [
  ["123", "100 ravine lane", "", "","Bainbridge Island","WA","98110","US","0","",""],
  ["456", "1S278 Wenmoth", "", "","Batavia","IL","60510","US","0","",""]
  ]

lines = [["1","","","Canoe","","1","300","false","","ref1","ref2","","","Blue canoe","None",".0000","1900-01-01","","false",""],
["2","","","Rowing boat","","1","800","false","","ref3","ref4","","","Red rowing boat","None",".0000","1900-01-01","","false",""]
]

tax_result = {}
#Call the gettax service
tax_result = TaxServ.adjusttax(adjustmentreason,
                  adjustmentdescription,
                  companycode,
                  doctype,
                  doccode,
                  docdate,
                  salespersoncode,
                  customercode,
                  customerusagetype,
                  discount,
                  purchaseorderno,
                  exemptionno,
                  origincode,
                  destinationcode,
                  addresses,
                  lines,
                  detaillevel,
                  referencecode,
                  hashcode,
                  locationcode,
                  commit,
                  batchcode,
                  taxoverridetype,
                  taxamount,
                  taxdate,
                  reason,
                  currencycode,
                  servicemode,
                  paymentdate,
                  exchangerate,
                  exchangerateeffdate,
                  poslanecode,
                  businessidentificationno,
                  debug,
                  validate) 

require 'pp'
pp tax_result












    
    