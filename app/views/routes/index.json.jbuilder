json.array!(@routes) do |route|
  json.extract! route, :id, :content
  json.url route_url(route, format: :json)
end
