# A sample Guardfile
# More info at https://github.com/guard/guard#readme

ignore /^\.git/, /^app/, /^bin/, /^build/, /^db/, /^log/, /^node_modules/, /^public/, /^storage/, /^test/, /^tmp/, /^vendor/

# directories %w(config lib)

guard 'puma', config: 'config/puma.rb' do
  watch('Gemfile.lock')
  watch(%r{^config|lib/.*})
end