json.array!(@devports) do |device|
  json.extract! devport, :id, :name, :portno, :fiber_id,:device_id
  json.url devport_url(devport, format: :json)
end
