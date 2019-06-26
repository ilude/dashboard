# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'puma', config: 'config/puma.rb' do
  watch('Gemfile.lock')
  watch(%r{^config|lib|api/.*})
end