json.array!(@devices) do |device|
  json.extract! device, :id, :name, :device_type, :net_rack_id
  json.url device_url(device, format: :json)
end
