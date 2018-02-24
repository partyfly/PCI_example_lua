require "math"

critics={["Lisa Rose"]={["Lady in the Water"]=2.5, ["Snakes on a Plane"]=3.5,
 ["Just My Luck"]= 3.0, ["Superman Returns"]= 3.5, ["You, Me and Dupree"]= 2.5, 
 ["The Night Listener"]= 3.0},
["Gene Seymour"]= {["Lady in the Water"]= 3.0, ["Snakes on a Plane"]= 3.5, 
 ["Just My Luck"]= 1.5, ["Superman Returns"]= 5.0, ["The Night Listener"]= 3.0, 
 ["You, Me and Dupree"]= 3.5}, 
["Michael Phillips"]= {["Lady in the Water"]= 2.5, ["Snakes on a Plane"]= 3.0,
 ["Superman Returns"]= 3.5, ["The Night Listener"]= 4.0},
["Claudia Puig"]= {["Snakes on a Plane"]= 3.5, ["Just My Luck"]= 3.0,
 ["The Night Listener"]= 4.5, ["Superman Returns"]= 4.0, 
 ["You, Me and Dupree"]= 2.5},
["Mick LaSalle"]= {["Lady in the Water"]= 3.0, ["Snakes on a Plane"]= 4.0, 
 ["Just My Luck"]= 2.0, ["Superman Returns"]= 3.0, ["The Night Listener"]= 3.0,
 ["You, Me and Dupree"]= 2.0}, 
["Jack Matthews"]= {["Lady in the Water"]= 3.0, ["Snakes on a Plane"]= 4.0,
 ["The Night Listener"]= 3.0, ["Superman Returns"]= 5.0, ["You, Me and Dupree"]= 3.5},
["Toby"]= {["Snakes on a Plane"]=4.5,["You, Me and Dupree"]=1.0,["Superman Returns"]=4.0}}

function sim_distance(prefs, person1, person2)
  local sum_of_squares = 0
  for key,value in pairs(prefs[person1]) do
    if prefs[person2][key] ~= nil then
      sum_of_squares = sum_of_squares + math.pow(prefs[person1][key] - prefs[person2][key], 2)
    end
  end
  return 1/(1+math.sqrt(sum_of_squares))
end

-- print(sim_distance(critics, "Lisa Rose", "Gene Seymour"))

function sim_pearson(prefs, person1, person2)
  local sum1,sum2 = 0,0
  local sum1Sq,sum2Sq = 0,0
  local pSum = 0
  local n = 0
  for key,value in pairs(prefs[person1]) do
    if prefs[person2][key] ~= nil then
      sum1Sq = sum1Sq + math.pow(prefs[person1][key],2)
      sum2Sq = sum2Sq + math.pow(prefs[person2][key],2)
      sum1 = sum1 + prefs[person1][key]
      sum2 = sum2 + prefs[person2][key]
      pSum = pSum + prefs[person1][key]*prefs[person2][key]
      n = n + 1
    end
  end
  local num = pSum - (sum1*sum2/n)
  local den = math.sqrt((sum1Sq-math.pow(sum1,2)/n)*(sum2Sq-math.pow(sum2,2)/n))
  if den==0 then return 0 end
  return num/den
end

-- print(sim_pearson(critics, "Lisa Rose", "Gene Seymour"))

function topMatches(prefs, person, n, similarity)
  if n == nil then
    n = 5
  end
  if similarity == nil then
   similarity = sim_pearson
  end
  local scores = {}
  for key,value in pairs(prefs) do
    if key ~= person then
      scores[similarity(prefs, person, key)] = key
    end
  end
  local a = {}
  for key,value in pairs(scores) do
    table.insert(a, {score=key, name=value})
  end
  table.sort(a, function (first, second)
      return first.score > second.score
    end)
  return a
end

-- print(topMatches(critics, "Toby"))

function getRecommendations(prefs, person, similarity)
  if similarity == nil then
    similarity = sim_pearson
  end
  local totals = {}
  local simSums = {}
  for other in pairs(prefs) do
    if other ~= person then
      local sim = similarity(prefs, person, other)
      if sim > 0 then
        for key,value in pairs(prefs[other]) do
          if prefs[person][key] == nil and prefs[other][key] ~= 0 then
            if totals[key] == nil then
              totals[key] = 0
            end
            totals[key] = totals[key] + prefs[other][key]*sim
            if simSums[key] == nil then
              simSums[key] = 0
            end
            simSums[key] = simSums[key] + sim
          end
        end
      end
    end
  end
  local a = {}
  for item,total in pairs(totals) do
    table.insert(a, {score=total/simSums[item], name=item})
  end
  table.sort(a, function (first, second)
      return first.score > second.score
    end)
  return a;
end

-- print(getRecommendations(critics, "Toby"))

function transformPrefs(prefs)
  local result = {}
  for person in pairs(prefs) do
    for item in pairs(prefs[person]) do
      if result[item] == nil then
        result[item] = {}
      end
      result[item][person] = prefs[person][item]
    end
  end
  return result
end

function calculateSimilarItems(prefs, n)
  if n == nil then
    n = 5
  end
  local itemPrefs = transformPrefs(prefs)
  local c = 0
  local result = {}
  for item in pairs(itemPrefs) do
    c = c + 1
    if c%100 == 0 then
      print(c.."/"..table.nums(itemPrefs))
    end
    local score = topMatches(itemPrefs, item, n, sim_distance)
    result[item] = score
  end
  return result
end

print(calculateSimilarItems(critics))

function getRecommendedItems(prefs, itemMatch, user)
  
end


