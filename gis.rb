#!/usr/bin/env ruby

require "json"


class Track
  def initialize(segments, name=nil)
    @segments = segments
    @name = name
  end

  def convert_segment_points_to_list(segments)
    converted_segments = []
    segments.each do |segment|
      segment_list = []
      segment.each do |point|
        segment_list.append(point.as_list)
      end
      converted_segments.append(segment_list)
    end
    converted_segments
  end

  def get_object
    track = {}

    track["type"] = "Feature"
    if @name != nil
      properties = {}
      properties["title"] = @name
      track["properties"] = properties
    end
    geometry = {}
    geometry["type"] = "MultiLineString"

    geometry["coordinates"] = self.convert_segment_points_to_list(@segments)
    track["geometry"] = geometry
    track
  end

  def get_json(space=' ')
    JSON.generate(self.get_object, space: space)
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

  def get_object
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
    JSON.generate(self.get_object, space: space)
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

  def to_geojson(space=' ')
    geo = {"type": "FeatureCollection"}
    feature_list = []
    @features.each do |feature|
      feature_list.append(feature.get_object)
    end
    geo["features"] = feature_list

    JSON.generate(geo, space: space)
  end
end

def main()

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
  
  puts world.to_geojson
end

if File.identical?(__FILE__, $0)
  main()
end

