require 'savon'
require 'erb'

module AvaTax
  #Avalara address class
  class AddressService
    def initialize(credentials)
      
      #Set @def_locn to the Avatax-x.x.x gem install library. This enables the ruby programs to
      #find other objects that it needs.
      spec = Gem::Specification.find_by_name("Avatax_AddressService")
      gem_root = spec.gem_dir
      @def_locn = gem_root + "/lib"
      
      #Extract data from hash
      username = credentials[:username]
      password = credentials[:password]  
      if username.nil? and password.nil?   
        raise ArgumentError, "username and password are required"
      end
      name = credentials[:name]
      clientname = credentials[:clientname]
      adapter = credentials[:adapter]      
      machine = credentials[:machine] 
      use_production_account = credentials[:use_production_account]     
      
      #Set credentials and Profile information
      @username = username == nil ? "" : username
      @password = password == nil ? "" : password
      @name = name == nil ? "" : name
      @clientname = (clientname == nil or clientname == "") ? "AvataxRubySDK" : clientname
      @adapter = (adapter == nil or adapter == "") ? spec.summary + spec.version.to_s : adapter
      @machine = machine == nil ? "" : machine
      @use_production_account = (use_production_account != true) ? false : use_production_account

      #Open Avatax Error Log
      @log = File.new(@def_locn + '/address_log.txt', "w")
      
      #Get service details from WSDL - control_array[2] contains the WSDL read from the address_control file
      #log :false turns off HTTP logging. Select either Dev or Prod depending on the value of the boolean value 'use_production_account'
      if @use_production_account
        @log.puts "#{Time.now}: Avalara Production Address service started"
        #log :false turns off HTTP logging
        @client = Savon.client(wsdl: @def_locn + '/addressservice_prd.wsdl', log: false)
      else
        @log.puts "#{Time.now}: Avalara Development Address service started"
        #log :false turns off HTTP logging
        @client = Savon.client(wsdl: @def_locn + '/addressservice_dev.wsdl', log: false)
      end

      begin
      #Read in the SOAP template for Ping
        @template_ping = ERB.new(File.read(@def_locn + '/template_ping.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the Ping template"
      end

      begin
      #Read in the SOAP template for Validate
        @template_validate = ERB.new(File.read(@def_locn + '/template_validate.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the Validate template"
      end

      begin
      #Read in the SOAP template for IsAuthorized
        @template_isauthorized = ERB.new(File.read(@def_locn + '/template_isauthorized.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the IsAuthorized template"
      end
      
      # Create hash for result
      @response = Hash.new
    end

    ############################################################################################################
    # ping - Verifies connectivity to the web service and returns version information
    ############################################################################################################
    def ping(message = nil)
      
      @service = 'Ping'
      
      #Read in the SOAP template
      @message = message == nil ? "?" : message

      # Subsitute real vales for template place holders
      @soap = @template_ping.result(binding)

      # Make the call to the Avalara Ping service
      begin
        @response = @client.call(:ping, xml: @soap).to_hash

      #Strip off outer layer of the hash - not needed
      @response = @response[:ping_response][:ping_result]

      return @response
      
      #Capture unexpected errors
      rescue Savon::Error => error
        abend(error)
      end
    end

    ############################################################################################################
    # validate - call the adddress validation service
    ############################################################################################################
    def validate(address)

      @service = 'Validate'
      
      #create instance variables for each entry in input      
      address.each do |k,v|
        instance_variable_set("@#{k}",v)
      end
      #set required default values for missing required inputs
      @taxregionid ||= "0"
      @textcase ||= "Default"
      @coordinates ||= false 
      @taxability ||= false 
      
      # Subsitute real values for template place holders
      @soap = @template_validate.result(binding)

      # Make the call to the Avalara Validate service
      begin
        @response = @client.call(:validate, xml: @soap).to_hash

      #Strip off outer layer of the hash - not needed
      @response = @response[:validate_response][:validate_result]
      
      #Return data to calling program
      return @response
      
      #Capture unexpected errors
      rescue Savon::Error => error
        abend(error)
      end
    end

    ############################################################################################################
    #Verifies connectivity to the web service and returns version information about the service.
    ############################################################################################################
    def isauthorized(operation = nil)
      
      @service = 'IsAuthorized'
      
      #Read in the SOAP template
      @operation = operation == nil ? "?" : operation

      # Subsitute real vales for template place holders
      @soap = @template_isauthorized.result(binding)

      # Make the call to the Avalara Ping service
      begin
        @response = @client.call(:is_authorized, xml: @soap).to_hash

      #Strip off outer layer of the hash - not needed
      @response = @response[:is_authorized_response][:is_authorized_result]
      
      return @response
      
      #Capture unexpected errors
      rescue Savon::Error => error
        abend(error)
      end
    end
    
    private
    ############################################################################################################
    # abend - Unexpected error handling
    ############################################################################################################
    def abend(error)
      @log.puts "An unexpected error occurred: Response from server = #{error}"   
      @log.puts "#{Time.now}: Error calling #{@service} service ... check that your account name and password are correct."
      @response = error.to_hash
      @response[:result_code] = 'Error'
      @response[:summary] = @response[:fault][:faultcode]
      @response[:details] = @response[:fault][:faultstring]   
      return @response
    end
  end
end