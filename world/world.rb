
name 'A small world'
description 'It\'s a small world after all...'

start :home

location :home do
  description 'A good place to start.'
  way :out do
    to :outside
    description 'The outside world'
    going 'Going out...'
  end
  way :stairs do
    to :cellar
    description 'Stairs lead down into darkness'
  end
  item :table do
    description 'Wooden table'
  end
  item :lamp do
    description off: 'A dark lamp sits on the table', on: 'A lamp lights the table'
    exclusion :light, :off, :on
    action :turn_on do
      description 'Turn on the lamp'
      describe 'The lamp flickers to light'
      execution { on! }
    end
    action :turn_off do
      description 'Turn off the lamp'
      describe 'The lamps turn off, darkness returns'
      execution { off! }
    end
  end
  item :chair do
    description 'Simple chair'
  end
end

location :cellar do
  description 'A dark, damp cellar'
  way :stairs do
    description 'Stairs lead up into light'
  end
end

location :outside do
  description 'Not as scary as it\'s made out to be'
  way :in do
    to :home
    description 'Home'
    going 'Going home...'
  end
end


