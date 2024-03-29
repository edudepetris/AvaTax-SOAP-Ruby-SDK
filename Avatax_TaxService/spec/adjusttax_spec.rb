require "spec_helper"

describe "AdjustTax" do
  before :each do
    credentials = YAML::load(File.open('credentials.yml'))
    @creds = {:username => credentials['username'], 
          :password => credentials['password'],  
          :clientname => credentials['clientname'],
          :use_production_url => credentials['production']}
    @svc =  AvaTax::TaxService.new(@creds)
    @get_tax_request = {
      :doctype => "SalesInvoice",
      :commit => false,
      :detaillevel => "Tax",
      :docdate=>DateTime.now.strftime("%Y-%m-%d"),
      :customercode => "CUST123",
      :origincode => "456",
      :destinationcode => "456",
      :addresses=>[{
        :addresscode=>"456", 
        :line1=>"7070 West Arlington Drive", 
        :postalcode=>"80123", 
        :country=>"US", 
        }], 
      :lines=>[{
        :no=>"1", 
        :itemcode=>"Canoe", 
        :qty=>"1",
        :amount=>"300.43", 
        :description=>"Blue canoe",
        }]}
    @get_tax_result = @svc.gettax(@get_tax_request) 
    @request_required = {
      :adjustmentreason => "5",
      :adjustmentdescription => "Testing Adjustments",
      :doccode => @get_tax_result[:doc_code],
      :doctype => "SalesInvoice",
      :detaillevel => "Tax",
      :docdate=>DateTime.now.strftime("%Y-%m-%d"),
      :customercode => "CUST123",
      :origincode => "456",
      :destinationcode => "456",
      :addresses=>[{
        :addresscode=>"456", 
        :line1=>"7070 West Arlington Drive", 
        :postalcode=>"80123", 
        :country=>"US", 
        }], 
      :lines=>[{
        :no=>"1", 
        :itemcode=>"Canoe", 
        :qty=>"1",
        :amount=>"300.43", 
        :description=>"Blue canoe",
        }]
      
    }
    @request_optional = {
      :companycode => @get_tax_result[:company_code],
      :salespersoncode => "Bill Sales",
      :customerusagetype => "L",
      :discount => "10",
      :purchaseorderno => "PO9823",
      :exemptionno => "23423",
      :referencecode => "ref1",
      :locationcode => "001",
      :commit => "false",
      :batchcode => "",
      :taxoverridetype => "TaxDate",
      :taxamount => "0",
      :taxdate => "1999-01-01",
      :reason => "Override",
      :currencycode => "USD",
      :servicemode => "Remote",
      :paymentdate => DateTime.now.strftime("%Y-%m-%d"),
      :exchangerate => "0",
      :exchangerateeffdate => "1900-01-01",
      :poslanecode => "1",
      :businessidentificationno => "2342",
      :debug => false,
      :hashcode => "0",
      :taxoverridetype=>"None", 
      :taxamount=>".0000", 
      :taxdate=>"1900-01-01", 
      :reason=>"", 
      :addresses=>[{
        :addresscode=>"123", 
        :line1=>"100 ravine lane", 
        :line2=>"Suite 21", 
        :city=>"Bainbridge Island", 
        :region=>"WA", 
        :postalcode=>"98110", 
        :country=>"US", 
        :taxregionid=>"0", 
        :latitude=>"", 
        :longitude=>""
        }, {
        :addresscode=>"456", 
        :line1=> "Attn. Accounting",
        :line3=>"7070 West Arlington Drive", 
        :postalcode=>"80123", 
        :country=>"US", 
        :taxregionid=>"0"
        }],
        :lines=>[{
          :no=>"1", 
          :itemcode=>"Canoe", 
          :qty=>"1",
          :amount=>"300.43", 
          :discounted=>"false", 
          :ref1=>"ref1", 
          :ref2=>"ref2", 
          :description=>"Blue canoe",
            :taxoverridetypeline=>"TaxAmount", 
            :taxamountline=>"10", 
            :taxdateline=>"1900-01-01", 
            :reasonline=>"Tax credit", 
          :taxincluded=>"false" 
          }, {
          :no=>"2", 
          :itemcode=>"Rowing boat", 
          :qty=>"1", 
          :destinationcodeline=>"123",
          :amount=>"800.12", 
          :discounted=>"false", 
          :ref1=>"ref3", 
          :ref2=>"ref4", 
          :description=>"Red rowing boat", 
          :taxoverridetype=>"None", 
          :taxamount=>"0", 
          :taxdate=>"1900-01-01", 
          :taxincluded=>"true"
          }]
    }          
  end
  
  describe "returns a meaningful" do
    it "error when URL is missing" do
      @creds[:use_production_url] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.adjusttax(@request_required)[:result_code].should eql "Success"
    end
    it "success when URL is specified" do
      @creds[:use_production_url] = false
      @service = AvaTax::TaxService.new(@creds)
      @service.adjusttax(@request_required)[:result_code].should eql "Success"
    end
    it "error when username is missing" do
      @creds[:username] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.adjusttax(@request_required)[:result_code].should eql "Error"
    end
    it "error when password is omitted" do
      @creds[:password] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.adjusttax(@request_required)[:result_code].should eql "Error"
    end
    it "success when clientname is omitted" do
      @creds[:clientname] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.adjusttax(@request_required)[:result_code].should eql "Success"
    end   
  end
  
  describe "has consistent formatting for" do
    it "server-side errors" do
      @creds[:password] = nil
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Error" and       
      @result[:messages].kind_of?(Array).should eql true and
      @result[:messages][0].should include(:details => "The user or account could not be authenticated.")
    end
    it "successful results" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Success" and @result[:transaction_id].should_not be_nil
    end
  end  
  describe "requests with" do
    it "missing required parameters fail" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_optional)
      @result[:result_code].should eql "Error" 
    end
    it "invalid parameters ignore them" do
      @service = AvaTax::TaxService.new(@creds)
      @request_required[:bogus] = "data"
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Success" 
    end
    it "missing optional parameters succeed" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Success" 
    end
    it "all parameters succeed" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_required.merge(@request_optional))
      @result[:result_code].should eql "Success" 
    end
  end
  describe "workflow" do
    it "should adjust committed documents" do      
      @request_required[:customercode] = "NewCust"
      @generic_request = { 
        :doccode => @request_required[:doccode],
        :companycode => @request_required[:companycode],
        :doctype => @request_required[:doctype],
        :commit => true
      }
      @post_result = @svc.posttax(@generic_request)
      @result = @svc.adjusttax(@request_required)
      @history_result = @svc.gettaxhistory(@generic_request)
      @result[:result_code].should eql "Success" and 
      @history_result[:get_tax_request][:customer_code].should eql @request_required[:customercode] and
      @history_result[:get_tax_result][:doc_status].should eql "Committed"
    end
    it "should adjust uncommitted documents" do
      @request_required[:customercode] = "NewCust"
      @generic_request = { 
        :doccode => @request_required[:doccode],
        :companycode => @request_required[:companycode],
        :doctype => @request_required[:doctype],
        :commit => false
      }
      @post_result = @svc.posttax(@generic_request)
      @result = @svc.adjusttax(@request_required)
      @history_result = @svc.gettaxhistory(@generic_request)
      @result[:result_code].should eql "Success" and 
      @history_result[:get_tax_request][:customer_code].should eql @request_required[:customercode] and
      @history_result[:get_tax_result][:doc_status].should eql "Saved"
    end
    
  end
  
end