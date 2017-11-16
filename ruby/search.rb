# area of interest:
$min_lat = 52.464011
$max_lat = 52.590117
$min_lon = 13.274099
$max_lon = 13.553989

class Point
  attr_accessor :x, :y, :lat, :lon

  def initialize(lat: nil, lon: nil, x: nil, y: nil)
    @lat = lat
    @lon = lon
    if x && y
      @x = x
      @y = y
    else
      xy = gps_to_xy(lat, lon)
      @x = xy[0]
      @y = xy[1]
    end
  end

  # | <x, y> - p |
  def distance(p)
    Math::sqrt((p.x - x)**2 + (p.y - y)**2)
  end

  def to_s
    sprintf('%5.f %5.f N%9.7f E%9.7f', x, y, lat, lon)
  end

  private

  # simple projection for getting GPS coordinates into an orthogonal coordinate system.
  # Result is an XY coordinate system with the origin (0,0) at the South-West corner of the area we are interested in.
  # The X axis corresponds to East-West and is given in kilometres. The Y axis corresponds to North-South and is also given in kilometres.
  def gps_to_xy(lat, lon)
    # The x and y coordinates of a GPS coordinate P with (P_lat, P_lon) can be calculated using:
    x = (lon - $min_lon) * Math::cos($min_lat * Math::PI / 180) * 111323.0 # km -> m
    y = (lat - $min_lat) * 111323.0 # km -> m

    return [x, y]
  end
end

class Line
  attr_reader :k, :l

  def initialize(points)
    @k = points[0]
    @l = points[1]
  end

  def normal_intersection_coefficient(p)
    raise 'Zero length line' if (k.x - l.x) ** 2 + (l.y - k.y) ** 2 == 0
    ((k.x - l.x) * (k.x - p.x) + (k.y - l.y) * (k.y - p.y)) / ((k.x - l.x) ** 2 + (l.y - k.y) ** 2)
  end

  def distance(point)
    a = normal_intersection_coefficient(point)
    intersection = Point.new(x: k.x + a * (l.x - k.x), y: k.y + a * (l.y - k.y))
    intersection.distance(point)
  end
end

def lognormal_pdf(point, center_point, mean, mode)
  mu = (2 * Math::log(mean) + Math::log(mode)) / 3
  sigma = Math::sqrt(2 * (Math::log(mean) - Math::log(mode)) / 3)
  x = center_point.distance(point)
  (1.0 / (x * sigma * Math::sqrt(2 / Math::PI))) * Math::exp(-(Math::log(x) - mu) ** 2 / (2 * sigma ** 2))
end

def brandenburg_gate_pdf(point)
  brandenburg_gate = Point.new(lat: 52.516288, lon: 13.377689)
  mean = 4700
  mode = 3877
  lognormal_pdf(point, brandenburg_gate, mean, mode)
end

# Satellite path is a great circle path between coordinates
$satellite_path = Line.new(
  [
    [52.590117, 13.39915],
    [52.437385, 13.553989]
  ].map { |lat, lon| Point.new(lat: lat, lon: lon) }
)

spree = [
  [52.529198, 13.274099],
  [52.531835, 13.29234],
  [52.522116, 13.298541],
  [52.520569, 13.317349],
  [52.524877, 13.322434],
  [52.522788, 13.329],
  [52.517056, 13.332075],
  [52.522514, 13.340743],
  [52.517239, 13.356665],
  [52.523063, 13.372158],
  [52.519198, 13.379453],
  [52.522462, 13.392328],
  [52.520921, 13.399703],
  [52.515333, 13.406054],
  [52.514863, 13.416354],
  [52.506034, 13.435923],
  [52.496473, 13.461587],
  [52.487641, 13.483216],
  [52.488739, 13.491456],
  [52.464011, 13.503386]
]

def joint_pdf(point)
  brandenburg_gate_pdf(point)
  #$satellite_path.distance(point)
end

plot_width = 1550
plot_height = 1148

y = 0
while y < plot_height
  x = 0
  while x < plot_width
    lat = $min_lat + (y * ($max_lat - $min_lat)) / plot_height
    lon = $min_lon + (x * ($max_lon - $min_lon)) / plot_width
    point = Point.new(lat: lat, lon: lon)
    pdf = joint_pdf(point)
    puts sprintf('%9.7f %9.7f %e', lat, lon, pdf)
    x += 1
  end
  y += 1
  puts "\n"
end
