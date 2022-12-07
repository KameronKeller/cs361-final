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
end




class Waypoint

  attr_reader :latitude, :longitude, :elevation, :name, :type

  # def initialize(longitude, latitude, elevation=nil, name=nil, type=nil)
  def initialize(location, name=nil, type=nil)
    @location = location
    @longitude = longitude
    @latitude = latitude
    @elevation = elevation
    @name = name
    @type = type
  end

  def get_waypoint_json(indent=0)
    json_output = '{"type": "Feature",'
    # if name is not nil or type is not nil
    json_output += '"geometry": {"type": "Point","coordinates": '
    json_output += "[#{@longitude},#{@latitude}"
    if elevation != nil
      json_output += ",#{@elevation}"
    end
    json_output += ']},'
    if name != nil or type != nil
      json_output += '"properties": {'
      if name != nil
        json_output += '"title": "' + @name + '"'
      end
      if type != nil  # if type is not nil
        if name != nil
          json_output += ','
        end
        json_output += '"icon": "' + @type + '"'  # type is the icon
      end
      json_output += '}'
    end
    json_output += "}"
    return json_output
  end
end

class World
  def initialize(name, features)
    @name = name
    @features = features
  end
  def add_feature(feature)
    @features.append(t)
  end

  def to_geojson(indent=0)
    # Write stuff
    json_output = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature, index|
      if index != 0
        json_output +=","
      end
      if feature.class == Track
        json_output += feature.get_track_json
      elsif feature.class == Waypoint
        json_output += feature.get_waypoint_json
      end
    end
    json_output + "]}"
  end
end

def main()
  home_location = Point.new(-121.5, 45.5, 30)
  store_location = Point.new(-121.5, 45.6, nil)

  home = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  store = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
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

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

