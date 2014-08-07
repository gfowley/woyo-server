
name 'A small world'
description 'It\'s a small world after all...'

start :home

location :home do
  description 'A place to start from'
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


