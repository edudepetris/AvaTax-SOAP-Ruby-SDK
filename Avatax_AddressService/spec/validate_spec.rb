require "spec_helper"

describe "Validate" do
  before :each do
    @address_req = {:line1 => "100 Ravine Lane NE", :postalcode => "98110"}
    @address_opt = {    
      :addresscode => "02",
      :line2 => "Attn: Avalara",
      :line3 => "Suite 200",
      :city => "Bainbridge Island",
      :region => "WA",
      :country => "US",
      :taxregionid => "234",
      :latitude => "47.624935",
      :longitude => "-122.515068",
      :textcase => "Upper",
      :coordinates => "true",
      :taxability => "true"}
    @creds = {:username => "account.admin.1100014690", 
      :password => "avalara",  
      :clientname => "AvaTaxCalcSOAP Ruby Sample",
      :use_production_url => false}
    @svc = AvaTax::AddressService.new(@creds)      
  end
  
  describe "returns a meaningful" do
    it "error when URL is missing" do
      @creds[:use_production_url] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.validate(@address_req)[:result_code].should eql "Success"
    end
    it "success when URL is specified" do
      @creds[:use_production_url] = false
      @service = AvaTax::AddressService.new(@creds)
      @service.validate(@address_req)[:result_code].should eql "Success"
    end
    it "error when username is missing" do
      @creds[:username] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.validate(@address_req)[:result_code].should eql "Error"
    end
    it "error when password is omitted" do
      @creds[:password] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.validate(@address_req)[:result_code].should eql "Error"
    end
    it "success when clientname is omitted" do
      @creds[:clientname] = nil
      @service = AvaTax::AddressService.new(@creds)
      @service.validate(@address_req)[:result_code].should eql "Success"
    end   
    it "error when internet is unavailable" do
      pending "not yet implemented"
    end    
  end
  
  describe "has consistant formatting for" do
    it "internal logic errors" do
      lambda { @svc.validate(@address_req, @address_req) }.should raise_exception
    end
    it "transmission errors" do
      pending "should be similar to internet unavailable"
    end
    it "server-side errors" do
      @creds[:password] = nil
      @service = AvaTax::AddressService.new(@creds)
      @result = @service.validate(@address_req)
      @result[:result_code].should eql "Error" and @result[:details].should eql "The user or account could not be authenticated."
    end
    it "successful results" do
      @result = @svc.validate(@address_req)
      @result[:result_code].should eql "Success" and @result[:valid_addresses].should_not be_nil
    end
  end  
  describe "requests with" do
    it "missing required parameters fail" do
      @address_req[:line1] = nil
      @svc.validate(@address_req)[:result_code].should eql "Error"
    end
    it "invalid parameters fail" do
      pending "Not sure this is required"
      @address_req[:bogus] = "data"
      @svc.validate(@address_req)[:result_code].should eql "Error"
    end
    it "missing optional parameters succeed" do
      @svc.validate(@address_req)[:result_code].should eql "Success"
    end
    it "all parameters succeed" do
      @address_full = @address_req.merge(@address_opt)
      @svc.validate(@address_full)[:result_code].should eql "Success"
    end
  end
end