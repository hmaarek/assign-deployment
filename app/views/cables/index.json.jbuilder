json.array!(@cables) do |cable|
  json.extract! cable, :id, :name, :size
  json.url cable_url(cable, format: :json)
end
