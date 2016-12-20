json.array!(@rings) do |ring|
  json.extract! ring, :id, :name, :description
  json.url ring_url(ring, format: :json)
end
