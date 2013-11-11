require 'savon'
require 'erb'
require 'nokogiri'

module AvaTax

  #Avalara address class
  class AddressService 
        
    def initialize(username,password,name,clientname,adapter,machine)
            
        #Set credentials and Profile information
        @username = username == nil ? "" : username
        @password = password == nil ? "" : password
        @name = name == nil ? "" : name  
        @clientname = clientname == nil ? "" : clientname
        @adapter = adapter == nil ? "" : adapter 
        @machine = machine == nil ? "" : machine        
       
        #Set @def_locn to the Avatax-x.x.x gem install library. This enables the ruby programs to
        #find other objects that it needs.
        spec = Gem::Specification.find_by_name("Avatax_AddressService")
        gem_root = spec.gem_dir
        @def_locn = gem_root + "/lib"
               
        #Open Avatax Error Log 
        @log = File.new(@def_locn + '\address_log.txt', "w")
        @log.puts "#{Time.now}: Address service started"

        #log :false turns off HTTP logging
        @client = Savon.client(wsdl: @def_locn + '/addressservice_dev.wsdl', log: false)
       
        begin
          #Read in the SOAP template for Ping
          @template_ping = ERB.new(File.read(@def_locn + '\template_ping.erb'))
          rescue
            @log.puts "#{Time.now}: Error loading the Ping template"
        end
        
        begin
          #Read in the SOAP template for Validate
          @template_validate = ERB.new(File.read(@def_locn + '\template_validate.erb'))
          rescue
            @log.puts "#{Time.now}: Error loading the Validate template"  
        end
        
        begin 
          #Read in the SOAP template for IsAuthorized
          @template_isauthorized = ERB.new(File.read(@def_locn + '\template_isauthorized.erb'))      
          rescue
            @log.puts "#{Time.now}: Error loading the IsAuthorized template"
        end
        # Create hash for validate result
        @return_data = Hash.new
    end

    ############################################################################################################    
    # ping - Verifies connectivity to the web service and returns version information 
    ############################################################################################################   
    def ping(message = nil)
      #Read in the SOAP template
      @message = message == nil ? "?" : message 

      # Subsitute real vales for template place holders  
      @soap = @template_ping.result(binding)
          
      #Clear return hash
      @return_data.clear
      
      # Make the call to the Avalara Ping service
      begin
        @response = @client.call(:ping, xml: @soap).to_s
        rescue
            @log.puts "#{Time.now}: Error calling Ping service ... check username and password" 
      end
      # Load the response into a Nokogiri object and remove namespaces
      @doc = Nokogiri::XML(@response).remove_namespaces! 
           
      #Read in an array of XPATH pointers 
      @ping_xpath = File.readlines(@def_locn + '\xpath_ping.txt')
   
      #Read each array element, extract the result returned by the service and place in a the @return_data hash
      @ping_xpath.each{|xpath| @return_data[xpath[2...xpath.length].chomp.to_sym] = @doc.xpath(xpath).text}
   
      return @return_data
    end

    ############################################################################################################
    # validate - call the adddress validation service
    ############################################################################################################
    def validate(addresscode = nil,
                  line1 = nil,
                  line2 = nil,
                  line3 = nil,
                  city = nil,
                  region = nil,
                  postalcode = nil,
                  country = nil,
                  taxregionid = nil,
                  latitude = nil,
                  longitude = nil,
                  textcase = nil,
                  coordinates = nil,
                  taxability = nil) 
      
        #Set parms passed by user - If Nil then default else use passed value
        @addresscode = addresscode == nil ? "123" : addresscode 
        @line1 = line1 == nil ? "" : line1
        @line2 = line2 == nil ? "" : line2
        @line3 = line3 == nil ? "" : line3 
        @city = city == nil ? "" : city 
        @region = region == nil ? "" : region
        @postalcode = postalcode == nil ? "" : postalcode
        @country = country == nil ? "" : country
        @taxregionid = taxregionid == nil ? "0" : taxregionid
        @latitude = latitude == nil ? "" : latitude
        @longitude = longitude == nil ? "" : longitude
        @textcase = textcase == nil ? "Default" : textcase
        @coordinates = coordinates == nil ? "true" : coordinates
        @taxability = taxability == nil ? "false" : taxability
      
        # Subsitute real vales for template place holders  
        @soap = @template_validate.result(binding)
       
        #Clear return hash
        @return_data.clear
        
        # Make the call to the Avalara Validate service
        begin
          @response = @client.call(:validate, xml: @soap).to_s

          rescue
            @log.puts "#{Time.now}: Error calling Validate service ... check username and password" 
        end    
     
        # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces! 
        
        #Read in an array of XPATH pointers 
        @validate_xpath = File.readlines(@def_locn + '\xpath_validate.txt')
      
        #Read each array element, extract the result returned by the service and place in a the @return_data hash
        @validate_xpath.each{|xpath| @return_data[xpath[2...xpath.length].chomp.to_sym] = @doc.xpath(xpath).text}
      
        return @return_data
    end
    
    ############################################################################################################
    #Verifies connectivity to the web service and returns version information about the service.
    ############################################################################################################
    def isauthorized(operation = nil)
      #Read in the SOAP template
      @operation = operation == nil ? "?" : operation 

      # Subsitute real vales for template place holders  
      @soap = @template_isauthorized.result(binding)
          
       #Clear return hash
      @return_data.clear
      
      # Make the call to the Avalara Ping service
      begin
        @response = @client.call(:is_authorized, xml: @soap).to_s
        rescue
          @log.puts "#{Time.now}: Error calling IsAuthorized service ... check username and password" 
      end
      
      # Load the response into a Nokogiri object and remove namespaces
      @doc = Nokogiri::XML(@response).remove_namespaces! 
          
      #Read in an array of XPATH pointers 
      @isauthorized_xpath = File.readlines(@def_locn + '\xpath_isauthorized.txt')
      
      #Read each array element, extract the result returned by the service and place in a the @return_data hash
      @isauthorized_xpath.each{|xpath| @return_data[xpath[2...xpath.length].chomp.to_sym] = @doc.xpath(xpath).text}
 
      return @return_data
    end
  end  
end