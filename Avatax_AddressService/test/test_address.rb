#Load the Avalara Address Service module
require 'avatax_addressservice'
#require green_shoes for the GUI
require 'green_shoes'

#Create an address service instance
#Call the gettax service
username = 'USERNAME'
password = 'PASSWORD'
name = 'Avalara Inc.'
clientname = 'MyShoppingCart'
adapter = 'Avatax SDK for Ruby 1.0.1'
machine = 'Lenovo W520 Windows 7'
AddrService = AvaTax::AddressService.new(username,password,name,clientname,adapter,machine) 

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

    #Call the validate service
    val_addr = AddrService.validate(nil, @line1.text, nil, nil, @city.text, @state.text, @zip.text, 'US', nil, nil, nil, @textcase, nil, nil)
     
    if val_addr[:ResultCode] == "Success"
      #Display validated result in a new window  
      Shoes.app :width => 400, :height => 700, :left => 1000, :title => "Avalara - Address Validation Result" do
          
        background orange..blue
      
        stack :margin => 10  do 
          #Display result
          para "Line 1:"
          edit_line :text => val_addr[:Line1]
          para "Line 2:"
          edit_line :text => val_addr[:Line2]
          para "Line 3:"
          edit_line :text => val_addr[:Line3]
          para "City"
          edit_line :text => val_addr[:City]
          para "State" 
          edit_line :text => val_addr[:Region] 
          para "Zip" 
          edit_line :text => val_addr[:PostalCode]
          para "Country"
          edit_line :text => val_addr[:Country]
        end
      end   
    else
      #Display error message in a new window  
      Shoes.app :width => 400, :height => 500, :title => "Address Validation Error" do
          
        background orange..red
       
        if val_addr[:ResultCode] == "Error"
        stack  :margin => 10  do 
          #Dispay error details 
          para "RESULT: #{val_addr[:ResultCode]}"
          para "SUMMARY: #{val_addr[:Summary]}"
          para "DETAILS: #{val_addr[:Details]}"
          para "HELP LINK: #{val_addr[:Helplink]}"
          para "REFERS TO: #{val_addr[:RefersTo]}"
          para "SEVERITY: #{val_addr[:Severity]}"
          para "SOURCE #{val_addr[:Source]}"
        end
        else
          #Dispay error details
          para "RESULT: Error"
          para "SUMMARY: Unexpected error"
          para "DETAILS: An unexpected error has occurred ... please check avalog.txt for details"
        end  
     end   
  end}
end

