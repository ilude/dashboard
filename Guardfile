# A sample Guardfile
# More info at https://github.com/guard/guard#readme
directories %w(app config lib test)

guard 'puma', config: 'config/puma.rb' do
  watch('Gemfile.lock')
  watch(%r{^config|lib/.*})
end