-- Swayimg OLED configuration for ThinkPad P14s 2.8K OLED
swayimg.antialiasing = true
swayimg.mode = "viewer"
swayimg.set_format_params('raw', { camera_wb = true })

-- OLED True Black background (Tận dụng độ tương phản vô cực của màn OLED)
swayimg.viewer.set_window_background(0xff000000)
swayimg.gallery.window_color = 0xff000000
swayimg.gallery.unselected_color = 0xff101010
swayimg.gallery.selected_color = 0xff252525
swayimg.gallery.border_color = 0xff57c7ff

-- Tự căn chỉnh ảnh nét trên màn 2.8K
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.autocenter = true
swayimg.text.font = "GeistMono Nerd Font"
swayimg.text.size = 18
swayimg.text.timeout = 3 -- Tự ẩn thông số sau 3s để tập trung xem ảnh
