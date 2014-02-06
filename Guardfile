guard :rspec, :failed_mode => :none do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^lib/zeusd/(.+)\.rb$})     { |m| "spec/lib/zeusd/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

