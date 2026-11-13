# Viết Markdown và code trong Neovim

Mở lại Neovim sau khi thay cấu hình. `<leader>` là phím Space.

## Markdown

| Phím/lệnh | Cách dùng |
| --- | --- |
| `Space c p` | Bật/tắt preview Markdown trong trình duyệt. Có hỗ trợ bảng, công thức và Mermaid. |
| `Space u m` | Bật/tắt render heading, bảng và code block ngay trong editor. |
| `Space c f` | Format tài liệu; LazyVim cũng format khi lưu nếu chưa tắt autoformat. |
| `Space m i` | Dán ảnh clipboard hoặc ảnh được copy dưới dạng đường dẫn; lưu bản sao vào `assets/` cạnh file Markdown và chèn liên kết tương đối. |
| `Enter` hoặc `o` | Tiếp tục danh sách/checkbox; Enter trên mục trống để kết thúc danh sách. |
| `Space m c` | Đánh dấu/bỏ đánh dấu checkbox ở dòng hiện tại. |
| `Ctrl+t` / `Ctrl+d` trong insert mode | Tăng/giảm cấp danh sách. |
| `gN` | Đánh lại số thứ tự danh sách. |
| `Space m t` | Bật/tắt căn bảng khi gõ các cột phân cách bằng `|`. |
| `:TableModeRealign` | Căn lại bảng dưới con trỏ. |
| `gd`, `gr` | Theo liên kết/định nghĩa và xem nơi tham chiếu qua Marksman. |
| `Space u s` | Bật/tắt kiểm tra chính tả tiếng Anh. Mặc định tắt để không gạch chân toàn bộ văn bản tiếng Việt. |

Gõ `- [ ] Việc cần làm` để tạo checkbox. Dùng snippet Markdown qua menu autocomplete sẵn có.

Để tự cập nhật mục lục khi format/lưu, thêm hai marker:

```markdown
<!-- toc -->

<!-- tocstop -->
```

Nội dung dài được ngắt dòng mềm trên màn hình, không tự chèn xuống dòng vào từng đoạn văn. Quy tắc lint tuân theo cấu hình markdownlint của dự án nếu có.

Ảnh phải nằm trong clipboard (chụp/copy ảnh), không phải chỉ là chữ mô tả ảnh. Lưu file `.md` trước khi dán để có thư mục đích rõ ràng. Preview và dán ảnh chỉ tải plugin khi cần.

## Xuất tài liệu

Trong terminal, tại thư mục chứa tài liệu:

```sh
pandoc ghi-chu.md --toc -o ghi-chu.docx
pandoc ghi-chu.md --toc --pdf-engine=xelatex -V mainfont='Noto Sans' -o ghi-chu.pdf
```

Pandoc dùng được cho Markdown tiêu chuẩn, bảng và công thức. Sơ đồ Mermaid/PlantUML cần được render thành ảnh trước khi xuất PDF/Word; preview trình duyệt và Pandoc có khả năng khác nhau.

## Code và LaTeX

- C#: OmniSharp, CSharpier, netcoredbg và bộ chạy test VSTest.
- Rust: rust-analyzer/rustaceanvim, rustfmt, CodeLLDB; `:RustLsp runnables` để chạy và `Space d r` để chọn mục debug.
- Java: JDTLS, Java debugger và Java test bundles; `Space r r` giữ runner hiện có, `Space t t` chạy test class Java và `Space t r` chạy test gần con trỏ.
- `Space d b`: đặt breakpoint; `Space d c`: chạy/tiếp tục debug; `Space t`: nhóm phím test. Mở dự án và build trước khi chọn chương trình debug. C# có thể yêu cầu chọn file DLL trong `bin/Debug/`.
- LaTeX: VimTeX dùng `latexmk` + XeLaTeX, xem PDF bằng Zathura; `Ctrl+s` giữ thao tác lưu/biên dịch cũ.

JDTLS dùng JDK 25 riêng ở `~/.local/share/jdks/temurin-25`; Java 21 hệ thống vẫn dùng cho dự án. CSharpier dùng runtime riêng ở `~/.local/share/dotnet`. Pandoc nằm ở `~/.local/bin/pandoc`.

Kiểm tra khi gặp lỗi: `:checkhealth`, `:Mason`, `:ConformInfo`, `:LspInfo`, `:Lazy`.
