#!/usr/bin/env ruby

require "json"


class Track
  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |segment|
      segment_objects.append(TrackSegment.new(segment))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end

  def get_track_json()
    json_output = '{'
    json_output += '"type": "Feature", '
    if @name != nil
      json_output+= '"properties": {'
      json_output += '"title": "' + @name + '"'
      json_output += '},'
    end
    json_output += '"geometry": {'
    json_output += '"type": "MultiLineString",'
    json_output +='"coordinates": ['
    # Loop through all the segment objects
    @segments.each_with_index do |segment, index|
      if index > 0
        json_output += ","
      end
      json_output += '['
      # Loop through all the coordinates in the segment
      track_segment_json = ''
      segment.coordinates.each do |coordinate|
        if track_segment_json != ''
          track_segment_json += ','
        end
        # Add the coordinate
        track_segment_json += '['
        track_segment_json += "#{coordinate.longitude},#{coordinate.latitude}"
        if coordinate.elevation != nil
          track_segment_json += ",#{coordinate.elevation}"
        end
        track_segment_json += ']'
      end
      json_output+=track_segment_json
      json_output+=']'
    end
    json_output + ']}}'
  end
end



class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end




class Point

  attr_reader :latitude, :longitude, :elevation

  def initialize(longitude, latitude, elevation=nil)
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
  end

  def as_list
    point = [longitude, latitude]
    if elevation != nil
      point.append(elevation)
    end
    point
  end

end




class Waypoint

  attr_reader :location, :name, :type

  def initialize(location, name=nil, type=nil)
    @location = location.as_list
    @name = name
    @type = type
  end

  def get_waypoint
    waypoint = {}
    waypoint["type"] = "Feature"
    waypoint["geometry"] = {"type": "Point", "coordinates": self.location}
    if name != nil or type != nil
      properties = {}
      if name != nil
        properties["title"] = self.name
      end
      if type != nil
        properties["icon"] = self.type
      end
      waypoint["properties"] = properties
    end
  waypoint
  end

  def get_json(space=' ')
    JSON.generate(self.get_waypoint, space: space)
  end
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end
  def add_feature(feature)
    @features.append(feature)
  end

  # def to_geo
  #   geo = {"type": "FeatureCollection"}
  #   geo["features"] = @features
  # end

  def to_geojson(space=' ')
    geo = {"type": "FeatureCollection"}
    geo["features"] = []
    @features.each do |feature|
      geo["features"].append(feature.get_json)
    end
    # json_output = '{"type": "FeatureCollection","features": ['
    # @features.each_with_index do |feature, index|
      # if index != 0
        # json_output +=","
      # end
      # if feature.class == Track
    #     json_output += feature.get_track_json
    #   # elsif feature.class == Waypoint
    #     json_output += feature.get_waypoint_json
    #   # end
    # end
    JSON.generate(geo, space: space)
    # json_output + "]}"
  end
end

def main()

  if false
    test_point = Point.new(-121.5, 45.5, 30)
    home = Waypoint.new(test_point, "home", "flag")
    # p home.location
    puts home.get_waypoint_json
  end



  if true
    home_location = Point.new(-121.5, 45.5, 30)
    store_location = Point.new(-121.5, 45.6, nil)

    home = Waypoint.new(home_location, "home", "flag")
    store = Waypoint.new(store_location, "store", "dot")
    tracks_1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46)
    ]

    tracks_2 = [
      Point.new(-121, 45),
      Point.new(-121, 46)
    ]

    tracks_3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5)
    ]

    track_1 = Track.new([tracks_1, tracks_2], "track 1")
    track_2 = Track.new([tracks_3], "track 2")

    world = World.new("My Data", [home, store, track_1, track_2])
    p world.to_geo

    # puts world.to_geojson()
  end
end

if File.identical?(__FILE__, $0)
  main()
end

