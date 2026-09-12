swayimg.mode = "gallery"
swayimg.appid = "wallpaper-picker"
swayimg.title = "Wallpaper Selector (Enter/Click to set, Esc to close)"
swayimg.gallery.thumb_size = 250
swayimg.gallery.aspect = "fill"
swayimg.gallery.padding_size = 14
swayimg.gallery.border_size = 3
swayimg.gallery.border_color = 0xff5af78e
swayimg.gallery.window_color = 0xf0202020

-- Font & Text style matching Waybar
swayimg.text.font = "GeistMono Nerd Font"
swayimg.text.size = 13
swayimg.text.color = 0xffeff0eb
swayimg.text.shadow = 0xcc181818

swayimg.gallery.set_text("topleft", {
  "  {name}"
})
swayimg.gallery.set_text("topright", {
  "󰋩 {list.index}/{list.total}"
})
swayimg.gallery.set_text("bottomright", {
  "󰌑 Enter / Click: Apply  •  Esc: Exit"
})

-- Wallpaper Modes (fill, fit, stretch, center, tile)
local home = os.getenv("HOME") or "/home/aquistus"
local mode_file = home .. "/.config/sway/.wallpaper_mode"
local modes = { "fill", "fit", "stretch", "center", "tile" }
local mode_idx = 1

local f = io.open(mode_file, "r")
if f then
  local saved = f:read("*l")
  f:close()
  if saved then
    saved = saved:match("^%s*(.-)%s*$")
    for i, m in ipairs(modes) do
      if m == saved then
        mode_idx = i
        break
      end
    end
  end
end

local function update_mode_display()
  local cur = modes[mode_idx]:upper()
  swayimg.gallery.set_text("bottomleft", {
    "󰸉 Mode: [" .. cur .. "]  (Press 'M' or Tab to switch: fill | fit | stretch | center | tile)"
  })
end

local function cycle_mode()
  mode_idx = (mode_idx % #modes) + 1
  update_mode_display()
end

update_mode_display()

local function apply_wallpaper()
  local img = swayimg.gallery.get_image()
  if img and img.path then
    local dest = home .. "/.config/sway/current_wallpaper"
    local cur_mode = modes[mode_idx]

    local mf = io.open(mode_file, "w")
    if mf then
      mf:write(cur_mode .. "\n")
      mf:close()
    end

    os.execute("ln -sf '" .. img.path .. "' '" .. dest .. "'")
    os.execute("swaymsg 'output * bg \"" .. dest .. "\" " .. cur_mode .. "'")
    local fname = img.path:match("([^/]+)$") or "wallpaper"
    os.execute("notify-send -i '" .. img.path .. "' -a 'Wallpaper' 'Wallpaper Changed (" .. cur_mode:upper() .. ")' '" .. fname .. "'")
    swayimg.exit()
  end
end

swayimg.gallery.on_key("m", cycle_mode)
swayimg.gallery.on_key("M", cycle_mode)
swayimg.gallery.on_key("Tab", cycle_mode)

swayimg.gallery.on_key("Return", apply_wallpaper)
swayimg.gallery.on_key("space", apply_wallpaper)
swayimg.gallery.on_mouse("MouseLeft", apply_wallpaper)

swayimg.gallery.on_key("Escape", function()
  swayimg.exit()
end)
swayimg.gallery.on_key("q", function()
  swayimg.exit()
end)
