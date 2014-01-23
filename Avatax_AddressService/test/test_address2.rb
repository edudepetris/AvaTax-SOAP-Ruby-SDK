 #Load the Avalara Address Service module
require 'avatax_addressservice'


#Create new Credentials hash object
credentials = Hash.new

#Create new Address hash object
address = Hash.new

credentials[:username] = 'USERNAME'
credentials[:password] = 'PASSWORD'

credentials[:name] = 'Avalara Inc.'
credentials[:clientname] = 'MyShoppingCart'
credentials[:adapter] = 'Avatax SDK for Ruby 1.0.5'
credentials[:machine] = 'Lenovo W520 Windows 7'
credentials[:use_production_account] = false
#Create an address service instance
AddrService = AvaTax::AddressService.new(credentials)
 
address[:line1] = '100 ravine lane'
address[:city] = 'bainbridge island'
address[:region] =  'wa'
address[:postalcode] = '98110'
address[:country]= 'us'
address[:textcase] = 'Upper'
address[:addresscode] = "123"
   
puts address        
#Call the validate service - passing the address as a Hash
val_addr = AddrService.validate(address)

require 'pp'
pp val_addr


          
 

