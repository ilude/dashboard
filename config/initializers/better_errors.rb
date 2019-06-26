if defined?(BetterErrors)
  BetterErrors.editor = proc { |full_path, line|
    full_path = full_path.sub(Rails.root.to_s, ENV["DOCKER_HOST_PATH"])
    "vscode://file/#{full_path}:#{line}"
  }
  BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
end
