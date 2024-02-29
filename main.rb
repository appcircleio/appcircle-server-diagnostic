require "uri"
require "json"
require "net/http"
require 'fileutils'
require 'securerandom'

upload_file_chunk_url = ENV["AC_UPLOADCHUNK_URL"]

upload_url = URI(upload_file_chunk_url.gsub("uploadFileChunk", "testFileUpload"))
time_out_check_url = URI(upload_file_chunk_url.gsub("uploadFileChunk", "testServerTimeout"))
file_size = ENV["AC_DIAGNOSTIC_UPLOAD_FILE_SIZE_MB"].to_i
file_path = "/tmp/diagnostic_file_#{SecureRandom.hex(4)}.txt"
time_out_in_minutes = ENV["AC_DIAGNOSTIC_SERVER_TIMEOUT_MINUTES"].to_i

$stdout.sync = true

if file_size > 2048
  puts "File size is too large. Please provide a file size less than 2048 MB."
  exit
end
if file_size < 1
  puts "File size is incorrect. Please provide a file size between 1-2048 MB."
  exit
end

def create_diagnostic_file(file_path, file_size)
  begin
    # Convert file size from MB to bytes
    file_size_bytes = file_size * 1024 * 1024

    # Generate random data for the dummy file
    dummy_data = SecureRandom.random_bytes(file_size_bytes)

    # Write the dummy data to the file
    File.open(file_path, 'wb') do |file|
      file.write(dummy_data)
    end

    puts "Diagnostic file created successfully at #{file_path}"
  rescue => e
    puts "Error creating diagnostic file: #{e.message}"
  end
end

def diagnose_file_upload(upload_url, file_size, file_path)

  begin 
    http = Net::HTTP.new(upload_url.host, upload_url.port)
    http.read_timeout = 3600 # 30 min
    http.use_ssl = true if upload_url.instance_of? URI::HTTPS
    request = Net::HTTP::Post.new(upload_url)
    request["Content-Type"] = "application/json"
    form_data = [['fileSize', (file_size * 1024 * 1024).to_s],
                 ['filename', 'diagnostic_file.txt'],
                 ['fileContent', File.open(file_path)]]

    request.set_form form_data, 'multipart/form-data'
    start_time = Time.now

    puts "  uploading... {file_name: #{file_path}, file_size: #{file_size}MB}"
    response = http.request(request)
    unless response.is_a?(Net::HTTPSuccess)
      puts "Error code from server: #{response.code}"
      puts response.body
      raise "Upload failed."
    end
    end_time = Time.now
    upload_speed = file_size.to_f / (end_time - start_time)
    puts "Upload speed: #{upload_speed.round(3)} MB/s"
  rescue => e
    puts "Error: #{e.message}"
  end

  ## delete the file after upload
  File.delete(file_path)
end

def test_server_time_out(time_out_check_url, time_out_in_minutes)
  http = Net::HTTP.new(time_out_check_url.host, time_out_check_url.port)
  http.read_timeout = 3600 # 60 min
  http.use_ssl = true if time_out_check_url.instance_of? URI::HTTPS
  request = Net::HTTP::Post.new(time_out_check_url)
  request["Content-Type"] = "application/json"
  form_data = [['timeoutInMinutes', time_out_in_minutes.to_s]]
  request.set_form form_data, 'multipart/form-data'

  puts " Testing server timeout for #{time_out_in_minutes} minutes"
  response = http.request(request)
  unless response.is_a?(Net::HTTPSuccess)
    puts "Error code from server: #{response.code}"
    puts response.body
    raise "Server timeout test failed."
  end
  if response.is_a?(Net::HTTPSuccess)
    puts "Server timeout test is OK."
  end
end

puts "Creating diagnostic file..."
create_diagnostic_file(file_path, file_size)
puts "Diagnosing file upload..."
diagnose_file_upload(upload_url, file_size, file_path)
puts "Testing server timeout..."
test_server_time_out(time_out_check_url, time_out_in_minutes)
