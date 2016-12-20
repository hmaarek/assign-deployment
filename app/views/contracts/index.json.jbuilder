json.array!(@connections) do |connection|
  json.extract! connection, :id, :name, :customer_id
  json.url connection_url(connection, format: :json)
end
