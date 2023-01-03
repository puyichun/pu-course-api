json.data do
  json.array! @courses do |course|
    json.name course.name
    json.chapter course.chapters do |chapter|
      json.name chapter.name
      json.unit chapter.units do |unit|
        json.name unit.name
      end
    end
  end

end