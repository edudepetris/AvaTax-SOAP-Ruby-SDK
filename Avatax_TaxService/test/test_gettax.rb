#Load the Avalara Address Service module
require 'avatax_taxservice' 
#Load the Avalara Address Service module - optional
require 'avatax_addressservice' 

#Create new credentials hash object
credentials = Hash.new

#Create new document hash object
document = Hash.new

#Create new address hash object
address = Hash.new

credentials[:username] = 'grahamw'
credentials[:password] = 'Avalara1!'
credentials[:name] = 'Avalara Inc.'
credentials[:clientname] = 'MyShoppingCart'
credentials[:adapter] = 'Avatax SDK for Ruby 1.0.6'
credentials[:machine] = 'Lenovo W520 Windows 7'

#Create a tax service instance
TaxServ = AvaTax::TaxService.new(credentials) 

#Create an address service instance
AddrService = AvaTax::AddressService.new(credentials)

#Populate the fields required by the GetTax call
document[:companycode] = '1'
document[:doctype] = 'SalesInvoice'
document[:doccode] = "MyDocCode"    
document[:docdate] = "2013-10-11" 
document[:salespersoncode] = "Bill Sales" 
document[:customercode] = "CUS001"
document[:customerusagetype] = ""    
document[:discount] = ".0000"             
document[:purchaseorderno]= "PO123456"
document[:exemptionno] = ""
document[:origincode] = "123"     
document[:destinationcode] = "456"

#Pass addresses as an array of hashes
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
document[:addresses]= [
  {:addresscode => "123",:line1 => "100 ravine lane", :line2 => "Suite 21",:city => "Bainbridge Island",:region => "WA",:postalcode => "98110",:country => "US",:taxregionid => "0",:latitude => "",:longitude => ""},
  {:addresscode => "456",:line1 => "7070 West Arlington Drive",:city => "Lakewood",:region => "CO",:postalcode => "80123",:country => "US",:taxregionid => "0"}
  ]

#Pass order/invoice lines as an array of hashes
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
document[:lines] = [
  {:no => "1",:itemcode => "Canoe",:qty => "1",:amount => "300.43",:discounted => "false",:ref1 => "ref1",:ref2 => "ref2",:description => "Blue canoe",:taxoverridetypeline => "TaxAmount",:taxamountline => "10",:taxdateline => "1900-01-01",:reasonline => "Tax credit",:taxincluded => "false"},
  {:no => "2",:itemcode => "Rowing boat",:qty => "1",:amount => "800.12",:discounted => "false",:ref1 => "ref3",:ref2 => "ref4",:description => "Red rowing boat",:taxoverridetypeline => "None",:taxamountline => "0",:taxdateline => "1900-01-01",:taxincluded => "false"}
]
document[:detaillevel] = "Tax"                 #The level of detail you want returned by the service     
document[:referencecode] = ""                  #Reference code - used for returns
document[:hashcode] = "0"                      #Set to 0
document[:locationcode] = ""                   #Store Location, Outlet Id, or Outlet code.
document[:commit] = "false"                    #Invoice will be committed if this flag has been set to true.
document[:batchcode] = ""                      #Optional Batch Code
document[:taxoverridetype] = "None"            #Type of TaxOverride  
document[:taxamount]= ".0000"                  #The TaxAmount overrides the total tax for the document, if not 0
document[:taxdate] = "1900-01-01"              #Tax Date is the date used to calculate tax
document[:reason] = ""                         #Reason for applying TaxOverride. = ""
document[:currencycode] = "USD"                #3 character ISO 4217 currency code (for example, USD) 
document[:servicemode] = "Remote"              #All lines are calculated by AvaTax remote server
document[:paymentdate] = "2013-09-26"          #Indicates the date payment was applied to this invoice
document[:exchangerate] = ".0000"              #Indicates the currency exchange rate
document[:exchangerateeffdate] = "1900-01-01"  #Indicates the effective date of the exchange rate.
document[:poslanecode] = ""                    #Optional POS Lane Code
document[:businessidentificationno] = ""       #Optional Business Identification Number
document[:debug] = true                       #Run in debug move - writes data to tax_log.txt
document[:validate]= false                     #If true - addresses will be validated before the tax call 


#Create empty hash for the tax result details 
tax_result = Hash.new

#Call the tax service
tax_result = TaxServ.gettax(document) 

#Print out the returned hash
require 'pp'
pp tax_result
puts

#Always check the result code
 if tax_result[:ResultCode] == ["Success"]
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