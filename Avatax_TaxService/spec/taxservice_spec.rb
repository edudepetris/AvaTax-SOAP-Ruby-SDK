require "spec_helper"

describe "TaxService" do

  describe "does not allow instantiation with" do
    it "no values" do
      lambda { AvaTax::TaxService.new }.should raise_exception
    end
    it "optional values only" do
      lambda { AvaTax::TaxService.new(
      :clientname => "AvaTaxCalcSOAP Ruby Sample",
      :adapter => "AvaTaxCalcRuby",
      :machine => "MyComputer",
      :use_production_account => false ) }.should raise_exception
    end
  end
  describe "allows instantiation with" do
    it "required values only" do
      lambda { AvaTax::TaxService.new(
      :username => "account.admin.1100014690", 
      :password => "avalara",  
      :clientname => "AvaTaxCalcSOAP Ruby Sample") }.should_not raise_exception
    end
    it "required and optional values" do
      lambda { AvaTax::TaxService.new(
      :username => "account.admin.1100014690", 
      :password => "avalara",  
      :clientname => "AvaTaxCalcSOAP Ruby Sample",
      :adapter => "AvaTaxCalcRuby",
      :machine => "MyComputer",
      :use_production_account => false ) }.should_not raise_exception
    end
  end

end