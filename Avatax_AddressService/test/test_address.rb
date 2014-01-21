 #Load the Avalara Address Service module
require 'avatax_addressservice'
#require green_shoes for the GUI
require 'green_shoes'

#Create new Credentials hash object
credentials = Hash.new

#Create new Address hash object
address = Hash.new
val_addr = Hash.new

Shoes.app :width => 400, :height => 460 do
  background orange
  border("#BE8",
  strokewidth: 6)
  stack(margin: 15) do
    para
    para "Enter Avalara credentials"
    para "Username:"
    @username = edit_line text: "USERNAME"
    para "Password:"
    @password = edit_line text: "PASSWORD", :secret => true
    para "Test Production:"
    @use_production_account = edit_line text: "false" 
    para
    @confirm = button "Confirm"
    para
    @confirm.click { 
      credentials[:username] = @username.text
      credentials[:password] = @password.text
      credentials[:name] = 'Avalara Inc.'
      credentials[:clientname] = ''
      credentials[:adapter] = ''
      credentials[:machine] = 'Lenovo W520 Windows 7'
      if @use_production_account.text == 'true' then
       credentials[:use_production_account] = !!@use_production_account
      else
       credentials[:use_production_account] = nil 
      end
       
      #Create an address service instance
      AddrService = AvaTax::AddressService.new(credentials)
      
      #Open a window to get the address to validate
      Shoes.app :width => 400, :height => 700, :title => "Avalara - Address Validation Tester" do
  
        #Set window characteristics
        background green..orange
  
        #Get the address to validate from the user
        stack :margin => 10 do
          #Get user input
          para "Line 1:"
          @line1 = edit_line text: "100 rav"  
          para "Line 2:"
          @line2 = edit_line
          para "Line 3:"
          @line3 = edit_line
          para "City"
          @city = edit_line width: 100, text: "bainbridge" 
          para "State" 
          @state = edit_line width: 40, text: 'WA' 
          para "Zip"
          @zip = edit_line width: 60, text: "98110" 
          para "Country"
          @country = edit_line width: 30, text: "US"
          para "Textcase"
          @textcase = "Default"
          list_box items: ["Default", "Upper", "Mixed"],
          width: 120, choose: @textcase do |list|
            @textcase = list.text
          end
          @validate = button "Validate"
        end
        
        #When the user clicks the Validate button then call the Validate service
        @validate.click {
          address[:line1] = @line1.text
          address[:line2] = @line2.text
          address[:line3] = @line3.text
          address[:city] = @city.text
          address[:region] =  @state.text
          address[:postalcode] = @zip.text
          address[:country]= @country.text
          address[:textcase] = @textcase
          address[:addresscode] = "123"
          
        #Call the validate service - passing the address as a Hash
        val_addr = AddrService.validate(address)
 
        if val_addr[:validate_response][:validate_result][:result_code] == "Success"
          #Display validated result in a new window  
          Shoes.app :width => 400, :height => 1000, :left => 1000, :title => "Avalara - Address Validation Result" do
          
            background orange..blue
    
            stack :margin => 10  do 
              #Display result
              para "Line 1:"          
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:line1]            
              para "Line 2:"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:line2]
              para "Line 3:"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:line3]
              para "City"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:city]
              para "State" 
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:region] 
              para "Zip" 
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:postal_code]         
              para "Country"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:country]
              para
              para "Latitude"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:latitude]
              para "Longitude"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:longitude]
              para "County"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:county]
              para "FIPS Code"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:fips_code]
              para "Carrier Route"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:carrier_route]
              para "Post Net"
              edit_line :text => val_addr[:validate_response][:validate_result][:valid_addresses][:valid_address][:post_net]                                             
            end
          end   
        else   
          #Display error message in a new window  
          Shoes.app :width => 400, :height => 500, :title => "Address Validation Error" do
          
            background orange..red
       
            if val_addr[:validate_response][:validate_result][:result_code] == "Error"
           
              stack  :margin => 10  do 
                #Dispay error details 
                para "RESULT: #{val_addr[:validate_response][:validate_result][:result_code]}"
                para "SUMMARY: #{val_addr[:validate_response][:validate_result][:messages][:message][:summary]}"
                para "DETAILS: #{val_addr[:validate_response][:validate_result][:messages][:message][:details]}"
                para "HELP LINK: #{val_addr[:validate_response][:validate_result][:messages][:message][:help_link]}"
                para "REFERS TO: #{val_addr[:validate_response][:validate_result][:messages][:message][:refers_to]}"
                para "SEVERITY: #{val_addr[:validate_response][:validate_result][:messages][:message][:severity]}"
                para "SOURCE #{val_addr[:validate_response][:validate_result][:messages][:message][:source]}"
              end
            else
              #Dispay error details
              para "RESULT: Error"
              para "SUMMARY: Unexpected error"
              para "DETAILS: An unexpected error has occurred ... please check address_log.txt for details"
            end  
         end   
      end}
   end}
  end
end