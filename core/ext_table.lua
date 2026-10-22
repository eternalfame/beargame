local table = table

function table.remove_node(arr, node)
	local _arr = #arr
	for i = 1, _arr do
		local _node = arr[i]
		if node == _node then
			arr[i] = arr[_arr]
			arr[_arr] = nil
			break
		end
	end
end

function table.remove_node_order_safe(arr, node)
    if arr then
        local _arr = #arr
        for i = 1, _arr do
            local _node = arr[i]
            if node == _node then
                for j = i, _arr-1 do
                    arr[j] = arr[j+1]
                end
                arr[_arr] = nil
                break
            end
        end
    end
end

function table.clear(array)
    if array then
        for k in pairs(array) do
            array[k] = nil
        end
    end
end

function table.not_in(array, node)
	for i = 1, #array do
		if node == array[i] then
			return false 
		end
	end
	return true
end

function table.length(T)
  local count = 0
  for _ in pairs(T) do
      count = count + 1
  end
  return count
end

function table.not_empty(T)
  for _ in pairs(T) do
      return true
  end
  return false
end

function table.get(T, idx)
    for index, value in pairs(T) do
        if index == idx then
            return value
        end
    end
    return nil
end

return table