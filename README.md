# bin2riscv

📦 Convert your legacy `x86_64` Linux executable binaries to `RISC-V` ELF binaries — as automatically as possible.

---

## 🚀 What is this?

`bin2riscv` is a proof-of-concept CLI tool that takes an **x86_64 executable**, decompiles it to C using [RetDec](https://github.com/avast/retdec), applies basic transformations for portability, and recompiles it as a **RISC-V ELF** binary using `clang`.

---

## ✨ Features

- ✅ Decompile x86_64 ELF to C
- ✅ Auto-patch for portability (`__int64` → `int64_t`, etc.)
- ✅ Replace Intel Intrinsics with RISC-V shim functions (e.g., `_mm_add_pd` → `shim_mm_add_pd`)
- ✅ Compile using `clang --target=riscv64-unknown-elf`
- ✅ Optionally run in `qemu-riscv64`
- ✅ Dockerfile included for full reproducibility

---

## 🛠 Requirements

- Python 3.x
- [`retdec`](https://github.com/avast/retdec) (must be in PATH)
- `clang` with RISC-V backend
- `ld.lld` (for linking)
- `qemu-riscv64` (optional for testing)
- OR: just use Docker! 🐳

---

## 📦 Install

```bash
git clone https://github.com/takahashi-akari/bin2riscv.git
cd bin2riscv
```

---

## 🔧 Usage

```bash
python bin2riscv.py your_binary.out
```

or with the all-in-one shell script:

```bash
./bin2riscv.sh your_binary.out
```

This will generate:
- `your_binary.c`: Decompiled C source
- `your_binary_riscv.elf`: RISC-V executable
- `intrin_shim.h`: Intrinsics header with stubbed RISC-V versions

If `qemu-riscv64` is available, it will run the binary too.

---

## 🐳 Docker Support

```bash
docker build -t bin2riscv .
docker run --rm -it -v $(pwd):/workspace bin2riscv ./bin2riscv.sh your_binary.out
```

---

## 🔍 Limitations

- Only simple binaries are supported for now (no dynamic linking, no syscalls)
- Intrinsics mapping is partial (e.g., only basic `_mm_*_pd` supported)
- Reverse-engineered function names may be placeholder (`func_1`, etc.)
- Not a security tool — purely experimental

---

## 📅 Roadmap

- [ ] Add more Intrinsics mappings (via scriptable JSON)
- [ ] Support custom linker scripts and relocation
- [ ] Extend to support dynamic binaries and libc
- [ ] Build full LLVM IR pipeline
- [ ] Optional: Web UI for drag-and-drop ELF → RISC-V conversion

---

## 🧠 Author

Created by [takahashi-akari] — powered by curiosity and low-level wizardry.

---

## 📜 License

MIT

---

## 📁 File List

```
bin2riscv.py           # Main CLI tool
intrin_shim.h          # Generated header for RISC-V Intrinsics shim
README.md              # Documentation (this file)
linker.ld              # Minimal linker script for RISC-V ELF
.gitignore             # Ignore temp and build artifacts
requirements.txt       # Python dependencies (currently empty)
bin2riscv.sh           # All-in-one shell automation
intrin_shims.sh        # Intrinsics header generator
Dockerfile             # Docker environment setup
```

Let’s convert some binaries 🚀
