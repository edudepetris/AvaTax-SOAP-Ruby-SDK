require 'savon'
require 'erb'
require 'nokogiri'
require 'benchmark'

module AvaTax
  #Avalara tax class
  class TaxService
    def initialize(credentials)

      #Extract data from hash
      username = credentials[:username]
      password = credentials[:password]
      name = credentials[:name]
      clientname = credentials[:clientname]
      adapter = credentials[:adapter]
      machine = credentials[:machine]

      #Set credentials and Profile information
      @username = username == nil ? "" : username
      @password = password == nil ? "" : password
      @name = name == nil ? "" : name
      @clientname = clientname == nil ? "" : clientname
      @adapter = adapter == nil ? "" : adapter
      @machine = machine == nil ? "" : machine

      #Set @def_locn to the Avatax-x.x.x gem install library. This enables the ruby programs to
      #find other objects that it needs.
      spec = Gem::Specification.find_by_name("Avatax_TaxService")
      gem_root = spec.gem_dir
      @def_locn = gem_root + "/lib"

      #Header for response data
      @responsetime_hdr = "  (User)    (System)    (Total)    (Real)"

      #Open Avatax Error Log
      @log = File.new(@def_locn + '/tax_log.txt', "w")
      @log.puts "#{Time.now}: Tax service started"

      #Get service details from WSDL - control_array[2] contains the WSDL read from the address_control file
      #log :false turns off HTTP logging
      @client = Savon.client(wsdl: @def_locn + '/taxservice_dev.wsdl', log: false)

      #Read in the SOAP template for Get tax
      begin
        @template_gettax = ERB.new(File.read(@def_locn + '/template_gettax.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the GetTax template"
      end

      #Read in the SOAP template for Adjust tax
      begin
        @template_adjust = ERB.new(File.read(@def_locn + '/template_adjusttax.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the AdjustTax template"
      end

      #Read in the SOAP template for Ping
      begin
        @template_ping = ERB.new(File.read(@def_locn + '/template_ping.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the Ping template"
      end

      #Read in the SOAP template for IsAuthorized
      begin
        @template_isauthorized = ERB.new(File.read(@def_locn + '/template_isauthorized.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the IsAuthorized template"
      end

      #Read in the SOAP template for Tax
      begin
        @template_post = ERB.new(File.read(@def_locn + '/template_posttax.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the Post template"
      end

      #Read in the SOAP template for Commit tax
      begin
        @template_commit = ERB.new(File.read(@def_locn + '/template_committax.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the CommitTax template"
      end

      #Read in the SOAP template for Cancel tax
      begin
        @template_cancel = ERB.new(File.read(@def_locn + '/template_canceltax.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the CancelTax template"
      end

      #Read in the SOAP template for GetTaxHistory tax
      begin
        @template_gettaxhistory = ERB.new(File.read(@def_locn + '/template_gettaxhistory.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the GetTaxHistory template"
      end

      #Read in the SOAP template for GetTaxHistory tax
      begin
        @template_reconciletaxhistory = ERB.new(File.read(@def_locn + '/template_reconciletaxhistory.erb'))
      rescue
        @log.puts "#{Time.now}: Error loading the ReconcileTaxHistory template"
      end

      # Create hash for validate result
      @return_data = Hash.new
    end

    ####################################################################################################
    # ping - Verifies connectivity to the web service and returns version information about the service.
    ####################################################################################################
    def ping(message = nil)
      #Read in the SOAP template
      @message = message == nil ? "?" : message

      # Subsitute real vales for template place holders
      @soap = @template_ping.result(binding)

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
        @response = @client.call(:ping, xml: @soap).to_s
      rescue
        @log.puts "#{Time.now}: Error calling Ping service ... check that your account name and password are correct."
      end
      # Load the response into a Nokogiri object and remove namespaces
      @doc = Nokogiri::XML(@response).remove_namespaces!

      #Read in an array of XPATH pointers
      @ping_xpath = File.readlines(@def_locn + '/xpath_ping.txt')

      #Parse the returned repsonse and return to caller as a hash
      @ping_xpath.each do |xpath|
        if xpath.rstrip.length != 0
          @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
        end
      end

      return @return_data
    end

    ####################################################################################################
    # gettax - Calls the Avatax GetTax Service
    ####################################################################################################
    def gettax(document)
      
      #Extract data from document hash
      xtract(document) 

      # If validate set to true then user has requested address validation before the tax call
      if @validate
        if @debug
          #Use Ruby built in Benchmark function to record response times
          time = Benchmark.measure do
            valaddr
          end
          if @val_addr[:ResultCode] == ["Success"]
            @log.puts "#{Time.now}: Validation OK"
          else
            @log.puts "#{Time.now}: Address #{line1}, #{line2}, #{line3}, #{city}, #{region}, #{postalcode}, #{country} failed to validate."
          end
          @log.puts "Response times for Address Validation:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        #Validate with no benchmarking
          valaddr
        end
      end

      # Subsitute template place holders with real values
      @soap = @template_gettax.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling GetTax Service for DocCode: #{@doccode}"
          time = Benchmark.measure do
          # Call GetTax Service
            @response = @client.call(:get_tax, xml: @soap).to_s
          end
          @log.puts "Response times for GetTax:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call GetTax Service
          @response = @client.call(:get_tax, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling GetTax service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @gettax_xpath = File.readlines(@def_locn + '/xpath_gettax.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the GeTax response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @gettax_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @gettax_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # adjusttax - Calls the Avatax AdjustTax Service
    ####################################################################################################
    def adjusttax(document)
      
      #Extract data from document hash
      xtract(document) 

      # If vaidate set to true then user has requested address validation before the tax call
      if @validate
        if @debug
          #Use Ruby built in Benchmark function to record response times
          time = Benchmark.measure do
            valaddr
          end
          if @val_addr[:ResultCode] == ["Success"]
            @log.puts "#{Time.now}: Validation OK"
          else
            @log.puts "#{Time.now}: Address #{line1}, #{line2}, #{line3}, #{city}, #{region}, #{postalcode}, #{country} failed to validate."
          end
          @log.puts "Response times for Address Validation:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        #Validate with no benchmarking
          valaddr
        end
      end

      # Subsitute template place holders with real values
      @soap = @template_adjust.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling AdjustTax Service for DocCode: #{@doccode}"
          time = Benchmark.measure do
          # Call AdjustTax Service
            @response = @client.call(:adjust_tax, xml: @soap).to_s
          end
          @log.puts "Response times for AdjustTax:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call AdjustTax Service
          @response = @client.call(:adjust_tax, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling AdjustTax service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @adjtax_xpath = File.readlines(@def_locn + '/xpath_adjtax.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the AdjustTax response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @adjtax_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @adjtax_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # posttax - Calls the Avatax PostTax Service
    ####################################################################################################
    def posttax(document)
      
      #Extract data from document hash
      xtract(document)

      # Subsitute template place holders with real values
      @soap = @template_post.result(binding)
      if debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling PostTax Service for DocCode: #{@doccode}"
          time = Benchmark.measure do
          # Call PostTax Service
            @response = @client.call(:post_tax, xml: @soap).to_s
          end
          @log.puts "Response times for PostTax:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call PostTax Service
          @response = @client.call(:post_tax, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling PostTax service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @posttax_xpath = File.readlines(@def_locn + '/xpath_post.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the PostTax response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @posttax_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @posttax_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # committax - Calls the Avatax CommitTax Service
    ####################################################################################################
    def committax(document)
        
      #Extract data from document hash
      xtract(document)

      # Subsitute template place holders with real values
      @soap = @template_commit.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling CommitTax Service for DocCode: #{@doccode}"
          time = Benchmark.measure do
          # Call CommitTax Service
            @response = @client.call(:commit_tax, xml: @soap).to_s
          end
          @log.puts "Response times for CommitTax:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call CommitTax Service
          @response = @client.call(:commit_tax, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling CommitTax service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @committax_xpath = File.readlines(@def_locn + '/xpath_commit.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the commitTax response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @committax_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @Committax_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # canceltax - Calls the Avatax CancelTax Service
    ####################################################################################################
    def canceltax(document)
      
      #Extract data from document hash
      xtract(document)

      # Subsitute template place holders with real values
      @soap = @template_cancel.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling CancelTax Service for DocCode: #{@doccode}"
          time = Benchmark.measure do
          # Call CancelTax Service
            @response = @client.call(:cancel_tax, xml: @soap).to_s
          end
          @log.puts "Response times for CancelTax:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call CancelTax Service
          @response = @client.call(:cancel_tax, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling CancelTax service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @canceltax_xpath = File.readlines(@def_locn + '/xpath_cancel.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the CancelTax response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @canceltax_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @canceltax_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # gettaxhistory - Calls the Avatax GetTaxHistory Service
    ####################################################################################################
    def gettaxhistory(document)
      
      #Extract data from document hash
      xtract(document)      

      # Subsitute template place holders with real values
      @soap = @template_gettaxhistory.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling GetTaxHistory Service"
          time = Benchmark.measure do
          # Call GetTaxHistory Service
            @response = @client.call(:get_tax_history, xml: @soap).to_s
          end
          @log.puts "Response times for GetTaxHistory:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call GetTaxHistory Service
          @response = @client.call(:get_tax_history, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling GetTaxHistory service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @gettaxhistory_xpath = File.readlines(@def_locn + '/xpath_gettaxhistory.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the GetTaxHistory response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @gettaxhistory_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.gsub('"', '').to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @gettaxhistory_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.gsub('"', '').to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ####################################################################################################
    # reconciletaxhistory - Calls the Avatax ReconcileTaxHistory Service
    ####################################################################################################
    def reconciletaxhistory(document)
      
      #Extract data from document hash
      xtract(document)      

      # Subsitute template place holders with real values
      @soap = @template_reconciletaxhistory.result(binding)
      if @debug
        @log.puts "#{Time.now}: SOAP request created:"
      @log.puts @soap
      end

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
      # Call using debug
        if @debug
          # Use Ruby built in Benchmark function to record response times
          @log.puts "#{Time.now}: Calling ReconcileTaxHistory Service"
          time = Benchmark.measure do
          # Call ReconcileTaxHistory Service
            @response = @client.call(:reconcile_tax_history, xml: @soap).to_s
          end
          @log.puts "Response times for ReconcileTaxHistory:"
        @log.puts @responsetime_hdr
        @log.puts time
        else
        # Call ReconcileTaxHistory Service
          @response = @client.call(:reconcile_tax_history, xml: @soap).to_s
        end
        #Capture unexpected errors
      rescue
        @log.puts "#{Time.now}: Error calling ReconcileTaxHistory service ... check that your account name and password are correct."
      end

      #Parse the response
      #Read in an array of XPATH pointers
      @reconciletaxhistory_xpath = File.readlines(@def_locn + '/xpath_reconciletaxhistory.txt')

      # Call using debug
      if @debug
        # Use Ruby built in Benchmark function to record response times
        @log.puts "#{Time.now}: Parsing the ReconcileTaxHistory response:"
        time = Benchmark.measure do
        # Load the response into a Nokogiri object and remove namespaces
          @doc = Nokogiri::XML(@response).remove_namespaces!
          #Parse the returned repsonse and return to caller as a hash
          @reconciletaxhistory_xpath.each do |xpath|
            if xpath.rstrip.length != 0
              @return_data[xpath.gsub('/', '').chomp.gsub('"', '').to_sym] = @doc.search(xpath).map{ |n| n.text}
            end
          end
        end
      @log.puts @responsetime_hdr
      @log.puts time
      else
      # Load the response into a Nokogiri object and remove namespaces
        @doc = Nokogiri::XML(@response).remove_namespaces!
        #Parse the returned repsonse and return to caller as a hash
        @reconciletaxhistory_xpath.each do |xpath|
          if xpath.rstrip.length != 0
            @return_data[xpath.gsub('/', '').chomp.gsub('"', '').to_sym] = @doc.search(xpath).map{ |n| n.text}
          end
        end
      end
      #Return data to calling program
      return @return_data
    end

    ############################################################################################################
    # isauthorized - Verifies connectivity to the web service and returns expiry information about the service.
    ############################################################################################################
    def isauthorized(operation = nil)
      #Read in the SOAP template
      @operation = operation == nil ? "?" : operation

      # Subsitute real vales for template place holders
      @soap = @template_isauthorized.result(binding)

      #Clear return hash
      @return_data.clear

      # Make the call to the Avalara service
      begin
        @response = @client.call(:is_authorized, xml: @soap).to_s
      rescue
        @log.puts "#{Time.now}: Error calling IsAuthorized service ... check username and password"
      end

      # Load the response into a Nokogiri object and remove namespaces
      @doc = Nokogiri::XML(@response).remove_namespaces!

      #Read in an array of XPATH pointers
      @isauthorized_xpath = File.readlines(@def_locn + '/xpath_isauthorized.txt')

      #Read each array element, extract the result returned by the service and place in a the @return_data hash
      @isauthorized_xpath.each{|xpath| @return_data[xpath.gsub('/', '').chomp.to_sym] = @doc.xpath(xpath).text}

      return @return_data
    end

    private

    ############################################################################################################
    # valaddr - Validates an address using the Avatax Address Validation Service
    ############################################################################################################
    def valaddr
      @x = 0
      @addresses.each do |addresscode,line1,line2,line3,city,region,postalcode,country,taxregionid,latitude,longitude,textcase,coordinates,taxability|
        @log.puts "#{Time.now}: Calling Address Validation Service for Address #{line1}, #{line2}, #{line3}, #{city}, #{region}, #{postalcode}, #{country}"
        #Call the address validation service
        @val_addr = AddrService.validate(addresscode,line1,line2,line3,city,region,postalcode,country,taxregionid,latitude,longitude,textcase,coordinates,taxability)
        #Update address details with the validated results
        @val_addr.each do
          @addresses[@x][0] = @val_addr[:AddressCode]
          @addresses[@x][1] = @val_addr[:Line1]
          @addresses[@x][2] = @val_addr[:Line2]
          @addresses[@x][3] = @val_addr[:Line3]
          @addresses[@x][4] = @val_addr[:City]
          @addresses[@x][5] = @val_addr[:Region]
          @addresses[@x][6] = @val_addr[:PostalCode]
          @addresses[@x][7] = @val_addr[:Country]
          @addresses[@x][8] = @val_addr[:TaxRegionId]
          @addresses[@x][9] = @val_addr[:Latitude]
          @addresses[@x][10] = @val_addr[:Longitude]
        end
        @x += @x
      end
    end
    
    ############################################################################################################
    # xtract - Extract data from document hash
    ############################################################################################################
    def xtract(document)

      companycode = document[:companycode]
      doctype = document[:doctype]
      doccode = document[:doccode]     
      docdate = document[:docdate]
      docid = document[:docid]      
      salespersoncode = document[:salespersoncode]
      customercode = document[:customercode]
      customerusagetype = document[:customerusagetype]     
      discount = document[:discount]             
      purchaseorderno = document[:purchaseorderno]
      exemptionno = document[:exemptionno]
      origincode = document[:origincode]     
      destinationcode = document[:destinationcode]
      addresses = document[:addresses]
      lines = document[:lines]
      detaillevel = document[:detaillevel]     
      referencecode = document[:referencecode]
      hashcode = document[:hashcode]
      locationcode = document[:locationcode]
      commit = document[:commit]
      batchcode = document[:batchcode]
      taxoverridetype = document[:taxoverridetype]
      taxamount = document[:taxamount]
      taxdate = document[:taxdate]
      reason = document[:reason]
      currencycode = document[:currencycode]
      servicemode = document[:servicemode]
      paymentdate = document[:paymentdate]
      exchangerate = document[:exchangerate]
      exchangerateeffdate = document[:exchangerateeffdate]
      poslanecode = document[:poslanecode]
      businessidentificationno = document[:businessidentificationno]
      adjustmentreason = document[:adjustmentreason]
      adjustmentdescription = document[:adjustmentdescription] 
      totalamount = document[:totalamount]
      totaltax = document[:totaltax]
      newdoccode = document[:newdoccode]
      lastdocid = document[:lastdocid] 
      reconciled = document[:reconciled]
      startdate = document[:startdate]
      enddate = document[:enddate]                 
      docstatus = document[:docstatus]      
      lastdoccode = document[:lastdoccode]
      cancelcode = document[:cancelcode]
      pagesize = document[:pagesize]
      debug = document[:debug]
      validate = document[:validate]
      
      #Set parms passed by user - If Nil then default else use passed value
      @companycode = companycode == nil ? "" : companycode
      @doctype = doctype == nil ? "" : doctype
      @doccode = doccode == nil ? "" : doccode
      @docdate = docdate == nil ? "" : docdate
      @docid = docid == nil ? "" : docid      
      @salespersoncode = salespersoncode == nil ? "" : salespersoncode
      @customercode = customercode == nil ? "" : customercode
      @customerusagetype = customerusagetype == nil ? "" : customerusagetype
      @discount = discount == nil ? "" : discount
      @purchaseorderno = purchaseorderno == nil ? "" : purchaseorderno
      @exemptionno = exemptionno == nil ? "" : exemptionno
      @origincode = origincode == nil ? "" : origincode
      @destinationcode = destinationcode == nil ? "" : destinationcode
      @addresses = addresses == nil ? "" : addresses
      @lines = lines == nil ? "" : lines
      @detaillevel = detaillevel == nil ? "" : detaillevel
      @referencecode = referencecode == nil ? "" : referencecode
      @hashcode = hashcode == nil ? "" : hashcode
      @locationcode = locationcode == nil ? "" : locationcode
      @commit = commit == nil ? "" : commit
      @batchcode = batchcode == nil ? "" : batchcode
      @taxoverridetype = taxoverridetype == nil ? "" : taxoverridetype
      @taxamount = taxamount == nil ? "" : taxamount
      @taxdate = taxdate == nil ? "" : taxdate
      @reason = reason == nil ? "" : reason
      @currencycode = currencycode == nil ? "" : currencycode
      @servicemode = servicemode == nil ? "" : servicemode
      @paymentdate = paymentdate == nil ? "" : paymentdate
      @exchangerate = exchangerate == nil ? "" : exchangerate
      @exchangerateeffdate = exchangerateeffdate == nil ? "" : exchangerateeffdate
      @poslanecode = poslanecode == nil ? "" : poslanecode
      @businessidentificationno = businessidentificationno == nil ? "" : businessidentificationno
      @validate = validate == nil ? false : validate
      @adjustmentreason = adjustmentreason == nil ? "" : adjustmentreason
      @adjustmentdescription = adjustmentdescription == nil ? "" : adjustmentdescription
      @totalamount = totalamount == nil ? "" : totalamount
      @totaltax = totaltax == nil ? "" : totaltax
      @newdoccode = newdoccode == nil ? "" : newdoccode
      @cancelcode = cancelcode == nil ? "" : cancelcode
      @detaillevel = detaillevel == nil ? "" : detaillevel
      @lastdocid = lastdocid == nil ? "" : lastdocid
      @reconciled = reconciled == nil ? "" : reconciled
      @startdate = startdate == nil ? "" : startdate
      @enddate = enddate == nil ? "" : enddate
      @docstatus = docstatus == nil ? "" : docstatus
      @lastdoccode = lastdoccode == nil ? "" : lastdoccode
      @pagesize = pagesize == nil ? "" : pagesize
      @debug = debug == nil ? false : debug
      @message = ""
      
    end

  end
end  