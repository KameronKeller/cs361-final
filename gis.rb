#!/usr/bin/env ruby

require "json"

class GeoJson
  def get_json(space = ' ')
    JSON.generate(self.build_object, space: space)
  end
end

class Track < GeoJson
  def initialize(segments, name = nil)
    @segments = segments
    @name = name
  end

  def as_lists()
    converted_segments = []
    @segments.each do |segment|
      converted_segments.append(segment.as_lists)
    end
    converted_segments
  end

  def build_geometry
    geometry = {}
    geometry["type"] = "MultiLineString"
    geometry["coordinates"] = self.as_lists
    geometry
  end

  def build_properties
    properties = {}
    properties["title"] = @name
    properties
  end

  def build_object
    track = {}
    track["type"] = "Feature"
    if @name != nil
      track["properties"] = self.build_properties
    end
    track["geometry"] = self.build_geometry
    track
  end
end

class TrackSegment
  attr_reader :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  def as_lists()
    converted_points = []
    @coordinates.each do |point|
      converted_points.append(point.as_list)
    end
    converted_points
  end
end

class Point
  attr_reader :latitude, :longitude, :elevation

  def initialize(longitude, latitude, elevation = nil)
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

class Waypoint < GeoJson
  attr_reader :location, :name, :icon

  def initialize(location, name = nil, icon = nil)
    @location = location
    @name = name
    @icon = icon
  end

  def build_properties
    properties = {}
    if name != nil
      properties["title"] = self.name
    end
    if icon != nil
      properties["icon"] = self.icon
    end
    properties
  end

  def build_object
    waypoint = {}
    waypoint["type"] = "Feature"
    waypoint["geometry"] = { "type": "Point", "coordinates": self.location.as_list }
    if name != nil or icon != nil
      waypoint["properties"] = self.build_properties
    end
    waypoint
  end
end

class World < GeoJson
  def initialize(name, features)
    @name = name
    @features = features
  end

  def add_feature(feature)
    @features.append(feature)
  end

  def build_feature_list
    feature_list = []
    @features.each do |feature|
      feature_list.append(feature.build_object)
    end
    feature_list
  end

  def build_object
    geo = { "type": "FeatureCollection" }

    geo["features"] = self.build_feature_list
    geo
  end

  def to_geojson
    self.get_json
  end
end

def main()
  home_location = Point.new(-121.5, 45.5, 30)
  store_location = Point.new(-121.5, 45.6, nil)

  home = Waypoint.new(home_location, "home", "flag")
  store = Waypoint.new(store_location, "store", "dot")

  segment_1 = TrackSegment.new([
                                 Point.new(-122, 45),
                                 Point.new(-122, 46),
                                 Point.new(-121, 46)
                               ])

  segment_2 = TrackSegment.new([
                                 Point.new(-121, 45),
                                 Point.new(-121, 46)
                               ])

  segment_3 = TrackSegment.new([
                                 Point.new(-121, 45.5),
                                 Point.new(-122, 45.5)
                               ])

  track_1 = Track.new([segment_1, segment_2], "track 1")
  track_2 = Track.new([segment_3], "track 2")

  world = World.new("My Data", [home, store, track_1, track_2])

  puts world.to_geojson
end

if File.identical?(__FILE__, $0)
  main()
end
