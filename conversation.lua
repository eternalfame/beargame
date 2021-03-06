local conversation = {
    current = nil,
    queue = {},
    timer = 0,
    win = nil,
    lose = nil
}

local table = require('ext_table')

printf = function(s,...)
    return io.write(s:format(...))
end -- function

local function printtable(_table, indent)

  indent = indent or 0;

  local keys = {};

  for k in pairs(_table) do
    keys[#keys+1] = k;
    table.sort(keys, function(a, b)
      local ta, tb = type(a), type(b);
      if (ta ~= tb) then
        return ta < tb;
      else
        return a < b;
      end
    end);
  end

  print(string.rep('  ', indent)..'{');
  indent = indent + 1;
  for k, v in pairs(_table) do

    local key = k;
    if (type(key) == 'string') then
      if not (string.match(key, '^[A-Za-z_][0-9A-Za-z_]*$')) then
        key = "['"..key.."']";
      end
    elseif (type(key) == 'number') then
      key = "["..key.."]";
    end

    if (type(v) == 'table') then
      if (next(v)) then
        printf("%s%s =", string.rep('  ', indent), tostring(key));
        printtable(v, indent);
      else
        printf("%s%s = {},", string.rep('  ', indent), tostring(key));
      end
    elseif (type(v) == 'string') then
      printf("%s%s = %s,", string.rep('  ', indent), tostring(key), "'"..v.."'");
    else
      printf("%s%s = %s,", string.rep('  ', indent), tostring(key), tostring(v));
    end
  end
  indent = indent - 1;
  print(string.rep('  ', indent)..'}');
end


function conversation:init()
    self:clearQueue()
end

function conversation:increaseTimer(value)
    self.timer = self.timer + value
end

function conversation:resetTimer()
    self.timer = 0
end

function conversation:insertInQueue(conv)
    if self.queue then
        self.queue[#(self.queue)+1] = conv
    else
        self.queue = {
            conv
        }
    end
end

function conversation:setQueue(conv)
    self:clearQueue()
    self.queue = conv
end

function conversation:setWinString(conv)
    self.win = conv
end

function conversation:setLoseString(conv)
    self.lose = conv
end

function conversation:printLose()
    if self.current ~= self.lose then
        self.current = self.lose
    end
end

function conversation:printWin()
    if self.current ~= self.win then
        self.current = self.win
    end
end

function conversation:clearQueue()
    table.clear(self.queue)
    self.current = nil
    self.queue = nil
end

function conversation:getCurrent()
    return self.current
end

function conversation:skip()
    if self.current and self.current.timer then
        self.timer = self.current.timer
    end
end

function conversation:process(dt)
    if self.queue then
        if self.current then
            self:increaseTimer(dt)
        end

        if not self.current or self.timer > self.current.timer then
            self:resetTimer()
    --        self.current = table.get(self.queue, 1)
            self.current = self.queue[1]

            if not self.queue[1] then
                self.current = nil
                return
            end

            if self.current.func then
                self.current.func()
            end

            table.remove_node_order_safe(self.queue, self.current)
        end
    end
end

return conversation