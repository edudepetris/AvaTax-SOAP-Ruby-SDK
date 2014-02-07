require "spec_helper"

describe "AdjustTax" do
  before :each do
    @reqest_required = {}
    @request_optional = {}
    @creds = {:username => "account.admin.1100014690", 
          :password => "avalara",  
          :clientname => "AvaTaxCalcSOAP Ruby Sample",
          :use_production_url => false}
          
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
    it "error when internet is unavailable" do
      pending "not yet implemented"
    end    
  end
  
  describe "has consistant formatting for" do
    it "internal logic errors" do
      pending
      @service = AvaTax::TaxService.new(@creds)
      lambda { @service.adjusttax(@request_required) }.should raise_exception
    end
    it "transmission errors" do
      pending "should be similar to internet unavailable"
    end
    it "server-side errors" do
      @creds[:password] = nil
      @service = AvaTax::TaxService.new(@creds)
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Error" and @result[:details].should eql "The user or account could not be authenticated."
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
    it "invalid parameters fail" do
      @service = AvaTax::TaxService.new(@creds)
      @request_required[:bogus] = "data"
      @result = @service.adjusttax(@request_required)
      @result[:result_code].should eql "Error" 
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
  describe "workflow cases" do
  end
  
end