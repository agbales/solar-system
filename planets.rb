require 'csv'
require 'awesome_print'

##
## Part 1 -- Creating CSV & Reading
##

planets = [
  [1, "Mercury", 0.055, 0.4],
  [2, "Venus", 0.815, 0.7],
  [3, "Earth", 1.0, 1.0],
  [4, "Mars", 0.107, 1.5]
]

# Our CSV won't have headers unless we add them!
headers = ["id", "name", "mass", "distance"]
# CSV.open(filename, mode, options)
# We're creating planet_data.csv with "w" mode
CSV.open("planet_data.csv", "w") do |file|
  file << headers
  # add all of the planets from planets array
  planets.each do |planet|
    file << planet
  end
end

# CSV.read outputs an array of arrays
# => [ ["1", "Mercury",...], ["2", "Venus",...], ...]
ap CSV.read("planet_data.csv")

##
## Part 2 - Appending & Reading Rows
##

# The "a" mode starts at the end of the file
planet_csv = CSV.open("planet_data.csv", "a") do |file|
  # at the end of the file, we add Jupiter
  file << [5, "Jupiter", 1234, 3321]
end

# .each accesses every row individually
CSV.open("planet_data.csv", "r").each do |row|
  ap row
end

##
## Part 3 -- Headers
##

# Notice we can pass in options (more than one, if we like)
csv_with_headers = CSV.open("planet_data.csv", "r", headers: true, header_converters: :symbol)
# It's a CSV object!
ap csv_with_headers
# Inspect with .each --> the headers are now symbol keys to the hash.
csv_with_headers.each do |row|
  ap row
end

##
## Part 4 -- This is helpful when writing out interpolated sentences.
##

CSV.open("planet_data.csv", "r+", headers: true, header_converters: :symbol).each do |row|
  ap "#{row[:name]} has a mass of #{row[:mass]} and distance of #{row[:distance]}"
end

##
## Part 5 -- CSV::Table methods
##

# .read gives us access to those methods. See Ruby Docs for full list.
csv = CSV.read("planet_data.csv", headers: true, header_converters: :symbol)
ap csv # <CSV::Table mode:col_or_row row_count:6>
ap csv.headers # Aarray of headers
ap csv.by_col[:id] # Array of the data in id column
ap csv.by_col[:name] # Array of the data in name column
ap csv.by_row[0] # Entire row at 0 (or any number)
ap csv[:name][3] # Name of the 3rd entry => "Mars"
ap csv[3][:name] # 3rd row's name => "Mars"

##
## Part 6 -- Game!
##

# Be sure to install catpix & launchy:
# gem install catpix -- Catpix can print images in the terminal
# gem install launchy -- Launchy can open and navigate a browser window
require 'catpix'
require 'launchy'

# CSV.read the Solar System.csv file; it's our database for the game
# The options will give us a hash, convertng the headers into symbols
$solar_system_data = CSV.read("Solar System.csv", headers: true, header_converters: :symbol)
ap $solar_system_data.class # CSV::Table < Object
ap "WELCOME TO THE SOLAR SYSTEM!"

def explore_planet()
  ap $solar_system_data.by_col[:name]
  prompt = "Where would you like to start? 0 - #{$solar_system_data.length}"
  ap prompt
  input = gets.chomp
  # Remember, solar_system_data.length == 14
  # We can grab the correct record with input.to_i
  $selected_planet = $solar_system_data[input.to_i]

  # Make sure planet exists & user input is numeric
  until $selected_planet && /\d/.match(input)
    ap prompt
    input = gets.chomp
    $selected_planet = $solar_system_data[input.to_i]
  end

  # Print that planet data
  ap $selected_planet

  prompt = "Do you want to LEARN or SEE?"
  ap prompt

  while input = gets.chomp
    # downcase helps errors due to alternate capitlizations
    case input.downcase
    when "learn"
      # Launchy opens a new window, navigates to the selected_planet page
      Launchy.open($selected_planet[:uri])
      return
    when "see"
      # Catpix prints the image at the file path stored at selected_planet[:image]
      # Be sure your images are within the Images folder in Solar-Data folder
      Catpix::print_image $selected_planet[:image]
      return
    else
      ap prompt
    end
  end
end
explore_planet()

def select_attribute()
  # The options are endless, but let's do one more feature.
  # Here, we can pick an attribute to look up values for each record.
  ap "Which attribute do want to see for each planet (ex: number_of_moons)?"
  # The headers are our attributes, so we print them as our options
  ap $solar_system_data.headers.to_s
  attribute = gets.chomp
  ap "Here are the #{attribute} findings:"
  # Iterate through listings to provide an interpolated answer.
  $solar_system_data.each do |row|
    # The current Row name / attribute requested / .to_sym converts string to appropriate symbol
    ap "#{row[:name]} --> #{attribute}: #{row[attribute.to_sym]}"
  end
end
select_attribute()

prompt = "SELECT another attribute or EXPLORE another planet?"
ap prompt

while input = gets.chomp
  case input.downcase
  when "select"
    select_attribute()
  when "explore"
    explore_planet()
  else
    ap prompt
  end
end
