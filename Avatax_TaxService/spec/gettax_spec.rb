require "spec_helper"
require "date"

describe "GetTax" do
  before :each do
    @request_required = {
      :doctype => "SalesOrder",
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
        :taxregionid=>"0"
        }], 
      :lines=>[{
        :no=>"1", 
        :itemcode=>"Canoe", 
        :qty=>"1",
        :amount=>"300.43", 
        :description=>"Blue canoe",
        :discounted => false,
        }]
      
    }
    @request_optional = {
      :companycode => "SDK", #TODO change to generic val
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
      :validate => false,
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
            :taxoverridetype=>"TaxAmount", 
            :taxamount=>"10", 
            :taxdate=>"1900-01-01", 
            :reason=>"Tax credit", 
          :taxincluded=>"false" 
          }, {
          :no=>"2", 
          :itemcode=>"Rowing boat", 
          :qty=>"1", 
          :destinationcode=>"123",
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

    @creds = {:username => "account.admin.1100014690", 
          :password => "avalara",  
          :clientname => "AvaTaxCalcSOAP Ruby Sample",
          :use_production_url => false}
          
  end
  
  describe "returns a meaningful" do
    it "error when URL is missing" do
      @creds[:use_production_url] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.gettax(@request_required)[:result_code].should eql "Success"
    end
    it "success when URL is specified" do
      @creds[:use_production_url] = false
      @service = AvaTax::TaxService.new(@creds)
      @service.gettax(@request_required)[:result_code].should eql "Success"
    end
    it "error when username is missing" do
      @creds[:username] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.gettax(@request_required)[:result_code].should eql "Error"
    end
    it "error when password is omitted" do
      @creds[:password] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.gettax(@request_required)[:result_code].should eql "Error"
    end
    it "success when clientname is omitted" do
      @creds[:clientname] = nil
      @service = AvaTax::TaxService.new(@creds)
      @service.gettax(@request_required)[:result_code].should eql "Success"
    end   
    it "error when internet is unavailable" do
      pending "not yet implemented"
    end    
  end
  
  describe "has consistant formatting for" do
    it "internal logic errors" do
      pending
      @service = AvaTax::TaxService.new(@creds)
      lambda { @service.gettax(@request_required) }.should raise_exception
    end
    it "transmission errors" do
      pending "should be similar to internet unavailable"
    end
    it "server-side errors" do
      @creds[:password] = nil
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.gettax(@request_required)
      @result[:result_code].should eql "Error" and @result[:details].should eql "The user or account could not be authenticated."
    end
    it "successful results" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.gettax(@request_required)
      if @result[:result_code] == "Error"
        print @result
      end
      @result[:result_code].should eql "Success" and @result[:transaction_id].should_not be_nil
    end
  end  
  describe "requests with" do
    it "missing required parameters fail" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.gettax(@request_optional)
      @result[:result_code].should eql "Error" 
    end
    it "invalid parameters fail" do
      @service = AvaTax::TaxService.new(@creds)
      @request_required[:bogus] = "data"
      @result = @service.gettax(@request_required)
      @result[:result_code].should eql "Error" 
    end
    it "missing optional parameters succeed" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.gettax(@request_required)
      @result[:result_code].should eql "Success" 
    end
    it "all parameters succeed" do
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.gettax(@request_required.merge(@request_optional))
      @result[:result_code].should eql "Success" 
    end
  end
  describe "workflow cases" do
  end
  
end