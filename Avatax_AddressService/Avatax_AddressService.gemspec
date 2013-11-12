Gem::Specification.new do |s|
  s.name = "Avatax_AddressService"
  s.version = "1.0.3"
  s.date = "2012-10-28"
  s.author = "Graham S Wilson"
  s.email = "support@Avalara.com"
  s.summary = "Ruby SDK for Avatax Address Web Services"
  s.homepage = "http://www.avalara.com/"
  s.description = "Ruby SDK provides means of communication with Avatax Web Services."
  s.files = ["lib/address_log.txt", "lib/addressservice_dev.wsdl", "lib/addressservice_prd.wsdl", "lib/avatax_addressservice.rb",
             "lib/template_validate.erb","lib/template_ping.erb","lib/template_isauthorized.erb",
             "lib/xpath_validate.txt", "lib/xpath_ping.txt","lib/xpath_isauthorized.txt","test/test_address.rb",
             "Avatax_AddressService.gemspec", "Avatax Ruby SDK Guide.docx", "LICENSE.txt"]
  s.add_dependency "nokogiri", ">= 1.4.0", "< 1.6"
  s.add_dependency "savon", ">= 2.3.0"
  s.required_ruby_version = '>=1.9.1'
  s.post_install_message = 'Thanks for installing the Avalara AddressService Ruby SDK. Refer to "Avatax Ruby SDK User Guide.docx" to get started.'
end
  