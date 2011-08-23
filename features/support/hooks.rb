Before do
  Object.class_eval do
    if defined? Query
      remove_const "Query"
    end
  end
end
