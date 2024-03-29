Gem::Specification.new do |s|
  s.name = "Avatax_TaxService"
  s.version = "2.0.2"
  s.date = "2015-06-12"
  s.author = "Graham S Wilson"
  s.email = "support@Avalara.com"
  s.summary = "Avatax SDK for Ruby "
  s.homepage = "http://www.avalara.com/"
  s.description = "Ruby SDK provides means of communication with Avatax Web Services."
  s.license = 'MIT'
  s.files = ["lib/tax_log.txt", "lib/taxservice.wsdl", "lib/avatax_taxservice.rb",
             "lib/template_adjusttax.erb", "lib/template_canceltax.erb", "lib/template_committax.erb","lib/template_gettax.erb",
             "lib/template_gettaxhistory.erb","lib/template_isauthorized.erb","lib/template_ping.erb","lib/template_posttax.erb",
             "lib/template_reconciletaxhistory.erb",
             "samples/CancelTaxTest.rb","samples/GetTaxTest.rb","samples/GetTaxHistoryTest.rb","samples/PingTest.rb","samples/PostTaxTest.rb",
             "spec/adjusttax_spec.rb","spec/canceltax_spec.rb","spec/committax_spec.rb","spec/gettax_spec.rb",
             "spec/gettaxhistory_spec.rb","spec/isauthorized_spec.rb","spec/ping_spec.rb","spec/posttax_spec.rb","spec/reconciletaxhistory_spec.rb",
             "spec/spec_helper.rb","spec/taxservice_spec.rb","Avatax_TaxService.gemspec","LICENSE.txt"]
  s.add_dependency "savon", ">= 2.3.0"
  s.required_ruby_version = '>= 1.9.1'
  s.post_install_message = 'Thanks for installing the Avalara TaxService Ruby SDK. For more information and to sign up for a free test account, visit http://developer.avalara.com'
end
  