class Point
  attr_accessor :x, :y

  def initialize(other_point)
    @x += other_point.x
    @y += other_point.y
  end

  def initialize(x = 0, y = 0)
    @x = x
    @y = y
  end

  def ==(another_point)
    @x == another_point.x && @y == another_point.y
  end

  def +(another_point)
    Point.new(@x + another_point.x, @y + another_point.y)
  end

  def *(another_point)
    if another_point.class == "Point"
      Point.new(@x * another_point.x, @y * another_point.y)
    else
      Point.new(@x * another_point, @y * another_point)
    end
  end

  def manhattan_length
    @x.abs + @y.abs
  end

  def to_s
    "(#{@x},#{@y})"
  end
end

class Command
  attr_accessor :type, :value

  def initialize(command, value)
    @type = command
    @value = value
  end

  def to_s
    "#{cmd_sym_to_str}#{@value}"
  end

  def self.parse_command(string)
    r = string.match(/(\w)(\d+)/)
    new(cmd_str_to_sym(r[1]), r[2].to_i)
  end

  def cmd_sym_to_str
    case @type
    when :forward
      return "F"
    when :rotate_right
      return "R"
    when :rotate_left
      return "L"
    when :north
      return "N"
    when :east
      return "E"
    when :south
      return "S"
    when :west
      return "W"
    else
      throw :this_should_not_happen
    end
  end

  def self.cmd_str_to_sym(cmd_str)
    case cmd_str
    when "F"
      return :forward
    when "R"
      return :rotate_right
    when "L"
      return :rotate_left
    when "N"
      return :north
    when "E"
      return :east
    when "S"
      return :south
    when "W"
      return :west
    else
      throw :this_should_not_happen
    end
  end

  def direction
    self.class.direction_from_heading(@type)
  end

  def rotate_waypoint(waypoint)
    # x' = x cos θ − y sin θ
    # y' = x sin θ + y cos θ
    in_radians = @value / 180.0 * Math::PI
    if @type == :rotate_left
      in_radians = -in_radians
    end
    x = waypoint.x * Math.cos(in_radians) - waypoint.y * Math.sin(in_radians)
    y = waypoint.x * Math.sin(in_radians) + waypoint.y * Math.cos(in_radians)
    Point.new(x.round, y.round)
  end

  def self.direction_from_heading(heading)
    case heading
    when :north
      Point.new(0, -1)
    when :south
      Point.new(0, 1)
    when :east
      Point.new(1, 0)
    when :west
      Point.new(-1, 0)
    end
  end
end

class Ship
  def initialize
    @position = Point.new
    @waypoint = Point.new(10, -1)
  end

  def execute_cmd(command)
    case command.type
    when :north, :south, :east, :west
      @waypoint += command.direction * command.value
    when :rotate_left, :rotate_right
      @waypoint = command.rotate_waypoint @waypoint
    when :forward
      @position += @waypoint * command.value
    end
  end

  def to_s
    "Waypoint at #{@waypoint} ship position #{@position} and manhattan length from origin #{@position.manhattan_length}"
  end
end

ship = Ship.new
File.open("input").map do |line|
  cmd = Command.parse_command(line)
  puts "Executing #{cmd}"
  ship.execute_cmd cmd
  puts ship
  puts "--------------------------------------"
end
