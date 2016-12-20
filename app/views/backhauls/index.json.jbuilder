json.array!(@backhauls) do |backhaul|
  json.extract! backhaul, :id, :name, :rfs_status, :descript
  json.url backhaul_url(backhaul, format: :json)
end
