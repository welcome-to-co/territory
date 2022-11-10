module Territory

  def self.circle(origin, radius, options = {})
     steps       = options[:steps] || 64
     properties  = options[:properties] ? options[:properties] : ((!origin.kind_of?(Array) && origin[:type] == "Feature" && origin[:properties]) ? origin[:properties] : {})
     units       = options[:units] || 'kilometers'

     coordinates = []
     steps.times do |i|
       coordinates.push(Territory.destination(origin, radius, (i * -360)/steps, {units: units})[:geometry][:coordinates])
     end

     coordinates.push(coordinates[0])

     polygon([coordinates], properties: options[:properties])
   end

end