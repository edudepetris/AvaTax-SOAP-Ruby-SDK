Gem::Specification.new do |s|
  s.name = "Avatax_TaxService"
  s.version = "1.0.10"
  s.date = "2012-10-28"
  s.author = "Graham S Wilson"
  s.email = "support@Avalara.com"
  s.summary = "Avatax SDK for Ruby "
  s.homepage = "http://www.avalara.com/"
  s.description = "Ruby SDK provides means of communication with Avatax Web Services."
  s.license = 'MIT'
  s.files = ["lib/tax_log.txt", "lib/taxservice_dev.wsdl", "lib/taxservice_prd.wsdl", "lib/avatax_taxservice.rb",
             "lib/template_adjusttax.erb", "lib/template_canceltax.erb", "lib/template_committax.erb","lib/template_gettax.erb",
             "lib/template_gettaxhistory.erb","lib/template_isauthorized.erb","lib/template_ping.erb","lib/template_posttax.erb",
             "lib/template_reconciletaxhistory.erb","test/test_adjtax.rb","test/test_gettax.rb","test/test_gettaxhistory.rb",
             "test/test_reconciletaxhistory.rb", "Avatax_TaxService.gemspec","Avatax Ruby SDK Guide.docx", "LICENSE.txt"]
  s.add_dependency "savon", ">= 2.3.0"
  s.required_ruby_version = '>= 1.9.1'
  s.post_install_message = 'Thanks for installing the Avalara AddressService Ruby SDK. Refer to "Avatax Ruby SDK User Guide.docx" to get started.'
end
  