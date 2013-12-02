app = lambda do |env|
  body = "Hello world! My name is %APPLICATION% :)"
  [200, {"Content-Type" => "text/plain", "Content-Length" => body.length.to_s}, [body]]
end
run app
