#Load the Avalara Address Service module
require 'avatax_taxservice' 
#Load the Avalara Address Service module - optional
require 'avatax_addressservice' 

#Create an tax service instance
username = 'USERNAME'   #Your user account number or name here
password = 'PASSWORD'   #The password that was e-mailed to you here
name = 'Avalara Inc.'
clientname = 'MyShoppingCart'
adapter = 'Avatax SDK for Ruby 1.0.1'
machine = 'Lenovo W520 Windows 7'
TaxServ = AvaTax::TaxService.new(username,password,name,clientname,adapter,machine) 

#Create an address service instance - optional
AddrService = AvaTax::AddressService.new(username,password,name,clientname,adapter,machine)

#Populate the fields required by the GetTax call
companycode = 'API TrialCompany'    #Same as the company code you set in the Admin console
doctype = "SalesInvoice"            #The type of document you want to process
doccode = "MyDocCode"               #Your doc code (e.g. invoice number)
docdate = "2013-10-11"              #The date on the document
salespersoncode = "Bill Sales"      #Optional sales person 
customercode = "CUS001"             #Customer code
customerusagetype = ""              #Usage type
discount = ".0000"                  #Discount amount
purchaseorderno = "PO123456"        #PO number
exemptionno = ""                    #Exemption number
origincode = "123"                  #Origin or ship from code - you make it up 
destinationcode = "456"             #Destination or ship to code - you make it up 
#Pass addresses as an array
#  <AddressCode>123</AddressCode>
#  <Line1>100 Ravine Lane</Line1>
#  <Line2/>
#  <Line3/>
#  <City>Bainbridge Island</City>
#  <Region>WA</Region>
#  <PostalCode>98110</PostalCode>
#  <Country>US</Country>
#  <TaxRegionId>0</TaxRegionId>
#  <Latitude/>
#  <Longitude/>
addresses = [
  ["123", "100 ravine lane", "", "","Bainbridge Island","WA","98110","US","0","",""],
  ["456", "7070 West Arlington Drive", "", "","Lakewood","CO","80123","US","0","",""]
  ]
#Pass order/invoice lines as an array
# <No>1</No>
# <OriginCode></OriginCode>
# <DestinationCode></DestinationCode>
# <ItemCode>Canoe</ItemCode>
# <TaxCode></TaxCode>
# <Qty>1</Qty>
# <Amount>300</Amount>
# <Discounted>false</Discounted>
# <RevAcct></RevAcct>
# <Ref1>ref1</Ref1>
# <Ref2>ref2</Ref2>
# <ExemptionNo></ExemptionNo>
# <CustomerUsageType></CustomerUsageType>
# <Description>Blue canoe</Description>
# <TaxOverrideType>TaxAmount</TaxOverrideType>
# <TaxAmount>10</TaxAmount>
# <TaxDate>1900-01-01</TaxDate>
# <Reason>Tax Credit</Reason>
# <TaxIncluded>false</TaxIncluded>
# <BusinessIdentificationNo></BusinessIdentificationNo>
lines = [
  ["1","","","Canoe","","1","300.43","false","","ref1","ref2","","","Blue canoe","TaxAmount","10","1900-01-01","Tax credit","false",""],
  ["2","","","Rowing boat","","1","800.12","false","","ref3","ref4","","","Red rowing boat","None",".0000","1900-01-01","","false",""]
]
detaillevel = "Tax"                 #The level of detail you want returned by the service
referencecode = ""                  #Reference code - used for returns
hashcode = "0"                      #Set to 0
locationcode = ""                   #Store Location, Outlet Id, or Outlet code.
commit = "false"                    #Invoice will be committed if this flag has been set to true.
batchcode = ""                      #Optional Batch Code
taxoverridetype = "None"            #Type of TaxOverride
taxamount = ".0000"                 #The TaxAmount overrides the total tax for the document, if not 0
taxdate = "1900-01-01"              #Tax Date is the date used to calculate tax
reason = ""                         #Reason for applying TaxOverride.
currencycode = "USD"                #3 character ISO 4217 currency code (for example, USD) 
servicemode = "Remote"              #All lines are calculated by AvaTax remote server
paymentdate = "2013-09-26"          #Indicates the date payment was applied to this invoice
exchangerate = ".0000"              #Indicates the currency exchange rate
exchangerateeffdate = "1900-01-01"  #Indicates the effective date of the exchange rate.
poslanecode = ""                    #Optional POS Lane Code
businessidentificationno = ""       #Optional Business Identification Number
debug = false                       #Run in debug move - writes data to tax_log.txt
validate = false                    #Performs address validation before calculating tax - needs address service installed

#Create empty hash for the tax result details 
tax_result = {}
tax_result = TaxServ.gettax(companycode,
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

#Print out the returned hash
require 'pp'
pp tax_result
puts

#Always check the result code
 if tax_result[:ResultCode] = "Success" then
   puts "The GetTax call was successful"
 else
   puts "The GetTax call failed"
 end

puts
#Convert a hash value to Floating point
tt = tax_result[:GetTaxResultTotalTax].at(0).to_f
puts "Total tax = #{tt}"

#Use the size method to determine the no of entries associated with a symbol
puts tax_result[:TaxDetailTaxName].size

#Data elements begin at 0
puts tax_result[:TaxDetailTaxName][0]
puts tax_result[:TaxDetailTaxName][1]

tax_result[:TaxDetailJurisType].each do |type|
  puts type
end

#Example of extracting the tax breakdown per line
no_of_lines = tax_result[:TaxLineNo].size
no_of_jurisdictions = tax_result[:TaxDetailCountry].size / no_of_lines
i = 0
while i < no_of_lines
  puts
  puts "Line = #{tax_result[:TaxLineNo][i]}"
  j = 0
  while j < no_of_jurisdictions
    puts "Jurisdiction #{j+1} = #{tax_result[:TaxDetailJurisName][j]}"
    puts "Tax name = #{tax_result[:TaxDetailTaxName][j]}"
    puts "Taxable amount = #{tax_result[:TaxDetailBase][j]}"
    puts "Tax rate = #{tax_result[:TaxDetailRate][j]}"
    puts "Tax calculated = #{tax_result[:TaxDetailTaxCalculated][j]}"
    puts
    j += 1
  end      
  i += 1
end















    
    