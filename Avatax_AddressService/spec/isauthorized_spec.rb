require "spec_helper"

describe "IsAuthorized" do
  before :each do
    @creds = {:username => "account.admin.1100014690", 
          :password => "avalara",  
          :clientname => "AvaTaxCalcSOAP Ruby Sample",
          :use_production_url => false}
  end
  
  describe "returns a meaningful" do
    it "error when URL is missing" do
      @creds[:use_production_url] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Success"
    end
    it "success when URL is specified" do
      @creds[:use_production_url] = false
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Success"
    end
    it "error when username is missing" do
      @creds[:username] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Error"
    end
    it "error when password is omitted" do
      @creds[:password] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Error"
    end
    it "success when clientname is omitted" do
      @creds[:clientname] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Success"
    end   
    it "error when internet is unavailable" do
      pending "not yet implemented"
    end    
  end
  
  describe "has consistant formatting for" do
    it "internal logic errors" do
      @service = AvaTax::AddressService.new(@creds)
      lambda { @service.isauthorized("param1","param2") }.should raise_exception
    end
    it "transmission errors" do
      pending "should be similar to internet unavailable"
    end
    it "server-side errors" do
      @creds[:password] = nil
      @service = AvaTax::AddressService.new(@creds)
      @result = @service.isauthorized
      @result[:result_code].should eql "Error" and @result[:details].should eql "The user or account could not be authenticated."
    end
    it "successful results" do
      @service = AvaTax::AddressService.new(@creds)
      @result = @service.isauthorized
      @result[:result_code].should eql "Success" and @result[:expires].should_not be_nil
    end
  end  
  describe "requests with" do
    it "missing required parameters fail" do
      true #there are no required parameters for isauthorized
    end
    it "invalid parameters fail" do
      @service = AvaTax::AddressService.new(@creds)
      lambda { @service.isauthorized("param1","param2") }.should raise_exception
    end
    it "missing optional parameters succeed" do
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized[:result_code].should eql "Success"
    end
    it "all parameters succeed" do
      @service = AvaTax::AddressService.new(@creds)
      @service.isauthorized("Message")[:result_code].should eql "Success"
    end
  end
  
end