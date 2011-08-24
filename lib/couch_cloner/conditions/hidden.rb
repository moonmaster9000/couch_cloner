module Hidden
  def conditions
    "#{super} && doc.couch_visible == false"
  end
end
