--[=[TAB:Main]=]
-- WinLib

-- Use this function to perform your initial setup
function setup()
    moved = 2
    btext = text --????
    winSetup()
    --backingMode(RETAINED)
    ui.alert(ui.OKAY_CANCEL, "Alert Title", "Message body\nLine 2\nLonger line of text that takes up the entire window width\n\nContinue?", 
    function() 
        ui.alert(ui.OKAY, "Results", "You pressed Okay")
    end,
    function() 
        ui.alert(ui.OKAY, "Results", "You pressed Cancel")
    end)
    local i = readImage("Documents:Alert_small")
    for x = 1, 24 do
        for y = 1, 24 do
            local r,g,b,a = i:get(x, y)
            i:set(x, y, color(255, a))
        end
    end
    saveImage("Documents:Alert_white", i)
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(255, 255, 255, 255)

    -- This sets the line thickness
    --strokeWidth(5)

    -- Do your drawing here
    drawWindows()
    
end


--[=[END_TAB]=]
--[=[TAB:Opt]=]
function bounds(a, l, h)
    return math.max(l, math.min(a, h)) == a
end

function range(a, l, h)
    return math.max(l, math.min(a, h))
end

_titlebar = {}
_titlebar[1] = function(self)
    fill(202, 202, 202, 255)
    rrect(self.x, HEIGHT - self.y, self.w, 20, vec4(0,5,5,0), vec3(50,50,50))
    --[[
    fill(202 - 40)
    noStroke()
    rrect(self.x, HEIGHT - self.y, self.w, 4, 0, vec3(10,10,10))
    --]]
    --[[
    fill(150)
    rrect(self.x + self.w - 50, HEIGHT - self.y + 3, 17, 14, 4, vec3(50,50,50))
    rrect(self.x + self.w - 70, HEIGHT - self.y + 3, 17, 14, 4, vec3(50,50,50))
    --]]
    fill(230)
    text(self.t, self.x + 19.5, HEIGHT - self.y + 0.5)
    fill(0)
    text(self.t, self.x + 20, HEIGHT - self.y + 1)
    --smooth()
    rsprite(self.ismall, self.x + 3, HEIGHT - self.y + 3, 14, 14, 2)
end
_titlebar[0] = function(self)
    fill(150)
    rrect(self.x, HEIGHT - self.y, self.w, 20, vec4(0,5,5,0), vec3(50,50,50))
    --[[
    fill(150 - 40)
    noStroke()
    rrect(self.x, HEIGHT - self.y, self.w, 4, 0, vec3(10,10,10))
    --]]
    --[[
    fill(175)
    rrect(self.x + self.w - 50, HEIGHT - self.y + 3, 17, 14, 4, vec3(50,50,50))
    rrect(self.x + self.w - 70, HEIGHT - self.y + 3, 17, 14, 4, vec3(50,50,50))
    --]]
    fill(30)
    text(self.t, self.x + 19.5, HEIGHT - self.y + 0.5)
    fill(230)
    text(self.t, self.x + 20, HEIGHT - self.y + 1)
    rsprite(self.ismall, self.x + 3, HEIGHT - self.y + 3, 14, 14, 2)
end
_isOnTop = {function() return true end}
_isOnTop[0] = function(self, x, y)
    for n = 1, self.cindex - 1 do
        if
            bounds(x, wins[n].x, wins[n].x + wins[n].w) and
            bounds(y, HEIGHT - wins[n].y - wins[n].h, HEIGHT - wins[n].y + 20) and
            wins[n].active
        then
            return false
        end
    end
    return true
end

local t = {[0] = false, [1] = true}

function isN(n, b) 
    return t[math.floor(b / n)] 
end
--[=[END_TAB]=]
--[=[TAB:Rounded]=]
local vertex = [[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    vColor = color;
    vTexCoord = texCoord;
    
    gl_Position = modelViewProjection * position;
}
]]

local fragment = [[
//
// A basic fragment shader
//
//Default precision qualifier
precision highp float;
//This represents the current texture on the mesh
uniform lowp sampler2D texture;
//The interpolated vertex color for this fragment
varying highp vec4 vColor;
// Screen position (bl)
uniform highp vec2 coords;
// Corner radius (bottom left, top left, top right, bottom right)
uniform highp vec4 r;
// Anti-Aliasing width (3 - ContentScaleFactor)
uniform highp float a;
// Width, Height
uniform highp vec2 size;
// Gradient - {r, g, b, a} - direction=top-to-bottom
// BottomColor = TopColor - g
uniform highp vec4 g;
varying highp vec4 vPosition;
//The interpolated texture coordinate for this fragment
varying highp vec2 vTexCoord;
void main()
{
    vec2 pos = vec2(vTexCoord.xy);
    // Corner Midpoints
    vec2 bl = coords + vec2(r.x, r.x);
    vec2 br = coords + vec2(size.x-r.w, r.w);
    vec2 ul = coords + vec2(r.y, size.y-r.y);
    vec2 ur = coords + vec2(size.x-r.z, size.y-r.z);
    //Set the output color to the texture color
    gl_FragColor = vColor - g*(1.-((pos.y - coords.y)/size.y));
    // Corners
    if (distance(pos, bl) >= r.x && (pos.x <= bl.x && pos.y <= bl.y)) {
        // bottom left
        gl_FragColor.w = (1. + (r.x - distance(pos, bl)) * a) - (1. - gl_FragColor.w);
    } else if (distance(pos, br) >= r.w && (pos.x >= br.x && pos.y <= br.y)) {
        // bottom right
        gl_FragColor.w = (1. + (r.w - distance(pos, br)) * a) - (1. - gl_FragColor.w);
    } else if (distance(pos, ul) >= r.y && (pos.x <= ul.x && pos.y >= ul.y)) {
        // upper left
        gl_FragColor.w = (1. + (r.y - distance(pos, ul)) * a) - (1. - gl_FragColor.w);
    } else if (distance(pos, ur) >= r.z && (pos.x >= ur.x && pos.y >= ur.y)) {
        // upper right
        gl_FragColor.w = (1. + (r.z - distance(pos, ur)) * a) - (1. - gl_FragColor.w);
    }
}
]]

local rr = {}
local v = vec2(10,10)
rr.sh = nil
rr.m = nil
function rr._ms() return rr.sh end
function rr._mm() return rr.m end
function rr.ms() if rr.sh then return rr.sh else rr.sh = shader(vertex, fragment) rr.ms = rr._ms return rr.sh end end
function rr.mm() if rr.m  then return rr.m  else rr.m  = mesh() rr.mm = rr._mm return rr.m end end

local m = rr.mm()

function rrect(x, y, w, h, r, g)
    --m = rr.mm()
    
    m.shader = rr.ms()
    
    if g and not g.w then
        g = vec4(g.x, g.y, g.z, 0)
    end
    
    m.shader.r = type(r) == "number" and vec4(r,r,r,r) or r
    
    m.shader.a = ContentScaleFactor / 2 + 0.5
    m.shader.coords = vec2(x, y)
    m.shader.size = vec2(w,h)
    m.shader.g = g and g / 255 or vec4(0,0,0,0)
    
    m.vertices = {
        vec2(x, y),
        vec2(x + w, y),
        vec2(x, y + h),
        vec2(x, y + h),
        vec2(x + w, y + h),
        vec2(x + w, y)
    }
    
    m.texCoords = m.vertices

    m:setColors(fill())

    m:draw()
end
--[=[END_TAB]=]
--[=[TAB:RoundedSprite]=]
--#nofunc

rs = {}
local v = vec2(10,10)
rs.sh = nil
rs.m = nil
function rs._ms() return rs.sh end
function rs._mm() return rs.m end
function rs.ms() if rs.sh then return rs.sh else rs.sh = shader("Documents:rsprite") rs.ms = rs._ms return rs.sh end end
function rs.mm() if rs.m  then return rs.m  else rs.m  = mesh() rs.mm = rs._mm return rs.m end end
function rsprite(i, x, y, w, h, r, g)
    local m2 = rs.mm()
    ---[[
    m2.shader = rs.ms()
    --m:addRect(0,0,1,1)
    
    if g and not g.w then
        g = vec4(g.x, g.y, g.z, 0)
    end
    
    -- Assign a shader
    m2.shader.r = r / math.max(w, h)
    m2.shader.a = math.max(w, h) * ContentScaleFactor
    m2.shader.coords = vec2(x, y)
    m2.shader.size = vec2(w,h)
    m2.shader.g = g and g / 255 or vec4(0,0,0,0)
    --]]
    
    -- Set vertices
    --[[
    m.vertices = triangulate 2     vec2(x,y),
        vec2(x+w,y),
        vec2(x+w,y+h),
        vec2(x,y+h)
    }
    --[=[
    --]]
    m2.vertices = {
        vec2(x, y),
        vec2(x + w, y),
        vec2(x, y + h),
        vec2(x, y + h),
        vec2(x + w, y + h),
        vec2(x + w, y)
    }
    -- Assign texture coordinates
    m2.texCoords = {vec2(0,0), vec2(1,0), vec2(0,1), vec2(0,1), vec2(1,1), vec2(1,0)}
    
    -- Assign a texture
    m2.texture = i--"Documents:BOXOFFICON"
    
    -- Set all vertex colors to white
    m2:setColors(0,0,0,0)
    
    --m:setRect(re, x, y, w, h)
    
    -- Draw the mesh
    m2:draw()
end
--rsprite = sprite
--[=[END_TAB]=]
--[=[TAB:UI]=]
--#nofunc

--UPLOADED_TAB:UI
ui = {}

--Button
ui.button = class()

function ui.button:init(win, x, y, w, h, t, c)
    self.win = win
    self.x, self.y, self.w, self.h, self.t, self.c = x, y, w, h, t, c or function() end
end

function ui.button:draw()
    fill(100)
    rrect(self.x, self.y, self.w, self.h, 6, vec3(50,50,50))
    if 
        (mousex and mousey) and 
        bounds(mousex, self.x, self.x + self.w) and bounds(mousey, self.y, self.y + self.h)
    then
        if CurrentTouch.state < ENDED then
            fill(200)
        elseif not self.ct then
            self.c()
            fill(240)
            self.ct = true
        else
            fill(240)
        end
    else
        fill(240)
        self.ct = false
    end
    rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 5, vec3(50,50,50))
    textMode(CENTER)
    fill(50)
    text(self.t, self.x + self.w / 2, self.y + self.h / 2)
end

-- Link
ui.link = class()

function ui.link:init(win, x, y, w, h, t, c, i)
    self.win = win
    self.x, self.y, self.w, self.h, self.t, self.c = x, y, w, h, t, c or function() end
    self.selected = 0
    self.i = i or image(0,0)
end

function ui.link:draw()
    if 
        (mousex and mousey) and 
        bounds(mousex, self.x, self.x + self.w) and bounds(mousey, self.y, self.y + self.h)
    then
        if CurrentTouch.state < ENDED then
            fill(230 - self.selected * 100, 230 - self.selected * 100, 230 - self.selected * 100, 255)
            rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 2, vec3(20,20,20))
            self.lt = false
        elseif not self.lt then
            self.selected = self.selected == 1 and 0 or 1
            self.c()
            fill(150,150,150, self.selected * 255)
            rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 2, vec3(20,20,20))
            self.lt = true
        else
            fill(150,150,150, self.selected * 255)
            rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 2, vec3(20,20,20))
        end
    else
        fill(150,150,150, self.selected * 255)
        rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 2, vec3(20,20,20))
        self.lt = false
    end
    textMode(CORNER)
    fill(50)
    text(self.t, self.x + self.h, self.y + 2)
    rsprite(self.i, self.x + 1, self.y + 1, self.h - 2, self.h - 2, 1)
end

--Text Edit
ui.textedit = class()

function ui.textedit:init(win, x, y, w, h, t, d)
    self.win = win
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.t = t and {t} or {""}
    self.d = d and d or "Enter text..."
    --self.c = self.t.len()
    self.f = false
    self.e = 0
    self.th = 13
    
    self.c = {0, 0}
    font("Inconsolata")
    fontSize(12)
    
    function self:text()
        return table.concat(self.t, "\n")
    end
end

function ui.textedit:draw(win)
    self.win = win or self.win
    clip(self.win.x + self.x, (HEIGHT - self.win.y - self.win.h) + self.y, self.w + 2, self.h + 2)
    fill(100)
    rrect(self.x, self.y, self.w, self.h, 6, vec3(30,30,30))
    if self.f then
        fill(240)
    else
        fill(220)
    end
    rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 5, vec3(10,10,10))
    
    textMode(CORNER)
    textWrapWidth(self.w - 12)
    font("Inconsolata")
    fontSize(12)
    if #self.t == 1 and self.t[1] == "" then
        fill(127)
        text(self.d, self.x + 6, self.y + self.h - 2 - 12 * #self.t)
    else
        fill(0)
        text(table.concat(self.t, "\n"), self.x + 6, self.y + self.h - 2 - 12 * #self.t)
    end
    
    if 
        bounds(mousex, self.x, self.x + self.w) and
        bounds(mousey, self.y, self.y + self.h)
    then 
        if CurrentTouch.state < ENDED then 
            showKeyboard()
            self.f = ElapsedTime 
            self.c[1] = math.floor((mousex - self.x) / 6) - 1
            self.c[1] = self.c[1] >= 0 and self.c[1] or 0
            self.c[2] = math.floor((self.y + self.h - (mousey) + 6) * (self.h - 6) / (12) / (self.h - 6))
            self.c[2] = self.c[2] <= #self.t and self.c[2] or #self.t
            self.c[2] = self.c[2] > 0 and self.c[2] or 1
            self.c[1] = self.c[1] < #self.t[self.c[2]] and self.c[1] or #self.t[self.c[2]]
        end
    else
        self.f = false
    end
    
    if self.f and (ElapsedTime - self.f) % 1 < 0.5 then
        line(
            self.x + self.c[1] * 6 + 6, self.y + self.h - (self.c[2] - 1) * 12 - 5, 
            self.x + self.c[1] * 6 + 6, self.y + self.h - (self.c[2] - 1) * 12 - 19
        )
    end
    if keyPressed ~= "NP" and self.f then
        if keyPressed == "\n" then
            self.c[2] = self.c[2] + 1
            table.insert(self.t, self.c[2], "")
            self.c[1] = 0
        elseif keyPressed == BACKSPACE then
            self.t[self.c[2]] = 
                (self.t[self.c[2]]):sub(1, range(self.c[1] - 1, 0, 9^99)) ..
                (self.t[self.c[2]]):sub(self.c[1] + 1, -1)
            self.c[1] = self.c[1] - 1
            if self.c[1] < 0 then
                self.c[2] = (self.c[2] > 1 and self.c[2] - 1 or 1)
                self.c[1] = self.t[self.c[2]] and #self.t[self.c[2]] or 0
            end
        else
            self.t[self.c[2]] = 
                (self.t[self.c[2]]):sub(1, self.c[1]) .. keyPressed .. 
                (self.t[self.c[2]]):sub(self.c[1] + 1, -1)
            self.c[1] = self.c[1] + 1
            if #self.t[self.c[2]] >= (self.w - 12) / 6 - 1 then
                self.c[1] = 0
                self.c[2] = self.c[2] + 1
                table.insert(self.t, self.c[2], "")
            end
        end
    end
    textWrapWidth(WIDTH)
end

--Scrolling Text Edit
ui.textscroll = class()

function ui.textscroll:init(win, x, y, w, h, t, d)
    self.win = win
    self.x, self.y = x, y
    self.w, self.h = w, h
    self.t = t and {t} or {""}
    self.d = d and d or "Enter text..."
    --self.c = self.t.len()
    self.f = false
    self.e = 0
    self.scroll = 0
    self.th = 13
    
    self.c = {0, 0}
    font("Inconsolata")
    fontSize(12)
    --self.fm = fontMetrics()
    self.sbegin = 0
    
    function self:text()
        return table.concat(self.t, "\n")
    end
end

function ui.textscroll:draw(win)
    self.win = win or self.win
    clip(self.win.x + self.x, (HEIGHT - self.win.y - self.win.h) + self.y, self.w + 2, self.h + 2)
    fill(100)
    rrect(self.x, self.y, self.w, self.h, 6, vec3(30,30,30))
    if self.f then
        fill(240 - (self.scrolling > 0 and 0 or 10))
    else
        fill(220)
    end
    rrect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, 5, vec3(10,10,10))
    
    textMode(CORNER)
    textWrapWidth(self.w - 12)
    font("Inconsolata")
    fontSize(12)
    if #self.t == 1 and self.t[1] == "" then
        fill(127)
        text(self.d, self.x + 6, self.y + self.h - 6 - 12 * #self.t)
    else
        fill(0)
        text(table.concat(self.t, "\n"), self.x + 6, self.y + self.h - 6 - 12 * #self.t - self.scroll)
    end
    
    if 
        bounds(mousex, self.x, self.x + self.w) and
        bounds(mousey, self.y, self.y + self.h)
    then 
        if CurrentTouch.state < ENDED then 
            if CurrentTouch.state == BEGAN then
                self.sbegin = ElapsedTime
                self.sx, self.sy = mousex, mousey
                self.scrolling = 1
            else
                if ElapsedTime - self.sbegin > 0.5 and not(self.scrolling == 2) then
                    showKeyboard()
                    self.f = ElapsedTime 
                    self.c[1] = math.floor((mousex - self.x) / 6) - 1
                    self.c[1] = self.c[1] >= 0 and self.c[1] or 0
                    self.c[2] = math.floor((self.y + self.h - (mousey + self.scroll) + 6) * (self.h - 6) / (12) / (self.h - 6))
                    self.c[2] = self.c[2] <= #self.t and self.c[2] or #self.t
                    self.c[2] = self.c[2] > 0 and self.c[2] or 1
                    self.c[1] = self.c[1] < #self.t[self.c[2]] and self.c[1] or #self.t[self.c[2]]
                    self.scrolling = 0
                elseif self.scrolling >= 1 and CurrentTouch.state >= BEGAN then
                    if 
                        bounds(CurrentTouch.deltaX, -1, 1) and bounds(CurrentTouch.deltaY, -1, 1) and 
                        ElapsedTime - self.sbegin < 0.5 and self.scrolling == 1 
                    then
                        self.scrolling = 0
                    elseif #self.t >= (self.h - 12) / 12 then
                        self.scrolling = 2
                        self.scroll = self.scroll + (self.sy - mousey)
                        if self.scroll < self.h - 12 - #self.t * 12 then
                            self.scroll = self.scroll - (self.sy - mousey)
                        elseif self.scroll > (#self.t) - (self.h - 6) / 12 then
                            --self.scroll = (#self.t) - (self.h - 6) / 12
                            self.scroll = self.scroll - (self.sy - mousey)
                        end
                        self.sy = mousey
                    end
                end
            end
        elseif self.scrolling == 1 then
            showKeyboard()
            self.f = ElapsedTime 
            self.c[1] = math.floor((mousex - self.x) / 6) - 1
            self.c[1] = self.c[1] >= 0 and self.c[1] or 0
            self.c[2] = math.floor((self.y + self.h - (mousey + self.scroll) + 6) * (self.h - 6) / (12 + 0) / (self.h - 6))
            self.c[2] = self.c[2] <= #self.t and self.c[2] or #self.t
            self.c[2] = self.c[2] > 0 and self.c[2] or 1
            self.c[1] = self.c[1] < #self.t[self.c[2]] and self.c[1] or #self.t[self.c[2]]
            self.scrolling = 0
        end
    elseif CurrentTouch.state == ENDED then
        self.f = false
    end
    
    if self.f and (ElapsedTime - self.f) % 1 < 0.5 then
        stroke(40, 84, 185, 255)
        strokeWidth(1)
        line(
            self.x + self.c[1] * 6 + 6, self.y + self.h - (self.c[2] - 1) * 12 - 5 - self.scroll, 
            self.x + self.c[1] * 6 + 6, self.y + self.h - (self.c[2] - 1) * 12 - 19 - self.scroll
        )
    end
    if keyPressed ~= "NP" and self.f then
        if keyPressed == "\n" then
            self.c[2] = self.c[2] + 1
            table.insert(self.t, self.c[2], "")
            self.c[1] = 0
        elseif keyPressed == BACKSPACE then
            self.t[self.c[2]] = 
                (self.t[self.c[2]]):sub(1, range(self.c[1] - 1, 0, 9^99)) ..
                (self.t[self.c[2]]):sub(self.c[1] + 1, -1)
            self.c[1] = self.c[1] - 1
            if self.c[1] < 0 then
                if #self.t[self.c[2]] == 0 then
                    table.remove(self.t, self.c[2])
                end
                self.c[2] = (self.c[2] > 1 and self.c[2] - 1 or 1)
                self.c[1] = self.t[self.c[2]] and #self.t[self.c[2]] or 0
            end
        else
            self.t[self.c[2]] = 
                (self.t[self.c[2]]):sub(1, self.c[1]) .. keyPressed .. 
                (self.t[self.c[2]]):sub(self.c[1] + 1, -1)
            self.c[1] = self.c[1] + 1
            if #self.t[self.c[2]] >= (self.w - 12) / 6 - 1 then
                self.c[1] = 0
                self.c[2] = self.c[2] + 1
                table.insert(self.t, self.c[2], "")
            end
        end
    end
    textWrapWidth(WIDTH)
end
--[=[END_TAB]=]
--[=[TAB:Wins]=]

--UPLOADED_TAB:Win
local titlebar = _titlebar
local taskbar = taskbar
local isOnTop = _isOnTop

local isOne = isOne

local bounds = bounds
local range = range

wins = {}
awins = {}

ftypes = {}

local context = setContext
local sprite = sprite
local rsprite = rsprite
local rrect = rrect

--local bounds, range = bounds, range

function adjustcindex()
    for i, v in ipairs(wins) do
        wins[i].cindex = i
        --winIndexes[wins[i].index] = wins[i].cindex
    end
end

local function runAll()
    for n = #wins, 1, -1 do
        if wins[n].active then
            wins[n]:run()
        end
    end
end
--[[
local function runAll()
    for i, v in pairs(awins) do
        v:draw()
    end
end
--]]
local function drawAndRunAll()
    for n = #wins, 1, -1 do
        if wins[n].active then
            wins[n]:run()
            wins[n]:draw()
        end
    end
end

function drawWindows()
    noStroke()
    noSmooth()
    rectMode(CORNER)
    textMode(CORNER)
    spriteMode(CORNER)
    font("SourceSansPro-Regular")
    --font("HelveticaNeue")
    fontSize(13.5)
    pushStyle()
    drawAndRunAll()
    --background(255) runAll() taskbar(1)
    --background(255)
    --drawAndRunAll()
    --taskbar()
    ctended = isN(CurrentTouch.state, ENDED)
    
    --drawFlashAlert()
    --clock()
    if keyPressed ~= "NP" then keyPressed = "NP" end
end

local cwinindex = 1
window = class()

function window:init(x, y, w, h, t, i)
    for i, v in pairs(ui) do self[i] = ui[i] end
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.t = t
    self.i = i
    self.touches = {}
    self.index = cwinindex -- A unique identifier
    self.cindex = #wins + 1 --self.index
    cwinindex = cwinindex + 1
    self.__CONTENTS = image(self.w, self.h)
    self.clip = function() clip(self.x + 1, HEIGHT - self.y - self.h + 2, self.w - 2, self.h - 2) end
    self.translate = function() translate(self.x + 1, HEIGHT - self.y - self.h + 1) end
    self.mousex, self.mousey, self.pmousex, self.pmousey = nil
    table.insert(wins, self)
end

function window:optimize()
    self.main = self.main or function() end
    self.background = self.background or function() end
    self.onclose = self.onclose or function() end
    self.start = self.start or function() end
    ---[=[
    if not self.i then
        self.i = image(27, 27)
        ---[[
        setContext(self.i)
        font("HelveticaNeue-Light")
        fontSize(28)
        textMode(CENTER)
        fill(0)
        background(255)
        text(self.t, 10, 13)
        setContext()
        --]]
    end
    --]=]
    if not self.ismall then self.ismall = self.i end
    self.keypressed = self.keypressed or function() end
    self.fill = self.fill or color(237, 237, 237, 255)
end

function window:draw()
    popStyle()
    
    titlebar[math.floor(1/self.cindex)](self)
    fill(self.closehover and color(175,50,50) or color(230, 30, 30))
    rrect(self.x + self.w - 30, HEIGHT - self.y + 3, 27, 14, 4, vec3(50,70,70))
    --]]
    local r, g, b = fill()
    fill(r-40,g-60,b-60)
    rrect(self.x + self.w - 7, HEIGHT - self.y + 3, 4, 4, 0, vec3(5,10,10))
    --]]
    --smooth()
    
    pushStyle()
end

function window:run()
    
    --if self.done then return end
    
    local x, y = CurrentTouch.x, CurrentTouch.y
    local onTop = isOnTop[math.floor(1/self.cindex)](self, x, y)
    --if self.cindex > 1 then
    --[[
        for n = 1, self.cindex - 1 do
            if
                bounds(x, wins[n].x, wins[n].x + wins[n].w) and
                bounds(y, HEIGHT - wins[n].y - wins[n].h, HEIGHT - wins[n].y + 20) and
                wins[n].active
            then
                onTop = false
                break
            end
        end
    --end
    --]]
    if bounds(x, self.x, self.x + self.w) and bounds(y, HEIGHT - self.y - self.h, HEIGHT - self.y) and onTop then
        self:show()
        adjustcindex()
    end
    if 
        (bounds(x, self.x + self.w - 30, self.x + self.w - 3) and 
        bounds(y, HEIGHT - self.y + 3, HEIGHT - self.y + 17) and onTop)
        or self.done
    then
        if self.closed then else
            if (CurrentTouch.state == ENDED and ctended) then
                self.closed = true
                local persist = self:hide()
                if not persist then
                    return
                else
                    self.active = true
                    self.done = false
                    self.closed = true
                end
            elseif self.done then
                local persist = self:hide()
                self.done = false
                return
            else
                self.closehover = true
            end
        end
    else
        self.closed = false
        self.closehover = false
        if bounds(x, self.x, self.x + self.w) and bounds(y, HEIGHT - self.y, HEIGHT - self.y + 20) and
            not(self.dragx and self.dragy) and CurrentTouch.state == BEGAN and onTop
        then
            moved = 1
            self.dragx = x
            self.dragy = y
            self.sdx = self.x
            self.sdy = self.y
            table.remove(wins, self.cindex)
            table.insert(wins, 1, self)
            adjustcindex()
            --[[
            for i, v in ipairs(wins) do
                winIndexes[wins[i].index] = wins[i].cindex
            end
            --]]
            if self.onFocus then
                self.onFocus()
            end
        elseif self.dragx and self.dragy then
            moved = 1
            if CurrentTouch.state == ENDED then
                self.dragx, self.dragy = nil
                self.clip = function() clip(self.x + 1, HEIGHT - self.y - self.h + 2, self.w - 2, self.h - 2) end
                self.translate = function() translate(self.x + 1, HEIGHT - self.y - self.h + 1) end
            else
                self.x = math.floor(self.sdx + (x - self.dragx))
                self.y = math.floor(self.sdy - (y - self.dragy))
                self.clip = function() clip(self.x + 1, HEIGHT - self.y - self.h + 2, self.w - 2, self.h - 2) end
                self.translate = function() translate(self.x + 1, HEIGHT - self.y - self.h + 1) end
            end
        end
    end
    pushStyle()
    
    fill(self.fill)
    stroke(127)
    strokeWidth(1/ContentScaleFactor)
    rect(self.x, HEIGHT - self.y - self.h + 1, self.w, self.h)
    
    --[[
    stroke(150)
    rect(self.x + 1/ContentScaleFactor, HEIGHT - self.y - self.h + 1 + 1/ContentScaleFactor, self.w-1, self.h-1)
    --]]
    
    --Run window
    --if self.main then
        --clip()
    self.pmousex, self.pmousey = self.mousex and self.mousex or CurrentTouch.x - self.x - 1, self.mousey and self.mousey or CurrentTouch.y - (HEIGHT - self.y - self.h + 1)
    self.mousex, self.mousey = CurrentTouch.x - self.x - 1, CurrentTouch.y - (HEIGHT - self.y - self.h + 1)
    --pmousex, pmousey = CurrentTouch.prevX - self.x - 1, CurrentTouch.prevY - (HEIGHT - self.y - self.h + 1)
    if onTop then
        mousex, mousey, pmousex, pmousey = self.mousex, self.mousey, self.pmousex, self.pmousey
    else
        mousex, mousey, pmousex, pmousey = 0,0,0,0
    end
    clip(self.x + 1, HEIGHT - self.y - self.h + 2, self.w - 2, self.h - 2)
    pushMatrix()
    popStyle()
    pushStyle()
    translate(self.x + 1, HEIGHT - self.y - self.h + 1)
    self:main()
    clip()
    popMatrix()
    popStyle()
--end
--if self.background then
    self.background()
    --end
    --self:draw()
end

function window:show()
    --adjustcindex()
    table.remove(wins, self.cindex)
    table.insert(wins, 1, self)
    adjustcindex()
    self.active = true
    awins[self.index] = self
    moved = 1
    --self.done = false
end

function window:hide()
    moved = 1
    if self.active then
        self.active = false
        if self.temp then
            adjustcindex()
            table.remove(wins, self.cindex)
            table.remove(winsOrig, self.index)
            adjustcindex()
            return
        end
        return self.onclose()
    end
end

function window:mhide()
    self.active = false
    awins[self.index] = nil
    moved = 1
    self.done = true
end

function window:destroy()
    --adjustcindex()
    for i = 1, #wins do
        if wins[i] and wins[i].index == self.index then
            table.remove(wins, i)
        end
    end
    awins[self.index] = nil
    winsOrig[self.index] = nil
    self.active = false
    self.done = true
    self.hidden = true
    self.draw = function() end
    moved = 1
end

function window:newInstance(...)
    adjustcindex()
    cwinindex = #wins + 1
    table.insert(wins, cwinindex, {})
    for i, v in pairs(wins[self.cindex]) do
        wins[cwinindex][i] = v
    end
    for i, v in pairs(window) do
        wins[cwinindex][i] = v
    end
    wins[cwinindex]:optimize()
    wins[cwinindex].active = true
    --if (...) then
        wins[cwinindex].start(self, ...)
    --end
    --wins[cwinindex].hide = window.destroy
    table.insert(winsOrig, wins[#wins])
    n = #wins
    o = #winsOrig
    wins[n].temp = true
    wins[n].cindex = #wins
    wins[n].index = cwinindex
    winsOrig[o].temp = true
    winsOrig[o].cindex = #winsOrig
    winsOrig[o].index = cwinindex
    adjustcindex()
    --cwinindex = cwinindex + 1
end

function new(i)
    return wins[i]:newInstance()
end

function window:extensions(...)
    for i, v in ipairs{...} do
        ftypes[v] = self
    end
end

--[=[END_TAB]=]
--[=[TAB:Alert]=]
--UPLOADED_TAB:Alert
ui.OKAY_CANCEL = 0
ui.OKAY = 1

ui.alerttypes = {}
    
ui.alerttypes[ui.OKAY_CANCEL] = function(title, contents, f_okay, f_cancel)
    font("SourceSansPro-Regular")
    fontSize(13.5)
    local x, y = textSize(contents)
    x = math.max(x, 115)
    local calert = window(WIDTH / 2 - x / 2 + 20,  HEIGHT / 2 - (y + 20 + 24) / 2, x + 20, y + 35, title)
    calert.hidden = true
    
    --ui.calert.w_ = ui.calert.w
    --ui.calert.h_ = ui.calert.h
    
    calert.i = image(14,14)
        ---[[
    setContext(calert.i)
    font("HelveticaNeue-Bold")
    fontSize(15)
    textMode(CENTER)
    fill(255,100)
    rrect(0,0,14,14, 3)
    fill(255)
    text("!!", 6.5, 6.5)
    fill(0)
    text("!!", 7, 7)
    setContext()
    
    calert.done = false
    
    local okay = calert:button(10, 10, 50, 16, "Okay", function()
        adjustcindex()
        table.remove(wins, calert.cindex)
        calert:destroy()
        calert = nil
        adjustcindex()
        if f_okay then f_okay() end
    end)
    local cancel = calert:button(70, 10, 50, 16, "Cancel", function() 
        adjustcindex()
        table.remove(wins, calert.cindex)
        calert:destroy()
        calert = nil
        adjustcindex()
        if f_cancel then f_cancel() end
    end)
    
    calert.main = function()
        fill(0)
        textMode(CORNER)
        font("SourceSansPro-Regular")
        fontSize(13.5)
        
        text(contents, 10, calert.h - y - 5)
        okay:draw()
        cancel:draw()
    end
    
    calert:optimize()
    calert:show()
end

ui.alerttypes[ui.OKAY] = function(title, contents)
    font("SourceSansPro-Regular")
    fontSize(13.5)
    local x, y = textSize(contents)
    x = math.max(x, 75)
    local calert = window(WIDTH / 2 - x / 2 + 20,  HEIGHT / 2 - (y + 20 + 24) / 2, x + 20, y + 35, title)
    calert.hidden = true
    
    --ui.calert.w_ = ui.calert.w
    --ui.calert.h_ = ui.calert.h
    
    calert.i = image(14,14)
        ---[[
    setContext(calert.i)
    font("HelveticaNeue-Bold")
    fontSize(15)
    textMode(CENTER)
    fill(255,100)
    rrect(0,0,14,14, 3)
    fill(255)
    text("!!", 6.5, 6.5)
    fill(0)
    text("!!", 7, 7)
    setContext()
    
    calert.done = false
    
    local okay = calert:button(10, 10, 50, 16, "Okay", function()
        adjustcindex()
        table.remove(wins, calert.cindex)
        calert = nil
        adjustcindex()
    end)
    calert.main = function()
        fill(0)
        textMode(CORNER)
        font("SourceSansPro-Regular")
        fontSize(13.5)
        
        text(contents, 10, calert.h - y - 5)
        okay:draw()
    end
    
    calert:optimize()
    calert:show()
end

function ui.alert(alert_type, ...)
    ui.alerttypes[alert_type](...)
end

---[[
--]]
--[=[END_TAB]=]
--[=[TAB:WinSetup]=]
function winSetup()
    winsOrig, winIndexes = {}, {}
    for i, v in ipairs(wins) do 
        wins[i]:optimize()
        if not wins[i].hidden then
            table.insert(winsOrig, v)
        end
        winIndexes[i] = i 
    end
end
--[=[END_TAB]=]
--[=[TAB:DemoWindow]=]
dev = window(450, 100, 150, 50, "Debug")
dev.i = readImage("Documents:ngear")

local afps, t, lt = 60, nil, os.clock()
local fps, avg = {}, 1

for i = 1, avg + 1 do
    fps[i] = 100
end

local f, tfps = avg + 1, 0

local max = 0
---[[
dev.main = function()
    background(255, 255, 255, 255)
    tfps = 0
    for n = f - avg, f do
        tfps = tfps + fps[n] 
    end
    fill(0)
    --text("FPS: " .. math.floor(tfps / avg), 5, 5)
    text("Max FPS: " .. math.floor(max / avg) .. "\nFPS: " .. math.floor(tfps / avg), 5, 5)
    --text("Windows: " .. awins, 20, 30)
end

dev.background = function()
    local t=os.clock()
    table.insert(fps, 1/(t-lt))
    lt=t
    f = f + 1
    max = math.max(max, (tfps))
end
--dev.main()
--]]
dev:show()
--[=[END_TAB]=]
