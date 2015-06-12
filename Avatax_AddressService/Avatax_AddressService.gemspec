Gem::Specification.new do |s|
  s.name = "Avatax_AddressService"
  s.version = "2.0.1"
  s.date = "2015-06-12"
  s.author = "Graham S Wilson"
  s.email = "support@Avalara.com"
  s.summary = "Ruby SDK for Avatax Address Web Services "
  s.homepage = "http://www.avalara.com/"
  s.license = 'MIT'
  s.description = "Ruby SDK provides means of communication with Avatax Web Services."
  s.files = ["lib/address_log.txt", "lib/addressservice.wsdl", "lib/avatax_addressservice.rb",
             "lib/template_validate.erb","lib/template_ping.erb","lib/template_isauthorized.erb",
             "samples/PingTest.rb","samples/ValidateAddressTest.rb",
             "spec/addressservice_spec.rb","spec/isauthorized_spec.rb","spec/ping_spec.rb","spec/spec_helper.rb","spec/validate_spec.rb",
             "Avatax_AddressService.gemspec","LICENSE.txt"]
  # s.add_dependency "nokogiri", ">= 1.4.0", "< 1.6"
  s.add_dependency "savon", ">= 2.3.0"
  s.required_ruby_version = '>=1.9.1'
  s.post_install_message = 'Thanks for installing the Avalara AddressService Ruby SDK. For more information and to sign up for a free test account, visit http://developer.avalara.com'
end