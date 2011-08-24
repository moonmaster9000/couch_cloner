module Shown
  def conditions
    "#{super} && doc.couch_visible == true"
  end
end
